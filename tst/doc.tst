# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true

# Bad package info
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage2.tar.gz");
#I  PackageInfo.g lacks Version field
false

# The big one: install semigroups, and mess with its dependencies
# TEMP: removed since semigroups now takes around 10 minutes to compile
# gap> InstallPackage("semigroups");
# true
# gap> dig := First(PackageInfo("digraphs"),
# >                 x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));;
# gap> PKGMAN_RemoveDir(Filename(Directory(dig.InstallationPath), "bin"));
# gap> UpdatePackage("semigroups");  # should recompile digraphs
# true
# gap> dig := First(PackageInfo("digraphs"),
# >                 x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));;
# gap> RemoveFile(Filename(Directory(dig.InstallationPath), "PackageInfo.g"));
# true
# gap> UpdatePackage("semigroups");  # recompiling doesn't work
# #I  Package already installed at target location
# #I  Dependencies not satisfied
# #I  Package availability test failed
# false
# gap> RemovePackage("semigroups", false);
# true
