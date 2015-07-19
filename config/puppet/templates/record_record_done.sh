#!/bin/bash

/usr/bin/yamdi -i $1 -o /var/recordings/$2 >> /var/log/record_record_done.log
/usr/local/bin/aws s3 cp /var/recordings/$2 s3://codewatch-tv/recordings/$2 >> /var/log/record_record_done.log
/usr/bin/ffmpeg -y -i /var/recordings/$2 -ss 00:00:01 -vframes 1 /var/images/recording_thumbnails/$3.png >> /var/log/record_record_done.log
/usr/bin/convert /var/images/recording_thumbnails/$3.png -resize 1280x720 /var/images/recording_thumbnails/$3.png >> /var/log/record_record_done.log
/usr/local/bin/aws s3 cp /var/images/recording_thumbnails/$3.png s3://codewatch-tv/recording-thumbnails/$3.png >> /var/log/record_record_done.log
