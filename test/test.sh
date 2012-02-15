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
    invoked_hooks="${invoked_hooks} $1/$2"
}


assertHooksInvoked()
{
    assertEquals "Mismatch in invoked hooks" "$*" "$invoked_hooks"
}


suite()
{
    for testcase in testcases/*; do
        . $testcase
    done
}


. ./shunit2
