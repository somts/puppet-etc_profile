# etc_profile

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with etc_profile](#setup)
    * [What etc_profile affects](#what-etc_profile-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with etc_profile](#beginning-with-etc_profile)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module sets up `/etc/profile.d` for Bourne/Bourne Again shell and
the logical equivalents in C-shell and Z-shell. The intention is to
make it easy for other Puppet file resources/packages/system admins to
customize the respective shell environments without having to touch
the main system-wide file(s).

sh/bash and csh/tcsh vary widely on how they are set up across OSes.
EG, on RedHat-style OSes, `/etc/profile.d` contains `*.sh` files
alongside `*.csh`. On other OSes, CSH `.d` directories either do not
exist or live in a location separate from where Bourne shell files live.

Some OSes do not ship with/install the logical equivalent of searching
for `/etc/profile.d/*.sh`, `/etc/profile.d/*.csh` or `*.zsh` files, but
some do. We consistently want those `.d`-style directories, so this
module changes what needs to be changed per OS and shell to set that up

## Setup

### What etc_profile affects

Based on the OS, Puppet may manage a single line of the complete
contents of files system-wide files for `/bin/sh`/`/bin/bash`,
`/bin/csh`/`/bin/tcsh` and `/bin/zsh`.

#### Bourne (Again) Shell
Note the `/etc` path will be different on OSes such as
FreeBSD (`/usr/local/etc`) and Darwin (`/private/etc`).

* `/etc/profile` when needed
* `/etc/profile.d`

#### C Shell
All supported OSes store system-wide C Shell files in `/etc`, save
Darwin (`/private/etc`), but whether or not the OS is set up to search
for `.d` directories varies widely.

* `/etc/csh.cshrc` when needed
* `/etc/csh.login` when needed
* `/etc/csh.logout` when needed
* `/etc/profile.d` or logical equivalent where `*.csh` files can live (EG `/etc/csh/login.d` and `/etc/csh/cshrc.d` on Debian)

#### Z Shell
Note the `/etc` path will be different on OSes such as
FreeBSD (`/usr/local/etc`) and Darwin (`/private/etc`).

Since FreeBSD/Linux do not ship with *zsh*, there is less historical
variance to overcome and less dependence on system setup for this shell.
As such, we take a less nuanced approach when setting up this shell. We
ensure these files exist:

* `/etc/zshenv` or logical equivalent
* `/etc/zprofile` or logical equivalent
* `/etc/zshrc` or logical equivalent
* `/etc/zlogin` or logical equivalent
* `/etc/zlogout` or logical equivalent

...and these directories exist, which do not come standard with zsh:
* `/etc/zsh/zshenv.d` or logical equivalent
* `/etc/zsh/zprofile.d` or logical equivalent
* `/etc/zsh/zshrc.d` or logical equivalent
* `/etc/zsh/zlogin.d` or logical equivalent
* `/etc/zsh/zlogout.d` or logical equivalent

...and finally, we insert a line in `/etc/zshenv`, `/etc/zprofile`,
`/etc/zshrc`, `/etc/zlogin` and `/etc/zlogout` (or logical equivalent)
that ensures that zsh will look for `*.zsh` files in the respective `.d`
directory, similar to Bourne shell.

### Setup Requirements **OPTIONAL**

None, yet.

### Beginning with etc_profile

## Usage

```puppet
contain 'etc_profile'
```

## Reference

Parameters described in `init.pp`.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there
are Known Issues, you might want to include them under their own heading here.

## Development

This is an in-house module for a production environment. Pull requests
will be considered, but no promises.

## Release Notes/Contributors/Etc. **Optional**

See CHANGELOG
