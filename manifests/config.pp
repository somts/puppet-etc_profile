# Private class
class etc_profile::config {
  file {
    "${etc_profile::csh_basedir}/usr_local.csh":
      ensure  =>  'file',
      content => template('etc_profile/profile.d/usr_local.csh.erb'),
      require => File[$etc_profile::csh_basedir],;
    "${etc_profile::sh_basedir}/usr_local.sh":
      ensure  => 'file',
      content => template('etc_profile/profile.d/usr_local.sh.erb'),
      require => File[$etc_profile::sh_basedir],;
  }

  # Conditionally manage some files
  if !empty($etc_profile::directories) {
    file { $etc_profile::directories :
      ensure => 'directory',
      mode   => '0755',
      owner  => 0,
      group  => 0,
      before => [
        File["${etc_profile::csh_basedir}/usr_local.csh"],
        File["${etc_profile::sh_basedir}/usr_local.sh"],
      ],
    }
  }

  # Conditionally manage the global csh file
  if $etc_profile::path_csh_login {
    file { $etc_profile::path_csh_login :
      ensure  => 'file',
      content => template('etc_profile/csh.login.erb'),
      before  => File["${etc_profile::csh_basedir}/usr_local.csh"],
    }
  }
  # Conditionally manage the global sh file
  if $etc_profile::path_profile {
    file { $etc_profile::path_profile :
      ensure  => 'file',
      content => template('etc_profile/profile.erb'),
      before  => File["${etc_profile::sh_basedir}/usr_local.sh"],
    }
  }
}
