require 'shellwords'

set :stage, 'streamer'

def ffmpeg_options
  options = ['-re -threads 0 -i rtmp://localhost/stream/$name']
  options << '-crf 28 -g 60 -preset veryfast -c:v libx264 -profile:v main -b:v 1920K -maxrate 1920K -bufsize 1920K -s 1920x1080 -f flv -c:a aac -ac 1 -strict -2 -b:a 128k rtmp://localhost/watch/$name@1080p'
  options << '-crf 28 -g 60 -preset veryfast -c:v libx264 -profile:v main -b:v 960K -maxrate 960K -bufsize 960K -s 1280x720 -f flv -c:a aac -ac 1 -strict -2 -b:a 128k rtmp://localhost/watch/$name@720p'
  options << '-crf 28 -g 60 -preset veryfast -c:v libx264 -profile:v main -b:v 480K -maxrate 480K -bufsize 480K -s 640x360 -f flv -c:a aac -ac 1 -strict -2 -b:a 56k rtmp://localhost/watch/$name@320p'
  options << '-crf 28 -g 60 -preset veryfast -c:v libx264 -profile:v main -b:v 240K -maxrate 240K -bufsize 240K -s 320x180 -f flv -c:a aac -ac 1 -strict -2 -b:a 56k rtmp://localhost/watch/$name@180p'
  options << '2>>/var/log/ffmpeg/ffmpeg-$name.log;'
  options.join(' ')
end

set :ffmpeg_options, ffmpeg_options

namespace :server do
  desc 'Spawns a new streamer server'
  task :spawn do
    server = fog.servers.create(
        image_id: 'ami-47a23a30', # ubuntu 14.04
        flavor_id: 'c4.xlarge',
        security_group_ids: ['sg-d45e4bb1'],
        key_name: fetch(:key_pair),
        vpc_id: 'vpc-14dd5271',
        subnet_id: 'subnet-15bdc570',
        availability_zone: fetch(:instance_region),
        tags: {'Name' => Bazaar.heroku, 'Group' => 'streamer'}
    )

    # wait for it to get online
    server.wait_for { print '.'; ready? }
    puts ''
    puts "Server started at #{server.dns_name}, #{server.public_ip_address}, #{server.private_ip_address}"
  end

  desc 'Setup server'
  task :setup do
    on roles(:app) do
      execute 'sudo locale-gen en_GB en_GB.UTF-8'
      execute 'sudo dpkg-reconfigure locales'
      execute 'sudo add-apt-repository -y ppa:mc3man/trusty-media'
      execute 'sudo apt-get update'
      execute 'sudo apt-get -y upgrade'
      execute 'sudo apt-get -y install git puppet locate build-essential libpcre3 libpcre3-dev libssl-dev unzip yasm libass-dev software-properties-common python-pip libxml2 libxml2-dev libxslt1-dev vim htop libav-tools libavcodec-extra-54 libavformat-extra-54 ffmpeg gstreamer0.10-ffmpeg yamdi imagemagick libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool pkg-config'
      execute 'sudo puppet module install --force maestrodev-wget'
      execute 'sudo pip install awscli'
      execute 'sudo chown ubuntu:ubuntu /etc/puppet'
    end
  end

  desc 'Drops a specific streamer server'
  task :drop do
    if (server = fog.servers.detect { |s| s.dns_name == ec2_address })
      server.destroy
    else
      puts 'No server is running'
    end
  end
end
