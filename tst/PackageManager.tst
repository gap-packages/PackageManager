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

# Install a package from a .tar.gz archive
gap> InstallPackage("https://github.com/gap-packages/example/releases/download/v4.2.1/Example-4.2.1.tar.gz");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(LowercaseString(f), "example"));
true
gap> RemovePackage("example", false);
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

# InstallPackageFromArchive failure
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/bad-tarball.tar.gz");
#I  Could not inspect tarball contents
false
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/twodirs.tar.gz");
#I  Archive should contain 1 directory (not 2)
false
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage.tar.gz");
#I  PackageInfo.g lacks PackageName field
false

# Fail to extract due to permissions
gap> dir := Filename(Directory(PKGMAN_PackageDir()), "badpackage");;
gap> CreateDir(dir);
true
gap> PKGMAN_Exec(".", "chmod", "000", dir);
rec( code := 0, output := "" )
gap> PKGMAN_CreateDirRecursively(Filename(Directory(dir), "subfolder"));
#I  Failed to create required directory
fail
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage.tar.gz");
#I  Target location not writable
false
gap> PKGMAN_Exec(".", "chmod", "222", dir);
rec( code := 0, output := "" )
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage.tar.gz");
#I  Target location not readable
false
gap> PKGMAN_Exec(".", "chmod", "777", dir);
rec( code := 0, output := "" )

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

# PKGMAN_CustomPackageDir
gap> olddir := PKGMAN_CustomPackageDir;;
gap> PKGMAN_CustomPackageDir := "";;
gap> EndsWith(PKGMAN_PackageDir(), "/.gap/pkg");
true
gap> PKGMAN_CustomPackageDir := olddir;;
gap> PKGMAN_SetCustomPackageDir("/home");  # not ending in pkg
fail
gap> PKGMAN_InsertPackageDirectory("/home");  # not ending in pkg
fail

# Install to existing empty directory
gap> CreateDir(Filename(Directory(PKGMAN_PackageDir()), "Toric-1.9.5"));
true
gap> InstallPackage("https://github.com/gap-packages/toric/releases/download/v1.9.5/Toric-1.9.5.tar.gz");
true

# Updating old package that doesn't have the version number in its directory name
gap> InstallPackage("https://www.math.colostate.edu/~hulpke/transgrp/transgrp3.6.4.tar.gz");
true
gap> oldinfo := First(PackageInfo("transgrp"), x -> x.Version = "3.6.4");;
gap> oldinfo <> fail;
true
gap> PositionSublist(oldinfo.InstallationPath, "3.6.4");  # version number not in dir name
fail
gap> UpdatePackage("transgrp", false);
#I  Package already installed at target location
#I  Appending '.old' to old version directory
true
gap> newinfo := PackageInfo("transgrp")[1];;
gap> CompareVersionNumbers(newinfo.Version, ">=3.6.5");
true

# FINAL TEST
# (keep this at the end of the file)
gap> PKGMAN_SetCustomPackageDir(Filename(DirectoryTemporary(), "pkg/"));
