#!/bin/awk -f

$2 == "(hex)" {
	n = $1; gsub(/-/, "", n)

	v = ""
	for(i=3;i<=NF;i++) {
		w = $i
		if(w ~ /^[A-Z'`-]+[.,]?$/) w = substr(w,1,1) tolower(substr(w,2))
		v = v " " w
	}

	t = ""
	if(match(v, / \(.+\)$/)) {
		t = substr(v,RSTART)
		v = substr(v,1,RSTART-1)
	}

	gsub(/ *\. +/, ". ", v)
	gsub(/ *, +/, ", ", v)
	do {
		l = length(v)
		sub(/[,.]+ *$/, "", v)
		sub(/ [Ss]\.(a(\.u)?|r\.[lo])$/, "", v)
		sub(/ A\/S$/, "", v)
		sub(/ Limited$/, "", v)
		sub(/ Co(rporation|(rp)?)$/, "", v)
		sub(/ [Ii]nc$/, "", v)
		sub(/ (Co\.,?)?[Ll]td$/, "", v)
		sub(/ [Gg]mb[hH]$/, "", v)
		sub(/ Kg$/, "", v)
		sub(/ Pty$/, "", v)
		sub(/ [&+]$/, "", v)
	} while(length(v) < l)
	gsub(/^ +/, "", v)

	gsub(/Cisco Systems$/, "Cisco", v)
	if(v=="Ibm") v="IBM"

	print n, v t
}
