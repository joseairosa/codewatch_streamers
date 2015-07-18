require 'capistrano/puppetize'

def find_servers
  @servers ||= fog.servers.select { |s| s.tags['Name'] == 'streamer' }
end

def fog
  @fog ||= Fog::Compute.new(
      provider: 'AWS',
      region: 'eu-west-1',
      aws_access_key_id: ENV['CODEWATCH_AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['CODEWATCH_AWS_SECRET_ACCESS_KEY']
  )
end

set :application, 'codewatch_streamer'
set :user, 'ubuntu'
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"

set :use_sudo, true
set :runner, "#{fetch(:user)}"
set :scm, :git
set :repository, 'git@github.com:joseairosa/codewatch_streamers.git' # thats a public path, if you want private you have to setup github public key etc stuff

set :ssh_private_key, File.expand_path("#{ENV['HOME']}/.ssh/ec2/codewatch-streamer-ec2.pem")
set :ssh_options, { keys: fetch(:ssh_private_key), forward_agent: true }

warn "Deploying codebase to #{find_servers.map(&:id).join(' ')}"

# role :app, *(streamer_server_ids)
role :app, %w{ubuntu@ec2-52-18-68-213.eu-west-1.compute.amazonaws.com}
