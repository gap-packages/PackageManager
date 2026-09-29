# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true

# Bad package info
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage2.tar.gz");
#I  PackageInfo.g lacks Version field
false
