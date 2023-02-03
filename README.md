The GAP 4 package "PackageManager"
==================================

[![Build Status](https://github.com/gap-packages/PackageManager/workflows/CI/badge.svg?branch=master)](https://github.com/gap-packages/PackageManager/actions?query=workflow%3ACI+branch%3Amaster)
[![Code Coverage](https://codecov.io/github/gap-packages/PackageManager/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-packages/PackageManager)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gap-packages/PackageManager/master?filepath=PackageManager-demo.ipynb)

A basic collection of simple functions for installing and removing GAP packages,
with the eventual aim of becoming a full package manager for the GAP system.

Example invocations:

    gap> LoadPackage("PackageManager");

    gap> InstallPackage("digraphs");

    gap> InstallPackage("https://github.com/gap-packages/Semigroups.git");

    gap> InstallPackage("https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/mapclass-1.2.tar.gz");

    gap> RemovePackage("semigroups");

By default, verbose information about a command's progress is printed to the
screen.  To see less of this information, try using:

    gap> SetInfoLevel(InfoPackageManager, 1);

For more information on the features of PackageManager, see the documentation at
https://gap-packages.github.io/PackageManager/doc/chap1.html
or enter GAP and call, for example,

    gap> ?InstallPackage

Installing and configuring GAP using PackageManager
---------------------------------------------------
It should be possible to install GAP from source, and install all required
packages, using nothing but GAP and PackageManager.  The following instructions
attempt to install GAP in your home directory `~`, with the package manager in a
`~/.gap/pkg` directory.  This should work on a Debian/Ubuntu machine, but might
need some alterations on a Mac.

First, make sure you've got the required dependencies for GAP installed on your
computer.  On a Debian/Ubuntu machine you can get the required software using:
```bash
sudo apt install autoconf build-essential curl git graphviz libtool libgmp-dev texlive-full
```

On a Mac, you can get the required software by installing Homebrew, and running:
```bash
brew install git autoconf automake curl GMP graphviz libtool
```

Now, to install GAP and PackageManager, open a terminal window and enter the following:
```bash
cd ~
git clone git@github.com:gap-system/gap.git
cd gap
./autogen.sh
./configure
make
cd ~/
mkdir .gap
cd .gap
mkdir pkg
cd pkg
git clone git@github.com:gap-packages/PackageManager.git
cd ~/gap
./gap --bare
```

In the GAP window that opens, enter the following:
```gap
LoadPackage("PackageManager");
InstallRequiredPackages();
quit;
```

Now compile the documentation using:
```bash
make doc
```

You should now be able to load GAP with `./gap` and everything should work
normally.  Further required packages can be installed with `InstallPackage` when
you need them.

Citing
------
Please cite this package using the following format:

[YouXX]
M. Young,
PackageManager (GAP package),
Easily download and install GAP packages,
Version X.Y.Z (20XX),
https://github.com/gap-packages/PackageManager.

Acknowledgements
----------------

<table class="none">
<tr>
<td>
  <img src="https://opendreamkit.org/public/logos/odk-elected-logo.svg" width="128">
</td>
<td>
  PackageManager was partly created with funding from the OpenDreamKit project: https://opendreamkit.org
</td>
</tr>
<tr>
<td>
  <img src="http://opendreamkit.org/public/logos/Flag_of_Europe.svg" width="128">
</td>
<td>
  This infrastructure is part of a project that has received funding from the
  European Union's Horizon 2020 research and innovation programme under grant
  agreement No 676541.
</td>
</tr>
</table>
