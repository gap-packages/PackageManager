gap> LoadPackage("curlInterface", false);
true

# IO should be pre-installed for these tests to pass
gap> IsEmpty(PackageInfo("io"));
false

# RemovePackage failure
gap> RemovePackage(3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RemovePackage' on 1 arguments
gap> RemovePackage("xyz");
#I  Package "xyz" not installed in user package directory
false
gap> RemovePackage("PackageManager");
#I  Package "PackageManager" not installed in user package directory
false
gap> RemovePackage("PackageManager", true, false);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RemovePackage' on 3 arguments
gap> RemovePackage("PackageManager", "please default to yes");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RemovePackage' on 2 arguments

# Installing multiple versions
gap> InstallPackage("https://github.com/gap-packages/grpconst/releases/download/v2.6.4/grpconst-2.6.4.tar.gz");
true
gap> InstallPackage("https://github.com/gap-packages/grpconst/releases/download/v2.6.3/grpconst-2.6.3.tar.gz");
true
gap> RemovePackage("grpconst");
#I  Multiple versions of package grpconst installed
true

# InstallPackage input failure
gap> InstallPackage(3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 1 arguments
gap> InstallPackage("semigroups", 'y');
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 2 arguments
gap> InstallPackage("semigroups", "yes", "actually no");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 3 arguments
gap> InstallPackage("semigroups", ">=3.0", true, "i dont know");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 4 arguments
gap> InstallPackage("https://github.com/gap-packages/orb.git", "master", true);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 3 arguments
gap> InstallPackage("https://github.com/a/b.git", false, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 3 arguments
gap> InstallPackage("https://github.com/a/b.git", 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 2 arguments
gap> InstallPackage("https://github.com/a/b.git", true, "master", "lol");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `InstallPackage' on 4 arguments

# Check a bad package directory
gap> baddir := Filename(Directory(PKGMAN_PackageDir()), "badpkg");;
gap> CreateDir(baddir);;
gap> PKGMAN_CheckPackageBasic(baddir);
#I  Could not find PackageInfo.g file
false
gap> FileString(Filename(Directory(baddir), "PackageInfo.g"),
>               "SetPackageInfo(rec());");;
gap> PKGMAN_CheckPackageBasic(baddir);
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
