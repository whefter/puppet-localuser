define localuser::rsa_id
(
  $home,
  $user,
  $basename           = 'id_rsa',
  $publickey_source   = undef,
  $publickey_content  = undef,
  $privatekey_source  = undef,
  $privatekey_content = undef,
)
{
  if !$publickey_source and !$publickey_content {
    fail('Either "source" or "content" must be provided for public key.')
  }

  if !$privatekey_source and !$privatekey_content {
    fail('Either "source" or "content" must be provided for private key.')
  }

  $user_ssh_confdir_path = "${home}/.ssh"

  if !defined(File[$user_ssh_confdir_path]) {
    file { $user_ssh_confdir_path:
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0700',
      require => [User[$user],]
    }
  }

  file { "${user_ssh_confdir_path}/${basename}":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0600',
    content => $privatekey_content,
    source  => $privatekey_source,
    require => [
      File[$user_ssh_confdir_path],
      User[$name],
    ],
  }

  file { "${user_ssh_confdir_path}/${basename}.pub":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => $publickey_content,
    source  => $publickey_source,
    require => [
      File[$user_ssh_confdir_path],
      User[$name],
    ],
  }
}
