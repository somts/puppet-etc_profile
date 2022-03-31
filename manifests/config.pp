# Private class
class etc_profile::config {
  assert_private("Must only be called by ${module_name}")

  if $etc_profile::manage_bourne { contain 'etc_profile::config::bourne' }
  if $etc_profile::manage_cshell { contain 'etc_profile::config::cshell' }
  if $etc_profile::manage_zshell { contain 'etc_profile::config::zshell' }
}
