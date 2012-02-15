test_initialized()
{
    assertTrue "[ -d $WORKON_HOME ]";
}
suite_addTest test_initialized


test_no_virtualenvs()
{
    assertEquals $(lsvirtualenvs) ""
}
suite_addTest test_no_virtualenvs
