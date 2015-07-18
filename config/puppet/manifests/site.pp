user { 'streamer':
  name => 'streamer',
  groups  => ["ubuntu"],
  home => '/home/streamer'
}

file { "/home/streamer":
  ensure => "directory",
  owner  => "streamer",
  group  => "ubuntu",
  mode   => 755,

}

package { 'puppetlabs-ruby':
  ensure => installed,
}

class { 'ruby':
  version => '2.2.1',
  gems_version  => 'latest'
}

class { 'nginx': }
nginx::vhost {'streamer':
  template=>'nginx.conf.erb'
}
