The GAP 4 package "PackageManager"
==================================

[![Build Status](https://travis-ci.org/gap-packages/PackageManager.svg?branch=master)](https://travis-ci.org/gap-packages/PackageManager)
[![Code Coverage](https://codecov.io/github/gap-packages/PackageManager/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-packages/PackageManager)

A basic collection of simple functions for installing and removing GAP packages,
with the eventual aim of becoming a full pip-style package manager for the GAP
system.

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
