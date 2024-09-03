gap> LoadPackage("curlInterface", false);
true

# IO should be pre-installed for these tests to pass
gap> IsEmpty(PackageInfo("io"));
false

# UpdatePackage for non-user packages
gap> UpdatePackage("GAPDoc", false);
#I  Package "gapdoc" not installed in user package directory
false

# Install GAP's required packages
gap> conts := DirectoryContents(PKGMAN_PackageDir());;
gap> ForAny(conts, f -> StartsWith(f, "primgrp"));
false
gap> ForAny(conts, f -> StartsWith(f, "SmallGrp"));
false
gap> ForAny(conts, f -> StartsWith(f, "transgrp"));
false
gap> ForAny(conts, f -> StartsWith(f, "GAPDoc"));
false
gap> InstallRequiredPackages();
true
gap> conts := DirectoryContents(PKGMAN_PackageDir());;
gap> ForAny(conts, f -> StartsWith(f, "primgrp"));
true
gap> ForAny(conts, f -> StartsWith(f, "SmallGrp"));
true
gap> ForAny(conts, f -> StartsWith(f, "transgrp"));
true
gap> ForAny(conts, f -> StartsWith(f, "GAPDoc"));
true
gap> RemovePackage("primgrp", false);
true
gap> RemovePackage("SmallGrp", false);
true
gap> RemovePackage("transgrp", false);
true
gap> RemovePackage("GAPDoc", false);
true

# Install and remove a package by name
gap> InstallPackage("format");
true
gap> InstallPackage("format");
true
gap> UpdatePackage("format");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "format"));
true
gap> RemovePackage("format", false);
true
gap> RemovePackage("format");
#I  Package "format" not installed in user package directory
false

# Install using a required package number
gap> InstallPackage("format", ">=0.5");
true
gap> RemovePackage("format", false);
true
gap> InstallPackage("format", "0.5", false);
true
gap> RemovePackage("format", false);
true

# Required package number too high
gap> InstallPackage("format", "9999.0");
#I  Version "9999.0" of package "FORMAT" cannot be satisfied
false

# Fail to install a GAP required package
gap> backup := GAPInfo.Dependencies.NeededOtherPackages;;
gap> needed := ShallowCopy(backup);;
gap> Add(needed, ["packagethatgaptotallyneeds", ">= 2.0"], 1);
gap> GAPInfo.Dependencies := rec(NeededOtherPackages := needed);;
gap> InstallRequiredPackages();
#I  Package "packagethatgaptotallyneeds" not found in package list
false
gap> GAPInfo.Dependencies := rec(NeededOtherPackages := backup);;

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

# GetPackageURLs failure
gap> default_url := PKGMAN_PackageInfoURLList;;
gap> PKGMAN_PackageInfoURLList := "http://www.nothing.rubbish/abc.txt";;
gap> GetPackageURLs();
#I  PackageManager: GetPackageURLs: could not contact server
rec( success := false )
gap> PKGMAN_PackageInfoURLList := "https://www.gap-system.org";;
gap> GetPackageURLs();
#I  PackageManager: GetPackageURLs: bad line:
#I  <!DOCTYPE html> <html lang="en-US"> <head> <meta charset="UTF-8"> <meta...
rec( success := false )
gap> PKGMAN_PackageInfoURLList := default_url;;

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

# InstallPackageFromName failure
gap> InstallPackage("sillypackage");
#I  Package "sillypackage" not found in package list
false

# InstallPackageFromInfo input failure
gap> InstallPackageFromInfo(42);
Error, PackageManager: InstallPackageFromInfo: <info> should be a rec or URL

# InstallPackageFromInfo failure (Remove #E messages after they leave GAP)
gap> InstallPackage("http://www.nothing.rubbish/PackageInfo.g");
#I  Unable to download from http://www.nothing.rubbish/PackageInfo.g
false

# TODO: package that doesn't offer a ".tar.gz" archive
# I'm not sure any such packages currently exist.
#gap> InstallPackage("nilmat");
##I  No supported archive formats available, so could not install
##I  Only [ ".zip" ] available
#false

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

# Check a bad package directory (Remove #E messages after they leave GAP)
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

# Missing curlInterface: use wget instead
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> InstallPackage("https://gap-packages.github.io/Memoisation/PackageInfo.g");
true
gap> RemovePackage("Memoisation", false);
true
gap> PKGMAN_CurlIntReqVer := ver;;

# wget failure
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false
gap> PKGMAN_CurlIntReqVer := ver;;

# Missing curlInterface: use curl instead
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> tmp := PKGMAN_DownloadCmds[1];;
gap> PKGMAN_DownloadCmds[1] := PKGMAN_DownloadCmds[2];;
gap> PKGMAN_DownloadCmds[2] := tmp;;
gap> PKGMAN_DownloadCmds[1][1];
"curl"
gap> InstallPackage("uuid");
true
gap> RemovePackage("uuid", false);
true
gap> PKGMAN_CurlIntReqVer := ver;;

# Install to existing empty directory
gap> CreateDir(Filename(Directory(PKGMAN_PackageDir()), "Toric-1.9.5"));
true
gap> InstallPackage("https://github.com/gap-packages/toric/releases/download/v1.9.5/Toric-1.9.5.tar.gz");
true

# curl failure
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> PKGMAN_DownloadCmds[1][1];
"curl"
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false
gap> PKGMAN_CurlIntReqVer := ver;;

# Missing first command
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> PKGMAN_DownloadCmds[1][1] := "abababaxyz";;
gap> InstallPackage("crypting");
true
gap> PKGMAN_CurlIntReqVer := ver;;

# Installing dependencies
gap> old_paths := GAPInfo.RootPaths;;
gap> dir := PKGMAN_PackageDir();;
gap> dir := SplitString(dir, "/");;
gap> Remove(dir) = "pkg";
true
gap> dir := JoinStringsWithSeparator(dir, "/");;
gap> dir := Concatenation(dir, "/");;
gap> GAPInfo.RootPaths := Immutable([dir]);;
gap> GAPInfo.DirectoriesLibrary := AtomicRecord(rec());;
gap> if IsBound(GAPInfo.PackagesInfoInitialized) and
>   GAPInfo.PackagesInfoInitialized = true then
>   GAPInfo.PackagesInfoInitialized := false;
>   InitializePackagesInfoRecords();
> fi;
gap> PackageInfo("corelg");
[  ]
gap> PackageInfo("sla");
[  ]
gap> InstallPackage("https://github.com/gap-packages/utils/releases/download/v0.84/utils-0.84.tar.gz");  # TEMP
true
gap> InstallPackage("corelg");
true
gap> ForAll(["corelg", "sla", "quagroup"],
>           name -> Length(PackageInfo(name)) = 1 or
>                   IsPackageLoaded(LowercaseString(name)));
true
gap> GAPInfo.RootPaths := old_paths;;
gap> GAPInfo.DirectoriesLibrary := AtomicRecord(rec());;
gap> if IsBound(GAPInfo.PackagesInfoInitialized) and
>   GAPInfo.PackagesInfoInitialized = true then
>   GAPInfo.PackagesInfoInitialized := false;
>   InitializePackagesInfoRecords();
> fi;

# Dependency failure
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/uuid-badname.tar.gz");
#I  Required package madeuppackage unknown
#I  Dependencies not satisfied for uuid-badname
false
gap> InstallPackageFromGit("https://github.com/mtorpey/uuid.git", false);
#I  Required package MadeUpPackage unknown
#I  Dependencies not satisfied for uuid
false

# Sabotaged PackageInfoURLList to produce some special errors
gap> InstallPackage("GAPDoc");
true
gap> InstallPackage("uuid");
true
gap> urllist := PKGMAN_PackageInfoURLList;;
gap> PKGMAN_PackageInfoURLList :=
> "https://gap-packages.github.io/PackageManager/dummy/badurls.txt";;
gap> UpdatePackage("GAPDoc", false);  # Installed version is newer than online
true
gap> UpdatePackage("uuid", false);  # Newer version, but fails to install
#I  Could not inspect tarball contents
false
gap> RemovePackage("uuid", false);
true
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/uuid-too-new.tar.gz");
#I  Package GAPDoc = 999.0 unavailable: only version 0.2 was found
#I  Dependencies not satisfied for uuid-too-new
false
gap> PKGMAN_PackageInfoURLList := urllist;;

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
