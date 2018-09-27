The GAP 4 package "PackageManager"
==================================

[![Build Status](https://travis-ci.org/gap-packages/PackageManager.svg?branch=master)](https://travis-ci.org/gap-packages/PackageManager)
[![Code Coverage](https://codecov.io/github/gap-packages/PackageManager/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-packages/PackageManager)

A basic collection of simple functions for installing and removing GAP packages,
with the eventual aim of becoming a full pip-style package manager for the GAP
language.

Example invocations:

    gap> InstallPackage("digraphs");

    gap> InstallPackage("https://github.com/gap-packages/Semigroups.git");

    gap> InstallPackage("https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/mapclass-1.2.tar.gz");

    gap> RemovePackage("semigroups");

By default, very little information is printed to the screen.  To see more
verbose information, try using:

    gap> SetInfoLevel(InfoPackageManager, 3);
