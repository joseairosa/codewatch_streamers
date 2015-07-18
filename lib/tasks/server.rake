namespace :server do
  task :spawn do
    server = fog.servers.create(
        image_id: 'ami-47a23a30', # ubuntu 14.04
        flavor_id: 'm4.xlarge',
        key_name: key_pair,
        dns_name: 'elfenleid',
        tags: 'streamer'
    )

    # wait for it to get online
    server.wait_for { print '.'; ready? }

    puts "server started at #{server.dns_name}"
  end

  task :drop do
    if (server = fog.servers.detect { |s| s.dns_name == ec2_address })
      server.destroy
    else
      puts 'No server is running'
    end
  end
end
