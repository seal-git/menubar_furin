import sys
import json
import pydub
import numpy as np
from pydub import AudioSegment

args = sys.argv
input_mp3 = args[1]
output_mp3 = args[2]
start_width = float(args[3])
end_width = float(args[4])
duration = float(args[5])

volume_list = np.arange(start_width, end_width, duration)
base_sound = AudioSegment.from_file(input_mp3, format="mp3")  # 音声を読み込み
for i in volume_list:
    edit_sound = base_sound + i
    edit_sound.export(f"../mp3/{output_mp3}_{i}.mp3", format="mp3")

