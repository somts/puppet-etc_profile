# Private class for init.pp
class etc_profile::install {
  if $etc_profile::packages {
    ensure_packages($etc_profile::packages)
  }
}
