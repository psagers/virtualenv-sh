test_single_virtualenv()
{
    mkvirtualenv test1 > /dev/null

    assertTrue "[ -e $WORKON_HOME/test1/bin/activate ]"
    assertEquals $(lsvirtualenvs) "test1"
}
suite_addTest test_single_virtualenv
