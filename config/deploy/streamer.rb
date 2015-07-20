set :stage, 'streamer'

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
      execute 'sudo puppet module install --force fsalum-newrelic'
      execute 'sudo puppet module install --force puppetlabs-apt'
      execute 'sudo puppet module install --force puppetlabs-stdlib'
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
