# @summary Manage /etc/profile and CSH/ZSH equivalents
# Notes:
#  Darwin: ZSH/CSH not pre-configured, so we make like RedHat.
#  Debian: CSH in /etc/csh/login.d, SH in /etc/profile.d.
#  FreeBSD: nothing pre-configured, so we make like RedHat.
#  RedHat: CSH/SH in /etc/profile.d by default.
#
# @param pathmunges Hash of directories to have each shell look for
# @param path_hostname path where `which hostname` resolves to
# @param owner String of shell file owner (probably root)
# @param group String of shell file group (probably wheel)
# @param basedir_bourne Absolutepath where system profile lives
# @param basedir_cshell Absolutepath where system csh.cshrc et al lives
# @param basedir_zshell Absolutepath where system zshenv et al lives
# @param manage_bourne Boolean to manage Bourne (Again) shell or not
# @param manage_cshell Boolean to manage Berkeley UNIX C shell or not
# @param manage_zshell Boolean to manage Z shell or not
# @param manage_bourne_system_files Boolean to manage EG /etc/profile
# @param manage_cshell_system_files Boolean to manage EG /etc/csh.login
# @param path_csh_cshrc Absolutepath to system file csh.cshrc
# @param path_csh_login Absolutepath to system file csh.login
# @param path_csh_logout Absolutepath to system file csh.logout
# @param profile_cshell Relative path where pathmunge.csh will live
# @param packages Package(s) to ensure are installed
class etc_profile(
  Hash[String, Hash[Enum['append'], Boolean]] $pathmunges,
  Stdlib::Absolutepath $path_hostname,
  String[1] $owner,
  String[1] $group,
  Stdlib::Absolutepath $basedir_bourne,
  Stdlib::Absolutepath $basedir_cshell,
  Stdlib::Absolutepath $basedir_zshell,
  Boolean $manage_bourne,
  Boolean $manage_cshell,
  Boolean $manage_zshell,
  Boolean $manage_bourne_system_files,
  Boolean $manage_cshell_system_files,
  Stdlib::Absolutepath $path_csh_cshrc,
  Stdlib::Absolutepath $path_csh_login,
  Stdlib::Absolutepath $path_csh_logout,
  Enum['cshrc.d', 'login.d', 'profile.d'] $profile_cshell,
  Variant[String[1], Array[String[1]], Undef] $packages,
) {
  validate_re('^(Darwin|FreeBSD|Linux)$', $facts['kernel'],
    "${facts['os']['name']} ${facts['os']['release']} unsupported")

  Class['etc_profile::install'] -> Class['etc_profile::config']
  contain 'etc_profile::install'
  contain 'etc_profile::config'
}
