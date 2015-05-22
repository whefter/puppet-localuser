define localuser::windows (
  $ensure,
  $uid,
  $gid,
  $password,
  $groups,
  $comment,
  $home,
  $roles,) {
  user { $name:
    ensure   => $ensure,
    comment  => $comment,
    groups   => $groups,
    password => $password,
  }
}
