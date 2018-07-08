**This module is not maintained anymore since I've found Ansible to be much, much easier to use than Puppet.**

# localuser #

Requires `parser=future` or Puppet 4 (untested).

## `ssh_rsa_ids` structure ##

    $ssh_rsa_ids = [
        {
            keyname             => 'some_key_name', 
            # Defaults to id_rsa if unspecified
            basename            => 'id_rsa2',
            public_key_content  => 'ssh-rsa AAAAB3NzaC1y...',
            public_key_source   => 'puppet://...',
            private_key_content => "-----BEGIN RSA PRIVATE KEY-----....",
            private_key_source  => 'puppet://...',
        }
    ]
    
## `ssh_authorized_keys` structure ##

    $ssh_authorized_keys = [
        # Either in one full string
        'ssh-rsa AAAAB3NzaC1y...',
        # Or as hash specifying the parts required by ssh_authorized_key
        {
            type    => 'ssh-rsa',
            key     => 'AAAAB3NzaC1y...',
            # Optional
            comment => 'user@fqdn',
        }
    ]
