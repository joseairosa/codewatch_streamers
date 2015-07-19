user { 'nginx':
  name => 'nginx',
  groups  => ["ubuntu"]
}

file { "/var/images":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 777,
  before => Class['build']
}

file { "/var/images/stream_thumbnails":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 777,
  before => Class['build']
}

file { "/var/images/recording_thumbnails":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 777,
  before => Class['build']
}

file { "/var/recordings":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 777,
  before => Class['build']
}

file { "/home/ubuntu/downloads":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 755,
  before => Class['build']
}

file { "/var/log/ffmpeg":
  ensure => "directory",
  owner  => "ubuntu",
  group  => "ubuntu",
  mode   => 777,
  before => Class['build']
}

class aws {
  file { "/home/ubuntu/.aws":
    ensure => "directory",
    owner  => "ubuntu",
    group  => "ubuntu",
    mode   => 775
  }

  file { "/home/ubuntu/.aws/config":
    content => template("aws/config.erb"),
    ensure => "file",
    owner  => "ubuntu",
    group  => "ubuntu",
    mode   => 777,
    before => Class['build']
  }

  file { "/home/ubuntu/.aws/credentials":
    content => template("aws/credentials.erb"),
    ensure => "file",
    owner  => "ubuntu",
    group  => "ubuntu",
    mode   => 777,
    before => Class['build']
  }
}

class build {
  include wget

  wget::fetch { "download nginx 1.8.0":
    source      => 'http://nginx.org/download/nginx-1.8.0.tar.gz',
    destination => '/home/ubuntu/downloads/nginx-1.8.0.tar.gz',
    timeout     => 0,
    verbose     => false,
    before      => Exec['unpack nginx-1.8.0.tar.gz']
  }

  wget::fetch { "download nginx-rtmp":
    source      => 'https://github.com/arut/nginx-rtmp-module/archive/master.zip',
    destination => '/home/ubuntu/downloads/master.zip',
    timeout     => 0,
    verbose     => false,
    before      => Exec['unzip nginx-rtmp-module/master.zip']
  }

  exec { 'unzip nginx-rtmp-module/master.zip':
    cwd     => '/home/ubuntu/downloads',
    command => '/usr/bin/unzip master.zip',
    creates => "/home/ubuntu/downloads/nginx-rtmp-module-master"
  }

  exec { 'unpack nginx-1.8.0.tar.gz':
    cwd     => '/home/ubuntu/downloads',
    command => '/bin/tar -xzvf /home/ubuntu/downloads/nginx-1.8.0.tar.gz',
    creates => "/home/ubuntu/downloads/nginx-1.8.0",
    before  => Exec['configure nginx']
  }

  exec { 'configure nginx':
    cwd     => '/home/ubuntu/downloads/nginx-1.8.0',
    command => '/usr/bin/env sudo /home/ubuntu/downloads/nginx-1.8.0/configure --with-http_xslt_module --with-http_ssl_module --add-module=/home/ubuntu/downloads/nginx-rtmp-module-master',
    require => Exec['unpack nginx-1.8.0.tar.gz'],
    before  => Exec["make nginx"]
  }

  exec { 'make nginx':
    cwd     => '/home/ubuntu/downloads/nginx-1.8.0',
    command => '/usr/bin/env sudo make',
    require => Exec['configure nginx'],
    before  => Exec["make install nginx"]
  }

  exec { 'make install nginx':
    cwd     => '/home/ubuntu/downloads/nginx-1.8.0',
    command => '/usr/bin/env sudo make install',
    require => Exec['make nginx'],
    before  => File["/usr/local/nginx/conf/nginx.conf"]
  }

  file { "/usr/local/nginx/conf/nginx.conf":
    content => template("$cap_stage/nginx.conf"),
    require => Exec['make install nginx'],
    before  => Exec['restart nginx']
  }

  file { "/usr/local/nginx/html/nclients.xsl":
    content => template('nclients.xsl'),
    owner   => "ubuntu",
    group   => "ubuntu",
    mode    => 755,
    require => Exec['make install nginx'],
    before  => Exec['restart nginx']
  }

  file { "/usr/local/nginx/html/stat.xsl":
    content => template('stat.xsl'),
    owner   => "ubuntu",
    group   => "ubuntu",
    mode    => 755,
    require => Exec['make install nginx'],
    before  => Exec['restart nginx']
  }

  file { "/etc/init.d/nginx":
    content => template('nginx_service'),
    mode    => 755,
    before  => Exec['restart nginx']
  }

  exec { 'restart nginx':
    command => '/usr/bin/env sudo /usr/sbin/service nginx restart',
    require => File['/usr/local/nginx/conf/nginx.conf']
  }
}


class streamer {
  include build
  include aws

  file { "/usr/local/bin/stream_record_done.sh":
    content => template('stream_record_done.sh'),
    owner   => "ubuntu",
    group   => "ubuntu",
    mode    => 755,
    before  => Exec['restart nginx']
  }

  file { "/usr/local/bin/record_record_done.sh":
    content => template('record_record_done.sh'),
    owner   => "ubuntu",
    group   => "ubuntu",
    mode    => 755,
    before  => Exec['restart nginx']
  }
}

class load_balancer {
  include build
  include aws

}

class vod {
  include build
  include aws

  exec { 'clone s3fs':
    cwd     => '/home/ubuntu/downloads',
    command => '/usr/bin/git clone https://github.com/s3fs-fuse/s3fs-fuse',
    creates => "/home/ubuntu/downloads/s3fs-fuse"  ,
    before  => Exec['s3fs ./autogen.sh']
  }

  exec { 's3fs ./autogen.sh':
    cwd     => '/home/ubuntu/downloads/s3fs-fuse',
    command => '/usr/bin/env sudo /home/ubuntu/downloads/s3fs-fuse/autogen.sh',
    require => Exec['clone s3fs'],
    before  => Exec['s3fs ./configure']
  }

  exec { 's3fs ./configure':
    cwd     => '/home/ubuntu/downloads/s3fs-fuse',
    command => '/usr/bin/env sudo /home/ubuntu/downloads/s3fs-fuse/configure --prefix=/usr --with-openssl',
    require => Exec['s3fs ./autogen.sh'],
    before  => Exec['make s3fs']
  }

  exec { 'make s3fs':
    cwd     => '/home/ubuntu/downloads/s3fs-fuse',
    command => '/usr/bin/env sudo make',
    require => Exec['s3fs ./configure'],
    before  => Exec['make install s3fs']
  }

  exec { 'make install s3fs':
    cwd     => '/home/ubuntu/downloads/s3fs-fuse',
    command => '/usr/bin/env sudo make install',
    require => Exec['make s3fs']
  }
}

class { $cap_stage: }
