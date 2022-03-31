# Manage Bourne (Again) SHell aka sh or bash
# On Linux, sh and bash have little distinction, but on
# UNIX-like OSes such as FreeBSD or Darwin, it matters more
class etc_profile::config::bourne {
  assert_private("Must only be called by ${module_name}")

  $base_d = "${etc_profile::basedir_bourne}/profile.d"

  # In RedHat, C shell and Bourne (Again) shell have the same basedir.
  # Conditionally manage the resource to avoid declaring it twice.
  ensure_resource('file', $base_d, {
    ensure => 'directory',
    owner  => $etc_profile::owner,
    group  => $etc_profile::group,
    mode   => '0755',
  })

  file { "${base_d}/pathmunge.sh":
    ensure  => 'file',
    owner   => $etc_profile::owner,
    group   => $etc_profile::group,
    mode    => '0644',
    content => epp('etc_profile/pathmunge.sh.epp', {
      module_name => $module_name,
      pathmunges  => $etc_profile::pathmunges,
    }),
    require => File[$base_d],
  }

  # Many kernels ship with a well-formed system file, but for the ones
  # that don't, we install a templated version of CentOS 7's file.
  if $etc_profile::manage_bourne_system_files {
    file { "${etc_profile::basedir_bourne}/profile" :
      ensure  => 'file',
      owner   => $etc_profile::owner,
      group   => $etc_profile::group,
      mode    => '0644',
      content => epp('etc_profile/profile.epp',{
        basedir         => $base_d,
        module_name     => $module_name,
        path_hostname   => $etc_profile::path_hostname,
        operatingsystem => join(
          [$facts['os']['name'], $facts['os']['release']['full']], ' '),
        }),
    }
  }
}
