#!/bin/bash

if [ $# != 0 ] ; then
	echo "useage: ${0}"
	exit 1
fi

for i in `seq 1 128`
do
	rm ${i}.mp3
done

for i in `seq 1 96`
do
	ffmpeg -i mono/furin_small.wav -af volume=-`awk "BEGIN { print 0.28*$((96 - ${i})) }"`dB ${i}.mp3

done

for i in `seq 97 128`
do
	ffmpeg -i mono/furin_large.wav -af volume=-`awk "BEGIN { print 0.28*$((128 - ${i})) }"`dB ${i}.mp3

done
