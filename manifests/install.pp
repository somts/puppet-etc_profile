# Private class for init.pp
class etc_profile::install {
  assert_private("Must only be called by ${module_name}")

  if $etc_profile::packages {
    ensure_packages($etc_profile::packages)
  }
}
