file { "/var/images":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 755,
  before => Class['build']
}

file { "/var/images/stream_thumbnails":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 755,
  before => Class['build']
}

file { "/var/images/recording_thumbnails":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 755 ,
  before => Class['build']
}

file { "/var/recordings":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 755 ,
  before => Class['build']
}

file { "/home/ubuntu/downloads":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 755 ,
  before => Class['build']
}

class build {
  include wget

  wget::fetch { "download nginx 1.8.0":
    source      => 'http://nginx.org/download/nginx-1.8.0.tar.gz',
    destination => '/home/streamer/downloads/nginx-1.8.0.tar.gz',
    timeout     => 0,
    verbose     => false,
    before      => Exec['unpack nginx-1.8.0.tar.gz']
  }

  wget::fetch { "download nginx-rtmp":
    source      => 'https://github.com/arut/nginx-rtmp-module/archive/master.zip',
    destination => '/home/streamer/downloads/master.zip',
    timeout     => 0,
    verbose     => false,
    before      => Exec['unzip nginx-rtmp-module/master.zip']
  }

  exec { 'unzip nginx-rtmp-module/master.zip':
    cwd     => '/home/streamer/downloads',
    command => '/usr/bin/unzip master.zip',
    creates => "/home/streamer/downloads/nginx-rtmp-module-master"
  }

  exec { 'unpack nginx-1.8.0.tar.gz':
    cwd     => '/home/streamer/downloads',
    command => '/bin/tar -xzvf /home/streamer/downloads/nginx-1.8.0.tar.gz',
    creates => "/home/streamer/downloads/nginx-1.8.0",
    before  => Exec['configure nginx']
  }

  exec { 'configure nginx':
    cwd     => '/home/streamer/downloads/nginx-1.8.0',
    command => '/usr/bin/env sudo /home/streamer/downloads/nginx-1.8.0/configure --with-http_xslt_module --with-http_ssl_module --add-module=/home/streamer/downloads/nginx-rtmp-module-master',
    before  => File["/etc/nginx/nginx.conf"]
  }

  file { "/usr/local/nginx/html/nclients.xsl":
    content => template('nclients.xsl'),
    before  => Exec['restart nginx']
  }

  file { "/etc/init.d/nginx":
    content => template('nginx_service'),
    before  => Exec['restart nginx']
  }

  file { "/usr/local/bin/stream_record_done.sh":
    content => template('stream_record_done.sh'),
    before  => Exec['restart nginx']
  }

  file { "/usr/local/bin/record_record_done.sh":
    content => template('record_record_done.sh'),
    before  => Exec['restart nginx']
  }

  file { "/etc/nginx/nginx.conf":
    content => template('nginx.conf.erb'),
    before  => Exec['restart nginx']
  }

  exec { 'restart nginx':
    command => '/usr/bin/env sudo /usr/sbin/service nginx restart',
  }
}

class { build: }
