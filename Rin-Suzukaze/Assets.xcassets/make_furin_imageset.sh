#!/bin/bash

for theta in R5 R4 R3 R2 R1 C0 L1 L2 L3 L4 L5 ; do
	for phase in 1 2 3 4 5 6 ; do
		n="${phase}${theta}.png"
		f="../../resources/furin/${n}"
		rm -r "furin_${phase}${theta}.imageset"
		mkdir "furin_${phase}${theta}.imageset"
		cp "../../resources/furin/${n}" "furin_${phase}${theta}.imageset/"
		cp "cat_page0.imageset/Contents.json" "furin_${phase}${theta}.imageset/"
		sed -i -e "s/cat0.png/${phase}${theta}.png/g" "furin_${phase}${theta}.imageset/Contents.json"
	done
done
