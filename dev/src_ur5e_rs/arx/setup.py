
from setuptools import setup

setup(
  name='dlo_dset',
  version='0.1',
  description='A dynamic DLO dataset',
  author='Bardia Mojra',
  author_email='bardia.mojra@mavs.uta.edu',
  packages=['dlo_dset'],
  install_requires=[
      'numpy',
      'pandas',
  ],
)
