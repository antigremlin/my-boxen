require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }
  class { 'nodejs::global': version => '0.12.7' }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.2.3': }
  class { 'ruby::global': version => '2.1.7' }

  # python versions
  python::version { '2.7.10': }
  python::version { '3.4.3': }
  
  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  # cask installs
  include brewcask
  homebrew::tap { 'caskroom/versions': }

  package { 'appcleaner': provider => 'brewcask' }
  package { 'daisydisk': provider => 'brewcask' }
  package { 'skype': provider => 'brewcask' }
  package { 'mou': provider => 'brewcask' }
  package { 'taskpaper': provider => 'brewcask' }

  package { 'adobe-digital-editions': provider => 'brewcask' }
  package { 'spotify': provider => 'brewcask' }

  package { 'google-chrome': provider => 'brewcask' }
  package { 'firefox': provider => 'brewcask' }

  package { 'emacs': provider => 'brewcask' }
  package { 'sublime-text': provider => 'brewcask' }
  package { 'github-desktop': provider => 'brewcask' }
  package { 'sourcetree': provider => 'brewcask' }
  package { 'versions': provider => 'brewcask' }

  package { 'java': provider => 'brewcask' }
  package { 'ant':
    install_options => [ '--with-ivy' ]
  }
  package { 'maven': }
  package { 'gradle': }
  package { 'intellij-idea': provider => 'brewcask' }
  package { 'sts': provider => 'brewcask' }
  package { 'eclipse-java': provider => 'brewcask' }

  package { 'virtualbox': provider => 'brewcask' }
  package { 'virtualbox-extension-pack': provider => 'brewcask' }
  package { 'vagrant': provider => 'brewcask' }
  package { 'awscli': }
  package { 'docker': }
  package { 'docker-machine': }
  package { 'docker-compose': }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
