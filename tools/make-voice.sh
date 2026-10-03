#!/bin/sh
# Renders the system-voice clips embedded in datasphere.html (VOICE_CLIPS), using espeak-ng with a
# flat-pitched, breathy variant ("datasphere") plus a little echo. Needs espeak-ng and ffmpeg.
# Usage: tools/make-voice.sh <outdir>   then base64 the .mp3 files into VOICE_CLIPS.
set -e
OUT=${1:-voice}; mkdir -p "$OUT"; DATA=$(espeak-ng --version | sed -n 's/.*Data at: //p')
cp -R "$DATA" "$OUT/data"
cat > "$OUT/data/voices/!v/datasphere" <<'V'
name datasphere
language variant
gender female
klatt 3
pitch 158 162
formant 0 100 100 100
formant 1 96 95 100
formant 2 97 80 100
breath 4 3 2 2 1 1
breathw 150 150 200 200 400 400
voicing 85
consonants 70 80
flutter 0
speed 125
V
for pair in "threat:threat" "friendly:friendly" "keyfound:access key found" "granted:access granted" "denied:access denied" "danger:danger"; do
  k=${pair%%:*}; txt=${pair#*:}
  espeak-ng --path="$OUT/data" -v en-us+datasphere -s 125 -a 90 -g 4 -w "$OUT/raw_$k.wav" "$txt"
  ffmpeg -loglevel error -y -i "$OUT/raw_$k.wav" -af "highpass=f=140,lowpass=f=5200,aecho=0.8:0.55:70|140:0.22|0.12,volume=1.2" -ac 1 -ar 22050 -b:a 40k "$OUT/$k.mp3"
done
