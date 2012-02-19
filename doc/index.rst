=============
virtualenv-sh
=============

This project is my personal substitute for the venerable `virtualenvwrapper
<http://pypi.python.org/pypi/virtualenvwrapper>`_ (a set of shell functions to
facilitate the use of `virtualenv <http://pypi.python.org/pypi/virtualenv>`_).
Like many, I've used virtualenvwrapper for years, but it's gotten a bit heavy
over time. I eventually found myself waiting too long for new shells to start
up, even though I tended to use only the basic features.

This project is an attempt to solve that problem. I borrowed the clever bits
of virtualenvwrapper, discarded everything I considered expensive or just not
interesting, and added a feature or two of my own. The number one priority of
this project is speed. The code is almost pure shell script, although there
may be one or two invocations of standard tools like grep or sed.

Be warned that this implementation may not be for you. I may have gotten rid
of a feature that you liked, either because it was expensive or because I just
didn't care about it. I may have accidentally discarded a fix or workaround
for some environment that I haven't encountered. I may have just introduced
new bugs (shell is an easy language to get wrong in subtle ways). Proceed at
your own risk.


Installing
==========

virtualenv-sh can be installed with pip or easy_install. To use it, you need
to source a single shell script in your shell environment. By default, pip or
easy_install should install it to /usr/local/bin. If you're using bash or zsh,
you should import the shell-specific script; otherwise, you can try the
generic one. Add *one* of the following to your shell's init script (.bashrc,
.zshrc, etc.)::

    . /usr/local/bin/virtualenv-sh.bash

::

    . /usr/local/bin/virtualenv-sh.zsh

::

    . /usr/local/bin/virtualenv-sh.sh

Nothing else is required. There's only one environment variable that you can
use for configuration, which is WORKON_HOME. This is a path to your collection
of virutalenvs; you can leave it blank to accept the default of
``${HOME}/.virtualenvs``. It is assumed that ``virtualenv`` itself is in your
path.

::

    WORKON_HOME=${HOME}/.virtualenvs


zsh
---

If you're using zsh, you can instead use the precompiled function archive for
optimal performance, although this needs to be compiled from source on your
machine. You can download the source directly or try::

    > pip install --upgrade --no-install virtualenv-sh
    > cd build/virtualenv-sh
    > sudo make install

This will find zsh in your path, use it to compile virtualenv-sh.zwc, and
install it to /usr/local/bin. You can now autoload these functions and
initialize virtualenv-sh. You may want to refer to the section on function
autoloading in the zsh manual if you're not familiar with this process::

    # Configure all virtualenv-sh functions for autoloading
    fpath=(/usr/local/bin/virtualenv-sh $fpath)
    autoload -w /usr/local/bin/virtualenv-sh

    # Call the main initialization function
    virtualenv_sh_init


Using
=====

The basic commands of virtualenv-sh are essentially the same as
virtualenvwrapper. Here's a brief recap:

  ``mkvirtualenv <env_name>``

    Creates a new virtual_env in ``$WORKON_HOME``. All arguments are passed
    directly to ``virtualenv``. The new virtual_env will become active. Unlike
    virtualenvwrapper, this takes no additional arguments.

  ``rmvirtualenv <env_name>``

    Deletes an existing virtual_env. If this virtual_env is currently active,
    it is deactivated first as a courtesy.

  ``workon [<env_name>]``

    Activates the named virtual_env. If another virtual_env is currently
    active, it will be deactivated first. Without arguments, it will list the
    available virtual_envs.

  ``autoworkon``

    Automatically sets the virtual_env based on special files. See below.

  ``deactivate``

    Deactivates the current virtual_env (as when using ``virtualenv``
    directly).

  ``lsvirtualenvs``

    Prints a list of the virtual_envs you've created.

  ``cdvirtualenv [subdir]``

    Changes the current directory to the root of the active virtual_env, or a
    subdirectory thereof.

  ``lssitepackages``

    Lists the contents of the active virtual_env's site-packages directory.

  ``cdsitepackages [subdir]``

    Changes the currect directory to the site-packages directory of the active
    virtual_env, or a subdirectory thereof.


Hooks
=====

virtualenv-sh supports the same global and local (per-env) hooks as
virtualenvwrapper. Global hooks are files in $WORKON_HOME; local hooks are
files in $WORKON_HOME/\{virtual_env\}/bin. Hooks are executed by sourcing them
in the current shell context.

  initialize (global)

    Called at the end of virtualenv_sh_init.

  premkvirtualenv, postmkvirtualv, prermvirtualenv, postmkvirtualenv (global)

    Called at the beginning and end of mkvirtualenv and rmvirtualenv.

  preactivate, postactivate (global, local); predeactivate, postdeactivate (local, global)

    Called in the order indicated around activation and deactivation of a
    virtual_env.

In addition, virtualenv-sh allows you to dynamically register functions to be
called when executing hooks::

    virtualenv_sh_add_hook <hook_name> <function_name>
    virtualenv_sh_remove_hook <hook_name> <function_name>

e.g.::

    my_virtualenv_cleanup()
    {
        # Do some stuff here
    }

    virtualenv_sh_add_hook postdeactivate my_virtualenv_cleanup

Registered hook functions are always executed after all global and local hook
scripts.


autoworkon
==========

autoworkon is a new command that is designed to automatically update your
virtual_env based on your current directory. Note that there is no standard
shell mechanism for running a function when the current directory changes--and
many shells don't have such a mechanism--so installing this is up to you. If
you're using zsh, you would use::

    autoload -U add-zsh-hook
    add-zsh-hook chpwd autoworkon

The autoworkon function will walk up the filesystem from the current directory
until it either reaches the root or finds an item named ".workon". If this is
a readable file, it will treat the first line as the name of a virtual_env and
activate it. There are a couple of special rules to keep in mind:

  * autoworkon always stops at the first .workon it finds. It's perfectly
    reasonable to have .workon files at multiple points in a directory tree to
    use different virtual_envs at different levels.

  * An empty or unreadable .workon file is interpreted as "no virtual_env".
    This is useful if you want to deactivate the automatic virtual_env in a
    particular subtree.

  * If you activate a virtual_env manually, autoworkon will never override it.
    autoworkon will only change your active virtual_env if it is unset or was
    previously set by autoworkon.
