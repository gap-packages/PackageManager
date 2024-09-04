gap> LoadPackage("curlInterface", false);
true

# IO should be pre-installed for these tests to pass
gap> IsEmpty(PackageInfo("io"));
false

# UpdatePackage for non-user packages
gap> UpdatePackage("GAPDoc", false);
#I  Package "gapdoc" not installed in user package directory
false

# Install a package from a PackageInfo.g URL (includes redirect)
gap> InstallPackage("https://gap-packages.github.io/autpgrp/PackageInfo.g");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "autpgrp"));
true
gap> RemovePackage("autpgrp", false);
true

# RemovePackage failure
gap> RemovePackage(3);
Error, PackageManager: RemovePackage: <name> must be a string
gap> RemovePackage("xyz");
#I  Package "xyz" not installed in user package directory
false
gap> RemovePackage("PackageManager");
#I  Package "PackageManager" not installed in user package directory
false
gap> RemovePackage("PackageManager", true, false);
Error, PackageManager: RemovePackage: requires 1 or 2 arguments (not 3)
gap> RemovePackage("PackageManager", "please default to yes");
Error, PackageManager: RemovePackage: <interactive> must be true or false

# UpdatePackage bad inputs
gap> UpdatePackage(3);
Error, PackageManager: UpdatePackage: <name> must be a string
gap> UpdatePackage("io", "yes");
Error, PackageManager: UpdatePackage: <interactive> must be true or false
gap> UpdatePackage("io", true, "master", "hello", Group(()), fail, []);
Error, PackageManager: UpdatePackage: requires 1 or 2 arguments (not 7)

# Installing multiple versions
gap> InstallPackage("https://github.com/gap-packages/grpconst/releases/download/v2.6.4/grpconst-2.6.4.tar.gz");
true
gap> InstallPackage("https://github.com/gap-packages/grpconst/releases/download/v2.6.3/grpconst-2.6.3.tar.gz");
true
gap> RemovePackage("grpconst");
#I  Multiple versions of package grpconst installed
false

# InstallPackage input failure
gap> InstallPackage(3);
Error, PackageManager: InstallPackage: <string> must be a string
gap> InstallPackage("semigroups", 'y');
Error, PackageManager: InstallPackage:
2nd argument must be true or false or a version string
gap> InstallPackage("semigroups", "yes", "actually no");
Error, PackageManager: InstallPackageFromName:
if specified, <interactive> must be true or false
gap> InstallPackage("semigroups", ">=3.0", true, "i dont know");
Error, PackageManager: InstallPackage: requires 1 to 3 arguments (not 4)

# InstallPackageFromInfo input failure
gap> InstallPackageFromInfo(42);
Error, PackageManager: InstallPackageFromInfo: <info> should be a rec or URL

# InstallPackageFromInfo failure
gap> InstallPackage("http://www.nothing.rubbish/PackageInfo.g");
#I  Unable to download from http://www.nothing.rubbish/PackageInfo.g
false

# Check a bad package directory
gap> baddir := Filename(Directory(PKGMAN_PackageDir()), "badpkg");;
gap> CreateDir(baddir);;
gap> PKGMAN_CheckPackage(baddir);
#I  Could not find PackageInfo.g file
false
gap> FileString(Filename(Directory(baddir), "PackageInfo.g"),
>               "SetPackageInfo(rec());");;
gap> PKGMAN_CheckPackage(baddir);
#I  PackageInfo.g lacks PackageName field
false
gap> RemoveDirectoryRecursively(baddir);;

# PKGMAN_Exec failure
gap> PKGMAN_Exec(".", 3);
Error, <cmd> should be a string
gap> PKGMAN_Exec(".", "xyzabc");
fail

# FINAL TEST
# (keep this at the end of the file)
gap> PKGMAN_SetCustomPackageDir(Filename(DirectoryTemporary(), "pkg/"));
