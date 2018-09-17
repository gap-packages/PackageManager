The GAP 4 package `PackageManager'
==================================

A basic collection of simple functions for installing and removing GAP packages,
with the eventual aim of becoming a full pip-style package manager for the GAP
language.

Example code:
```gap
gap> SetInfoLevel(InfoPackageManager, 2);
gap> InstallPackageURL("https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/mapclass-1.2.tar.gz");
```

Please take care when using the `RemovePackage` function.
