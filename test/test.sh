#!/bin/sh

virtualenv_sh=$1


oneTimeSetUp()
{
    rm -rf workon_home
    mkdir workon_home

    WORKON_HOME=$PWD/workon_home

    . $virtualenv_sh 

    init_test_hooks
}


init_test_hooks()
{
    for hook in $(global_hooks); do
        echo "\$(( global_${hook}_count += 1 ))" > $WORKON_HOME/$hook
    done

    echo >> $WORKON_HOME/postmkvirtualenv
    for hook in $(local_hooks); do
        echo "local_${hook}_count=0" >> $WORKON_HOME/postmkvirtualenv
        echo "echo \$(( \${VIRTUAL_ENV##*/}_${hook}_count += 1 )) > \$VIRTUAL_ENV/bin/${hook}" >> $WORKON_HOME/postmkvirtualenv
    done
}


oneTimeTearDown()
{
    rm -rf workon_home
}


setUp()
{
    for hook in $(global_hooks); do
        echo "report_hook_invoked global ${hook}" > $WORKON_HOME/$hook
    done

    { echo
      for hook in $(local_hooks); do
          echo "echo report_hook_invoked \${env_name} ${hook} > \${WORKON_HOME}/\${env_name}/bin/${hook}"
      done
    } >> $WORKON_HOME/postmkvirtualenv

    invoked_hooks=
}


global_hooks()
{
    echo initialize
    echo premkvirtualenv postmkvirtualenv
    echo prermvirtualenv postrmvirtualenv
    echo preactivate postactivate
    echo predeactivate postdeactivate
}

local_hooks()
{
    echo preactivate postactivate
    echo predeactivate postdeactivate
}


report_hook_invoked()
{
    if [ -n "${invoked_hooks:-}" ]; then
        invoked_hooks="$invoked_hooks $1/$2"
    else
        invoked_hooks="$1/$2"
    fi
}

clear_hooks_invoked()
{
    unset invoked_hooks
}


assertHooksInvoked()
{
    assertEquals "Mismatch in invoked hooks" "$*" "$invoked_hooks"
}


#
# Test cases
#
test_initialized()
{
    assertTrue "[ -d $WORKON_HOME ]";
    assertEquals $(lsvirtualenvs) ""
}

test_one_virtualenv()
{
    mkvirtualenv test1 >/dev/null

    assertTrue "[ -e $WORKON_HOME/test1/bin/activate ]"
    assertEquals "test1 " "$(lsvirtualenvs | tr $'\n' ' ')"
    assertHooksInvoked global/premkvirtualenv global/postmkvirtualenv \
                       global/preactivate test1/preactivate \
                       global/postactivate test1/postactivate
}

test_two_virtualenvs()
{
    mkvirtualenv test1 >/dev/null
    clear_hooks_invoked
    mkvirtualenv test2 >/dev/null

    assertEquals "test1 test2 " "$(lsvirtualenvs | tr $'\n' ' ')"
    assertEquals "$VIRTUAL_ENV" "$WORKON_HOME/test2"
    assertHooksInvoked global/premkvirtualenv global/postmkvirtualenv \
                       test1/predeactivate global/predeactivate \
                       test1/postdeactivate global/postdeactivate \
                       global/preactivate test2/preactivate \
                       global/postactivate test2/postactivate
}


. ./shunit2
