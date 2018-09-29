# Manage /etc/profile and pals
# Notes:
#  Darwin: nothing pre-configured, so we make like RedHat.
#  Debian: CSH in /etc/csh/login.d, SH in /etc/profile.d.
#  FreeBSD: nothing pre-configured, so we make like RedHat.
#  RedHat: everything in /etc/profile.d by default.
class etc_profile(
  Stdlib::Absolutepath $sh_basedir,
  Stdlib::Absolutepath $csh_basedir,
  Hash $pathadd,
  Hash $manpathadd,
  Stdlib::Absolutepath $path_hostname,
  Array[Stdlib::Absolutepath] $directories,
  Optional[Array] $packages,
  Optional[Stdlib::Absolutepath] $path_csh_login,
  Optional[Stdlib::Absolutepath] $path_profile,
) {
  validate_re('^(Darwin|FreeBSD|Linux)$', $::kernel, "${::kernel} unsupported")

  Class['etc_profile::install'] -> Class['etc_profile::config']
  contain etc_profile::install
  contain etc_profile::config
}
