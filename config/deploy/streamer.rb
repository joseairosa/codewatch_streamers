namespace :server do
  desc 'Spawns a new streamer server'
  task :spawn do
    # require 'pry'; binding.pry
    server = fog.servers.create(
        image_id: 'ami-47a23a30', # ubuntu 14.04
        flavor_id: 'c4.xlarge',
        security_group_ids: ['sg-22f9f347'],
        key_name: fetch(:key_pair),
        dns_name: 'elfenleid',
        vpc_id: 'vpc-14dd5271',
        subnet_id: 'subnet-15bdc570',
        availability_zone: 'eu-west-1b',
        tags: {'Name' => 'streamer'}
    )

    # wait for it to get online
    server.wait_for { print '.'; ready? }

    puts "server started at #{server.dns_name}"
  end

  desc 'Setup server'
  task :setup do
    on roles(:app) do
      execute 'sudo locale-gen en_GB en_GB.UTF-8'
      execute 'sudo dpkg-reconfigure locales'
      execute 'sudo add-apt-repository -y ppa:nginx/stable'
      execute 'sudo add-apt-repository -y ppa:mc3man/trusty-media'
      execute 'sudo apt-get update'
      execute 'sudo apt-get -y upgrade'
      execute 'sudo apt-get -y install git puppet locate build-essential libpcre3 libpcre3-dev libssl-dev unzip yasm libass-dev software-properties-common python-pip libxml2 libxml2-dev libxslt1-dev vim htop libav-tools libavcodec-extra-54 libavformat-extra-54 nginx=1.8.0-1~trusty ffmpeg gstreamer0.10-ffmpeg'
      execute 'sudo puppet module install --force maestrodev-wget'
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
