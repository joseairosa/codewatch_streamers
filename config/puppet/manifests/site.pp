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

class ruby {
  package { 'ruby':
    ensure => 'installed'
  }

  class { 'ruby':
    gems_version  => 'latest'
  }
}


#class { 'nginx': }
#nginx::vhost {'streamer':
#  template=>'nginx.conf.erb'
#}
