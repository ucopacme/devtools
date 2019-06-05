Role Name
=========

install dev tools on mac and linux

Requirements
------------

Mac OS X
run boot.sh script to install ansible/brew/xcode

Role Variables
--------------

A description of the settable variables for this role should go here, including
any variables that are in defaults/main.yml, vars/main.yml, and any variables
that can/should be set via parameters to the role. Any variables that are read
from other roles and/or the global scope (ie. hostvars, group vars, etc.) should
be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in
regards to parameters that may need to be set for other roles, or variables that
are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

    - hosts: all
      roles:
         - { role: devtools, x: 42 }

# howto create aws config

* create access keys for your iam user, and put them somewhere secure, eg
  ~/accessKeys.csv.  Create env variables for use with ansible:

```
eval `./aws-keys.sh ~/accessKeys.csv`
export mfa_serial=yourmfaserialarn
```

run playbook

```
ansible-playbook -i "localhost," -c local yourdevtoolplaybook.yaml "awscli-conf" -e "mfa_serial=$mfa_serial" -e "cli_key=$cli_key" -e "cli_secret=$cli_secret" -K
```

create an accounts file (Hint run this in the org master)

```
aws organizations list-accounts > ~/.aws/accounts.json
```

You may have to ask someone for a copy of accounts.json to bootstrap. We should
probably have this accounts.json file stored in central auth account. Or a way
to query it. Remember accounts can change within and org. Also what about rogue
accounts outside an org or multiple orgs.

License
-------

BSD

Author Information
------------------

eric.odell@ucop.edu
