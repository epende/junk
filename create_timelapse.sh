#!/bin/sh

if [ $# -eq 0 ] ; then
    echo 'USAGE:  $0 <cam number>'
    exit 0
fi

CAM=$1
DIR=/home/nginx/html/cam${CAM}
TZ="America/Denver"
DAY=$(date --date yesterday +"%Y%m%d")
INPUT_MATCH_FILENAME="${DIR}/cam-${DAY}*.mp4"
OUTPUT_FILENAME="${DIR}/cam${CAM}-${DAY}.mp4"
CONCAT_MATCH="${DIR}/${INPUT_MATCH_FILENAME}"
#TEMPFILE="/var/tmp/cam${CAM}-file_list.txt"
#$(ls -1 ${INPUT_MATCH_FILENAME} > $TEMPFILE)
FILES=$(ls -1 ${INPUT_MATCH_FILENAME} | head -n -1 | paste -sd+ | sed "s/\+/ \\+ /g")
echo "input match:$INPUT_MATCH_FILENAME"
echo "tempfile:$TEMPFILE"
echo "files:$FILES"
#echo $OUTPUT_FILENAME
#echo $CONCAT_MATCH

#/usr/bin/ffmpeg -i concat:\"${CONCAT_MATCH}\" -c copy $OUTPUT_FILENAME
rm ${OUTPUT_FILENAME}
rm ${OUTPUT_FILENAME}.mkv
#ffmpeg -i concat:"${FILES}" -c copy $OUTPUT_FILENAME
echo "command: mkvmerge -o ${OUTPUT_FILENAME}.mkv $FILES"
mkvmerge -o ${OUTPUT_FILENAME}.mkv $FILES
ffmpeg -i ${OUTPUT_FILENAME}.mkv -codec copy ${OUTPUT_FILENAME}
