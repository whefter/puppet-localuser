class localuser::params {
  $user_default_shell = '/bin/bash'

  case $::osfamily {
    /(D|ebian)/: {
      $admin_group_name = 'sudo'
    }
    /(R|r)ed(H|h)at/: {
      $admin_group_name = 'wheel'
    }
    default: {
      $admin_group_name = ''
    }
  }
}
