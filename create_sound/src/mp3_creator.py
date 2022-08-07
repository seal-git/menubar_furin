import os
import sys
import json
import pydub
import numpy as np
from pydub import AudioSegment

args = sys.argv
input_file = args[1]
output_mp3 = args[2]
db = args[3]
num = args[4]
sign = args[5]

ext = os.path.splitext(input_file)[1][1:]

base_sound = AudioSegment.from_file(input_file, format=ext)  # 音声を読み込み
for i in range(int(num)):
    if (i == 0):
        edit_sound = base_sound
        edit_sound.export(f"../mp3/{output_mp3}_{i}.mp3", format="mp3")
    else:
        if (sign == "plus"):
            edit_sound = base_sound + float(db)
            edit_sound.export(f"../mp3/{output_mp3}_{i}.mp3", format="mp3")
        elif (sign == "minus"):
            edit_sound = base_sound - float(db)
            edit_sound.export(f"../mp3/{output_mp3}_-{i}.mp3", format="mp3")

