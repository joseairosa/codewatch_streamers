require 'fog'

# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
# Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

set :key_pair, 'codewatch-streamer-ec2' # ec2 key-pair name, store it in ~/.ssh/ec2/

# deploy to ec2
# ssh_options[:keys] = "~/.ssh/ec2/#{key_pair}.pem"
