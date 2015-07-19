#!/bin/bash

/usr/bin/ffmpeg -y -i /var/images/stream_thumbnails/$1.flv -vf fps=1 /var/images/stream_thumbnails/$1.png >> /var/log/stream_record_done.log
/usr/bin/convert /var/images/stream_thumbnails/$1.png -resize 1280x720 /var/images/stream_thumbnails/$1.png >> /var/log/stream_record_done.log
/usr/local/bin/aws s3 cp /var/images/stream_thumbnails/$1.png s3://codewatch-tv/stream-thumbnails/$1.png >> /var/log/stream_record_done.log
