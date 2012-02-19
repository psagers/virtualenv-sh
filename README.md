virtualenv-sh
=============

This project is a replacement for the venerable virtualenvwrapper (a set of
shell functions to facilitate the use of virtualenv
(<http://pypi.python.org/pypi/virtualenv>)). Like many, I've used
virtualenvwrapper for years, but it's gotten a bit heavy over time. I
eventually found myself waiting too long for new shells to start up, even
though I tended to use only the most basic virtualenvwrapper features.

This project is an attempt to solve the problem. I borrowed all of the clever
bits of virtualenvwrapper, discarded everything I considered expensive or just
not interesting, and added a feature or two of my own. The number one priority
of this project is speed. The code is almost pure shell script, although there
may be one or two invocations of standard tools like grep or sed.

Be warned that this implementation may not be for you. I may have gotten rid
of a feature that you liked, either because it was expensive or because I just
didn't care about it. I may have accidentally discarded a fix or workaround
for some environment that I haven't encountered. I may have just introduced
new bugs (shell is an easy language to get wrong in subtle ways). Proceed at
your own risk.


Installing
----------

This project keeps all of its functions in separate files so that individual
functions can have shell-specific implementations. The Makefile will wrap them
up into a usable monolithic shell script.

    make
    sudo make install

This will install all of the flavors to /usr/local/bin. There are currently
three flavors: sh, bash, and zsh. sh is the generic flavor that's meant to
work with pretty much any shell. The others have some shell-specific features,
such as completion.

To initialize virtualenv-sh, you'll need to add a line to your shell init file
(.bashrc, .zshrc, etc.). Choose one of the following, according to your shell
of choice:

    . /usr/local/bin/virtualenv-sh.sh
    . /usr/local/bin/virtualenv-sh.bash
    . /usr/local/bin/virtualenv-sh.zsh

If you'd rather not have these files installed globally, feel free to skip the
`sudo make install` step and manually copy the compiled files somewhere else.

If you're using zsh, you can also use the precompiled function archive for
optimal performance. You may want to refer to the section on function
autoloading in the zsh manual if you're not familiar with this process:

    # Configure all virtualenv-sh functions for autoloading
    typeset -U fpath
    fpath=(/usr/local/bin/virtualenv-sh $fpath)
    autoload -w /usr/local/bin/virtualenv-sh

    # Call the main initialization function
    virtualenv_sh_init

Nothing else is required. There's only one environment variable that you can
use for configuration, which is WORKON\_HOME. This is a path to your
collection of virutalenvs; you can leave it blank to accept the default of
${HOME}/.virtualenvs. It is assumed that `virtualenv` itself is in your path.


Using
-----

The basic commands of virtualenv-sh are essentially the same as
virtualenvwrapper. Here's a brief recap:

  * mkvirtualenv myenv

    Creates a new virtual\_env in $WORKON\_HOME. All arguments are passed
    directly to virtualenv. The new virtual\_env will become active. Unlike
    virtualenvwrapper, this takes no additional arguments.

  * rmvirtualenv myenv

    Deletes an existing virtual\_env. If this virtual\_env is currently active,
    it is deactivated first as a courtesy.

  * workon [virtual\_env]

    Activates the named virtual\_env. If another virtual\_env is currently
    active, it will be deactivated first. Without arguments, it will list the
    available virtual\_envs.

  * autoworkon

    Automatically sets the virtual\_env based on special files. See below.

  * deactivate

    Deactivates the current virtual\_env (as when using virtualenv directly).

  * lsvirtualenvs

    Prints a list of the virtual\_envs you've created.

  * cdvirtualenv [subdir]

    Changes the current directory to the root of the active virtual\_env, or a
    subdirectory thereof.

  * lssitepackages

    Lists the contents of the active virtual\_env's site-packages directory.

  * cdsitepackages [subdir]

    Changes the currect directory to the site-packages directory of the active
    virtual\_env, or a subdirectory thereof.


Hooks
-----

virtualenv-sh supports the same global and local (per-env) hooks as
virtualenvwrapper. Global hooks are files in $WORKON\_HOME; local hooks are
files in $WORKON\_HOME/\{virtual\_env\}/bin. Hooks are executed by
sourcing them in the current shell context.

  * initialize (global)

    Called at the end of virtualenv\_sh\_init.

  * premkvirtualenv, postmkvirtualv, prermvirtualenv, postmkvirtualenv (global)

    Called at the beginning and end of mkvirtualenv and rmvirtualenv.

  * preactivate, postactivate (global, local)
  * predeactivate, postdeactivate (local, global)

    Called in the order indicated around activation and deactivation of a
    virtual\_env.

In addition, virtualenv-sh allows you to dynamically register functions to be
called when executing hooks:

    virtualenv_sh_add_hook hook_name function_name
    virtualenv_sh_remove_hook hook_name function_name

e.g.:

    my_virtualenv_cleanup()
    {
        # Do some stuff here
    }

    virtualenv_sh_add_hook postdeactivate my_virtualenv_cleanup

Registered hook functions are always executed after all global and local hook
scripts.


autoworkon
----------

autoworkon is a new command that is designed to automatically update your
virtual\_env based on your current directory. Note that there is no standard
shell mechanism for running a function when the current directory changes--and
many shells don't have such a mechanism--so installing this is up to you. If
you're using zsh, you would use:

    autoload -U add-zsh-hook
    add-zsh-hook chpwd autoworkon

The autoworkon function will walk up the filesystem from the current directory
until it either reaches the root or finds an item named ".workon". If this is
a readable file, it will treat the first line as the name of a virtual\_env
and activate it. There are a couple of special rules to keep in mind:

  * autoworkon always stops at the first .workon it finds. It's perfectly
    reasonable to have .workon files at multiple points in a directory tree to
    use different virtual\_envs at different levels.

  * An empty or unreadable .workon file is interpreted as "no virtual\_env".
    This is useful if you want to deactivate the automatic virtual\_env in a
    particular subtree.

  * If you activate a virtual\_env manually, autoworkon will never override
    it. autoworkon will only change your active virtual\_env if it is unset or
    was previously set by autoworkon.
