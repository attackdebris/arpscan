NAME = arpscan
VERSION = 0.10
OUI = /usr/local/lib/arpscan/oui
#DIET = diet
CFLAGS = -O2 -g -DVER=$(VERSION) -DOUI=$(OUI)
SRC = Makefile arpscan.c oui.c list.h oui.awk
OBJ = $(filter %.o,$(SRC:.c=.o))
EXE = arpscan

ifneq ($(DIET),)
LDFLAGS += -lcompat
CC := $(DIET) $(CC)
endif

$(EXE): $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $(EXE)

clean:
	rm -f $(OBJ) $(EXE) core oui

install: arpscan
	install -s arpscan /usr/local/sbin/
	@echo Note: To download and install vendor database: make db-install

db: oui

oui: oui.txt
	awk -f oui.awk $^ >$@

ifeq (,$(wildcard oui.txt))
oui.txt: db-download
endif

db-download:
	wget -N http://standards.ieee.org/regauth/oui/oui.txt

db-update: db-download db-install

db-install: oui
	install -Dm 644 oui $(OUI)

PKG := $(NAME)-$(VERSION)

dist:
	ln -s . $(PKG)
	tar czf $(PKG).tar.gz --group=root --owner=root $(addprefix $(PKG)/, $(SRC)); \
	rm $(PKG)

.PHONY: clean install dist db db-download db-install db-update
