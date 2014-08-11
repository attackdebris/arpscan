#include <sys/types.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <err.h>
#define _STR(S) #S
#define STR(S) _STR(S)

typedef uint8_t u8;
static int fd = -2;
static char *ouiptr, *ouiend;

static void open_oui()
{
	struct stat st;
	fd = open("oui", O_RDONLY);
	if(fd < 0) {
		fd = open(STR(OUI), O_RDONLY);
		if(fd < 0) goto err;
	}
	if(fstat(fd, &st) < 0 || st.st_size == 0) goto err_cl;
	ouiptr = mmap(0, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	ouiend = ouiptr + st.st_size;
	if(ouiptr == MAP_FAILED) {
err_cl:
		close(fd); fd=-1;
err:
		warnx("Can't open OUI database");
		return;
	}
#ifdef MADV_SEQUENTIAL
	madvise(ouiptr, st.st_size, MADV_SEQUENTIAL);
#endif
}

void print_oui(int sp, u8 a[6])
{
	char addr[7], *p, *q;
	if(fd < 0) {
		if(fd == -2)
			open_oui();
		if(fd < 0)
			return;
	}
	sprintf(addr, "%02X%02X%02X", a[0], a[1], a[2]);

	for(p=ouiptr; p<ouiend; p=q+1) {
		q = memchr(p, '\n', ouiend-p);
		if(!q) q=ouiend;
		if(q-p < 8 || memcmp(p, addr, 6))
			continue;

		p += 7;
print:
		printf("%*s%.*s", sp, "", (int)(q-p), p);
		return;
	}
	if(a[0]==0 && a[1]==0xFF) {
		p = "(generated)";
		q = p + 11;
		goto print;
	}
}
