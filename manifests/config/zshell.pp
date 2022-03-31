# Manage Z shell aka zsh
class etc_profile::config::zshell {
  assert_private("Must only be called by ${module_name}")

  # We want our .d dirs in a subdir rather than /etc
  $base_d = $etc_profile::basedir_zshell ? {
    /\/etc$/ => "${etc_profile::basedir_zshell}/zsh",
    default  => $etc_profile::basedir_zshell,
  }

  file { "${base_d}/zshenv.d/pathmunge.zsh":
    ensure  => 'file',
    content => epp('etc_profile/pathmunge.zsh.epp', {
        pathmunges  => $etc_profile::pathmunges,
        module_name => $module_name,
    }),
    require => File["${base_d}/zshenv.d"],
  }

  # ZSH package will install some, but not all expected system files.
  # We will ensure system files exist, but not manage their contents.
  #
  # Add a complimentary '.d' directory for each system file, then
  # add a line to each system file that loads *.zsh from the respective
  # '.d' directory.
  if $base_d != $etc_profile::basedir_zshell {
    file { $base_d:
      ensure => 'directory',
      owner  => $etc_profile::owner,
      group  => $etc_profile::group,
      mode   => '0755',
      before => File[
        "${base_d}/zshenv.d", "${base_d}/zprofile.d", "${base_d}/zshrc.d",
        "${base_d}/zlogin.d", "${base_d}/zlogout.d",
      ],
    }
  }
  ['zshenv', 'zprofile', 'zshrc', 'zlogin', 'zlogout'].each |String $z| {
    file {
      "${etc_profile::basedir_zshell}/${z}":
        ensure => 'file',
        owner  => $etc_profile::owner,
        group  => $etc_profile::group,
        mode   => '0644',;
      "${base_d}/${z}.d":
        ensure => 'directory',
        owner  => $etc_profile::owner,
        group  => $etc_profile::group,
        mode   => '0755',;
    }
    file_line { "enable ${z}.d":
      path    => "${etc_profile::basedir_zshell}/${z}",
      line    => join([
        "for i in ${base_d}/${z}.d/*.zsh(N)",
        'do source $i', 'done'], '; '),
      require => File["${etc_profile::basedir_zshell}/${z}"],
    }
  }
}
