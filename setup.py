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
    version='0.1',
    description='Convenient shell interface to virtualenv',
    long_description=open('README').read(),
    url='https://bitbucket.org/psagers/virtualenv-sh',
    author='Peter Sagerson',
    author_email='psagers.pypi@ignorare.net',
    license='BSD, Public Domain',
    packages=[],
    classifiers=[
        'Programming Language :: Unix Shell',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'License :: Public Domain',
    ],
    keywords=['virtualenv'],
    cmdclass={'build': VirtualenvSHBuild, 'install': VirtualenvSHInstall},
)
