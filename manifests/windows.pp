define localuser::windows
(
  $ensure,
  $uid,
  $gid,
  $password,
  $groups,
  $comment,
  $home,
  $roles,
)
{
  include ::localuser::params

  user { $name:
    ensure   => $ensure,
    comment  => $comment,
    groups   => $groups,
    password => $password,
  }
}
