# Manage Berkeley UNIX C shell aka csh
class etc_profile::config::cshell {
  assert_private("Must only be called by ${module_name}")

  $base_d = "${etc_profile::basedir_cshell}/${etc_profile::profile_cshell}"

  # In RedHat, C shell and Bourne (Again) shell have the same basedir.
  # Conditionally manage the resource to avoid declaring it twice.
  ensure_resource('file', $base_d, {
    ensure => 'directory',
    owner  => $etc_profile::owner,
    group  => $etc_profile::group,
    mode   => '0755',
  })

  file { "${base_d}/pathmunge.csh":
    ensure  => 'file',
    owner   => $etc_profile::owner,
    group   => $etc_profile::group,
    content => epp('etc_profile/pathmunge.csh.epp', {
      module_name => $module_name,
      pathmunges  => $etc_profile::pathmunges,
    }),
    require => File[$base_d],;
  }

  # Almost every kernel supported in this module ships with or installs
  # 3 system-wide files for CSH in the same locations: /etc/csh.cshrc, 
  # /etc/csh.login and /etc/csh.logout. However, the files vary pretty
  # widely in terms of what they setup (see copies under this module's
  # files). This module's EPP templates attempt to normalize CSH setup
  # across OSes and can be optionally installed where desired.
  if $etc_profile::manage_cshell_system_files {
    file {
      $etc_profile::path_csh_cshrc:
        ensure  => 'file',
        owner   => $etc_profile::owner,
        group   => $etc_profile::group,
        mode    => '0644',
        content => epp('etc_profile/csh.cshrc.epp', {
          searchdir       => $base_d,
          module_name     => $module_name,
          path_hostname   => $etc_profile::path_hostname,
          operatingsystem => join(
            [$facts['os']['name'], $facts['os']['release']['full']], ' '),
          }),;
      $etc_profile::path_csh_login:
        ensure  => 'file',
        owner   => $etc_profile::owner,
        group   => $etc_profile::group,
        mode    => '0644',
        content => epp('etc_profile/csh.login.epp', {
          basedir         => $base_d,
          module_name     => $module_name,
          path_hostname   => $etc_profile::path_hostname,
          operatingsystem => join(
            [$facts['os']['name'], $facts['os']['release']['full']], ' '),
          }),;
      $etc_profile::path_csh_logout:
        ensure  => 'file',
        owner   => $etc_profile::owner,
        group   => $etc_profile::group,
        mode    => '0644',
        content => epp('etc_profile/csh.logout.epp', {
          module_name     => $module_name,
          operatingsystem => join(
            [$facts['os']['name'], $facts['os']['release']['full']], ' '),
          }),;
    }
  }
}
