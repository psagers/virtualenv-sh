import subprocess

from distutils.command.build import build
from distutils.command.install import install
from distutils.core import setup


class VirtualenvSHBuild(build):
    def run(self):
        subprocess.call(['make'])


class VirtualenvSHInstall(install):
    def run(self):
        subprocess.call(['make', 'install'])


setup(
    name='virtualenv-sh',
    version='1.0',
    description='Convenient shell interface to virtualenv',
    long_description='''This is a leaner, faster derivative of virtualenvwrapper. the interface should be familiar to virtualenvwrapper users, minus the expensive parts. This project prioritizes speed avove all else.''',
    url='https://bitbucket.org/psagers/virtualenv-sh',
    author='Peter Sagerson',
    author_email='psagers.pypi@ignorare.net',
    license='BSD, Public Domain',
    packages=[],
    classifiers=[
        'Programming Language :: Unix Shell',
        'Operating System :: POSIX',
        'Intended Audience :: Developers',
        'License :: Public Domain',
    ],
    keywords=['virtualenv'],
    cmdclass={'build': VirtualenvSHBuild, 'install': VirtualenvSHInstall},
)
