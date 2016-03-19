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
  $managehome          = true,
  $system              = false,
  $ssh_rsa_ids         = {},
  $purge_ssh_keys      = false,
  $ssh_authorized_keys = [],
  $comment             = "${name}@${::fqdn}",
  $admin               = false,
)
{
  include ::localuser::params

  validate_array($groups)

  $_groups = $admin ? {
    true    => concat($groups, $localuser::params::admin_group_name),
    default => $groups,
  }

  $_home = $home ? {
    default => $home,
  }

  if $_home == undef {
    $_managehome = false
  } else {
    $_managehome = $managehome
  }

  if $::kernel =~ /^(L|l)inux$/ {
    ::localuser::linux { $name:
      ensure              => $ensure,
      uid                 => $uid,
      gid                 => $gid,
      password            => $password,
      password_crypt      => $password_crypt,
      shell               => $shell,
      groups              => $_groups,
      home                => $_home,
      managehome          => $_managehome,
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
      groups   => $_groups,
      home     => $_home,
      comment  => $comment,
    }
  }

  each($ssh_rsa_ids) |$rsa_id| {
    $keyname  = $rsa_id['keyname']
    $basename = $rsa_id['basename'] ? {
      undef   => 'id_rsa',
      default => $rsa_id['basename'],
    }

    ::localuser::rsa_id { "${name}_${basename}":
      home                => $_home,
      user                => $name,
      basename            => $basename,
      public_key_content  => $rsa_id['public_key_content'],
      public_key_source   => $rsa_id['public_key_source'],
      private_key_content => $rsa_id['private_key_content'],
      private_key_source  => $rsa_id['private_key_source'],
    }
  }
}
