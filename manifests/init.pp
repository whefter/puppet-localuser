define localuser
(
  $ensure              = present,
  $uid                 = undef,
  $gid                 = undef,
  $password            = undef,
  $password_crypt      = undef,
  $shell               = undef,
  $groups              = [],
  $home                = undef,
  $system              = false,
  $ssh_rsa_ids         = {},
  $purge_ssh_keys      = true,
  $ssh_authorized_keys = {},
  $global_ssh_id_rsa   = {},
  $comment             = "${name}@${::fqdn}",
  $roles               = [],
)
{
  validate_array($groups)
  
  $_groups = member($roles, 'admin') ? {
    true    => concat($groups, $localuser::params::admin_group_name),
    default => $groups,
  }

  $_home = $home ? {
    undef   => $name ? {
      'root'  => '/root',
      default => "${localuser::params::home_base_path}/${name}",
    },
    default => $home,
  }
  
  if $::kernel =~ /^(L|l)inux$/ {
    ::localuser::linux { $name:
      ensure              => $ensure,
      uid                 => $uid,
      gid                 => $gid,
      password            => $password,
      password_crypt      => $password_crypt,
      shell               => $shell,
      groups              => $groups,
      home                => $_home,
      system              => $system,
      purge_ssh_keys      => $purge_ssh_keys,
      ssh_authorized_keys => $ssh_authorized_keys,
      comment             => $comment,
    }
  } elsif $::kernel =~ /^(W|w)indows$/ {
    ::localuser::windows { $name:
      ensure   => $ensure,
      uid      => $uid,
      gid      => $gid,
      password => $password,
      groups   => $groups,
      home     => $_home,
      comment  => $comment,
    }
  }

  each($ssh_rsa_ids) |$keyname, $rsa_id| {
    $basename = $rsa_id['basename'] ? {
      undef   => 'id_rsa',
      default => $rsa_id['basename'],]
    }

    ::localuser::rsa_id { "${name}_${basename}":
      home               => $_home,
      user               => $name,
      basename           => $basename,
      publickey_content  => $rsa_id['public_key'],
      privatekey_content => $rsa_id['private_key'],
    }
  }
}
