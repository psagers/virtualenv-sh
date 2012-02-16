#!/bin/sh

virtualenv_sh=$1


oneTimeSetUp()
{
    rm -rf workon_home
    mkdir workon_home

    WORKON_HOME=$PWD/workon_home

    . $virtualenv_sh 

    for hook in $(global_hooks); do
        echo "report_hook_invoked global ${hook}" > $WORKON_HOME/$hook
    done

    { echo
      for hook in $(local_hooks); do
          echo "echo report_hook_invoked \${env_name} ${hook} > \${WORKON_HOME}/\${env_name}/bin/${hook}"
      done
    } >> $WORKON_HOME/postmkvirtualenv
}


oneTimeTearDown()
{
    rm -rf workon_home
}


tearDown()
{
    clear_hooks_invoked
    clear_custom_hooks_invoked
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
    assertEquals "Mismatch in invoked hooks" "$*" "${invoked_hooks:-}"
}


report_hook_func_invoked()
{
    if [ -n "${invoked_hook_funcs:-}" ]; then
        invoked_hook_funcs="$invoked_hook_funcs $1"
    else
        invoked_hook_funcs="$1"
    fi
}

clear_custom_hooks_invoked()
{
    unset invoked_hook_funcs
}

assertHookFuncsInvoked()
{
    assertEquals "Mismatch in invoked hook funcs" "$*" "$invoked_hook_funcs"
}


custom_hook_1()
{
    report_hook_func_invoked custom_hook_1
}

custom_hook_2()
{
    report_hook_func_invoked custom_hook_2
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

test_add_hook()
{
    virtualenv_sh_add_hook preactivate custom_hook_1

    assertEquals "preactivate/custom_hook_1" ${_virtualenv_sh_hook_functions% }
}

test_remove_hook()
{
    virtualenv_sh_add_hook preactivate custom_hook_1
    virtualenv_sh_remove_hook preactivate custom_hook_1

    assertEquals "" "${_virtualenv_sh_hook_functions}"
}

test_remove_hook_empty()
{
    virtualenv_sh_remove_hook preactivate custom_hook_1

    assertEquals "" "${_virtualenv_sh_hook_functions}"
}

test_duplicate_hook()
{
    virtualenv_sh_add_hook preactivate custom_hook_1
    virtualenv_sh_add_hook preactivate custom_hook_1

    assertEquals "preactivate/custom_hook_1" "$(echo $_virtualenv_sh_hook_functions)"
}

test_two_hooks()
{
    virtualenv_sh_add_hook preactivate custom_hook_1
    virtualenv_sh_add_hook preactivate custom_hook_2

    assertEquals "preactivate/custom_hook_1 preactivate/custom_hook_2" "$(echo $_virtualenv_sh_hook_functions)"
}

test_two_minus_one_hooks()
{
    virtualenv_sh_add_hook preactivate custom_hook_1
    virtualenv_sh_add_hook preactivate custom_hook_2
    virtualenv_sh_remove_hook preactivate custom_hook_1

    assertEquals "preactivate/custom_hook_2" "$(echo $_virtualenv_sh_hook_functions)"
}

test_run_hook()
{
    virtualenv_sh_add_hook preactivate custom_hook_1
    virtualenv_sh_add_hook postactivate custom_hook_2
    virtualenv_sh_run_hook_functions postactivate

    assertHookFuncsInvoked "custom_hook_2"
}


. ./shunit2
