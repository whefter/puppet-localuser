define localuser::rsa_id
(
  $home,
  $user,
  $basename            = 'id_rsa',
  $public_key_source   = undef,
  $public_key_content  = undef,
  $private_key_source  = undef,
  $private_key_content = undef,
)
{
  include ::localuser::params

  if !$home {
    fail("A home directory must be provided to deploy RSA ID ${name} for user ${user}.")
  }

  if !$public_key_source and !$public_key_content {
    fail('Either "source" or "content" must be provided for public key.')
  }

  if !$private_key_source and !$private_key_content {
    fail('Either "source" or "content" must be provided for private key.')
  }

  $user_ssh_confdir_path = "${home}/.ssh"

  if !defined(File[$user_ssh_confdir_path]) {
    file { $user_ssh_confdir_path:
      ensure  => directory,
      owner   => $user,
      group   => $user,
      mode    => '0700',
      require => [
        User[$user],
      ]
    }
  }

  file { "${user_ssh_confdir_path}/${basename}":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0600',
    content => $private_key_content,
    source  => $private_key_source,
    require => [
      File[$user_ssh_confdir_path],
      User[$user],
    ],
  }

  file { "${user_ssh_confdir_path}/${basename}.pub":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => $public_key_content,
    source  => $public_key_source,
    require => [
      File[$user_ssh_confdir_path],
      User[$user],
    ],
  }
}
