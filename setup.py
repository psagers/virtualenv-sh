from distutils.core import setup


setup(
    name='virtualenv-sh',
    version='0.1',
    description='Convenient shell interface to virtualenv',
    long_description=open('README').read(),
    url='https://bitbucket.org/psagers/virtualenv-sh',
    author='Peter Sagerson',
    author_email='psagers.pypi@ignorare.net',
    license='BSD, Public Domain',
    packages=[],
    scripts=[
        'scripts/virtualenv-sh.sh',
        'scripts/virtualenv-sh.bash',
        'scripts/virtualenv-sh.zsh',
    ],
    classifiers=[
        'Programming Language :: Unix Shell',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'License :: Public Domain',
    ],
    keywords=['virtualenv'],
)
