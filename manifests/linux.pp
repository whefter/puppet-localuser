define localuser::linux (
  $ensure,
  $uid,
  $gid,
  $password,
  $password_crypt,
  $shell,
  $groups,
  $home,
  $system,
  $purge_ssh_keys,
  $ssh_authorized_keys,
  $comment,
) {
  include localuser::params

  validate_array($ssh_authorized_keys)

  $_shell = $shell ? {
    undef   => $system ? {
      true    => '/bin/false',
      default => $localuser::params::user_default_shell,
    },
    default => $shell,
  }

  # If only plaintext password was passed, hash it
  if $password_crypt {
    $_password = $password_crypt
  } elsif $password {
    $_password = inline_template("<%= '${password}'.crypt(\"\$6\$#{SecureRandom.base64(6)}\") %>")
  } else {
    $_password = undef
  }

  if $ensure == 'present' {
    group { $name: gid => $uid, } ->
    user { $name:
      uid            => $uid,
      gid            => $name,
      home           => $home,
      managehome     => true,
      comment        => $comment,
      shell          => $shell,
      purge_ssh_keys => $purge_ssh_keys,
      groups         => $groups,
      system         => $system,
      password       => $_password,
    }

    each($ssh_authorized_keys) |$key| {
      if is_string($key) {
        if $key =~ /^([\w-]+) (.*?) (.*)$/ {
          $key_type    = $1
          $key_key     = $2
          $key_comment = $3
        } else {
          fail('Malformed SSH public key')
        }
      } elsif is_hash($key) {
        $key_type    = $key['type']
        $key_key     = $key['key']
        $key_comment = has_key($key, 'comment') ? {
          true    => $key['comment'],
          default => undef,
        }
      } else {
        fail('Malformed authorized key entry')
      }

      ssh_authorized_key { "${name}_ssh_${key_type}_${key_comment}":
        user => $name,
        type => $key_type,
        key  => $key_key,
      }
    }
  } else {
    user { $name: ensure => absent, } ->
    group { $name: ensure => absent, }
  }
}
