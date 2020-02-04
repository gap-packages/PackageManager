# Get curlInterface (for testing)
gap> InstallPackage("curlInterface");
true
gap> if DownloadURL = fail then
>   Unbind(DownloadURL);  # unbind dummy variable set in init.g
> fi;
gap> LoadPackage("curlInterface", false);
true

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

# Install old version of atlasrep (TEMPORARY to matgrp work in the next example)
gap> InstallPackage("https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/atlasrep1r5p1.tar.gz");
true

# Install and remove a package by name
gap> InstallPackage("matgrp");
true
gap> InstallPackage("matgrp");
true
gap> UpdatePackage("matgrp");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "matgrp"));
true
gap> RemovePackage("matgrp", false);
true
gap> RemovePackage("matgrp");
#I  Package "matgrp" not installed in user package directory
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

# Repositories that don't contain GAP packages
gap> InstallPackageFromGit("https://github.com/mtorpey/planets.git", true);
#I  Could not find PackageInfo.g
false
gap> InstallPackageFromHg("https://bitbucket.org/mtorpey/lowindex", true);
#I  Could not find PackageInfo.g
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
gap> InstallPackage("https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/MapClass-1.4.3.tar.gz");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(LowercaseString(f), "mapclass"));
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
gap> InstallPackage("https://github.com/gap-packages/grpconst/releases/download/v2.6/grpconst-2.6.tar.gz");
true
gap> InstallPackage("https://github.com/gap-packages/grpconst/releases/download/v2.5/grpconst-2.5.tar.gz");
true
gap> RemovePackage("grpconst");
#I  Multiple versions of package grpconst installed
false

# GetPackageURLs failure
gap> default_url := PKGMAN_PackageInfoURLList;;
gap> PKGMAN_PackageInfoURLList := "http://www.nothing.rubbish/abc.txt";;
gap> GetPackageURLs();
Error, PackageManager: GetPackageURLs: could not contact server
gap> PKGMAN_PackageInfoURLList := "https://www.gap-system.org";;
gap> GetPackageURLs();
Error, PackageManager: GetPackageURLs: bad line:
<?xml version="1.0" encoding="utf-8"?>
gap> PKGMAN_PackageInfoURLList := default_url;;

# InstallPackage input failure
gap> InstallPackage(3);
Error, PackageManager: InstallPackage: <string> must be a string
gap> InstallPackage("semigroups", "yes");
Error, PackageManager: InstallPackage: <interactive> must be true or false
gap> InstallPackage("semigroups", "yes", "actually no");
Error, PackageManager: InstallPackage: requires 1 or 2 arguments (not 3)

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
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/PackageInfo.g");
#E  component `PackageName' must be bound to a nonempty string
#E  component `Subtitle' must be bound to a string
#E  component `Version' must be bound to a nonempty string that does not start\
 with `='
#E  component `Date' must be bound to a string of the form `dd/mm/yyyy'
#E  component `ArchiveURL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `ArchiveFormats' must be bound to a string
#E  component `Status' must be bound to one of "accepted", "deposited", "dev",\
 "other"
#E  component `README_URL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `PackageInfoURL' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `AbstractHTML' must be bound to a string
#E  component `PackageWWWHome' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `PackageDoc' must be bound to a record or a list of records
#E  component `AvailabilityTest' must be bound to a function
#I  Invalid PackageInfo.g file
false
gap> InstallPackage("nilmat");
#I  No supported archive formats available, so could not install
#I  Only [ ".zip" ] available
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
#I  PackageInfo.g validation failed
false
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage2.tar.gz");
#E  component `Subtitle' must be bound to a string
#E  component `Version' must be bound to a nonempty string that does not start\
 with `='
#E  component `Date' must be bound to a string of the form `dd/mm/yyyy'
#E  component `ArchiveURL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `ArchiveFormats' must be bound to a string
#E  component `Status' must be bound to one of "accepted", "deposited", "dev",\
 "other"
#E  component `README_URL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `PackageInfoURL' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `AbstractHTML' must be bound to a string
#E  component `PackageWWWHome' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `BookName' must be bound to a string
#E  component `ArchiveURLSubset' must be bound to a list of strings denoting r\
elative paths to readable files or directories
#E  component `HTMLStart' must be bound to a string denoting a relative path t\
o a readable file
#E  component `PDFFile' must be bound to a string denoting a relative path to \
a readable file
#E  component `SixFile' must be bound to a string denoting a relative path to \
a readable file
#E  component `LongTitle' must be bound to a string
#E  component `AvailabilityTest' must be bound to a function
#I  PackageInfo.g validation failed
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

# InstallPackageFromGit failure
gap> InstallPackage("www.gap.rubbish/somepackage.git");
#I  Cloning unsuccessful
false
gap> InstallPackage(".git");
#I  Could not find repository name (bad URL?)
false

# InstallPackageFromHg failure
gap> InstallPackage("www.gap.rubbish/somepackage.hg");
#I  Cloning unsuccessful
false
gap> InstallPackage(".hg");
#I  Could not find repository name (bad URL?)
false

# Check a bad package directory (Remove #E messages after they leave GAP)
gap> baddir := Filename(Directory(PKGMAN_PackageDir()), "badpkg");;
gap> CreateDir(baddir);;
gap> PKGMAN_CheckPackage(baddir);
#I  Could not find PackageInfo.g file
false
gap> FileString(Filename(Directory(baddir), "PackageInfo.g"),
>               "SetPackageInfo(rec());");;
gap> PKGMAN_CheckPackage(baddir);
#I  PackageInfo.g validation failed
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

# PKGMAN_CompileDir error: no shell
gap> InstallPackage("example");
true
gap> InstallPackage("example");  # latest version already installed
true
gap> progs := GAPInfo.DirectoriesPrograms;;
gap> GAPInfo.DirectoriesPrograms := [];;  # terrible vandalism
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No shell available called "sh"
#I  Compilation failed (package may still be usable)
false
gap> GAPInfo.DirectoriesPrograms := progs;;

# PKGMAN_CompileDir error: no bin/BuildPackages.sh
gap> InstallPackage("example", false);  # latest version already installed
true
gap> build_scr := PKGMAN_BuildPackagesScript;;
gap> PKGMAN_BuildPackagesScript := fail;;
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No bin/BuildPackages.sh script available
false
gap> PKGMAN_BuildPackagesScript := build_scr;;

# PKGMAN_CompileDir error: missing source
gap> InstallPackage("example");  # latest version already installed
true
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> RemoveFile(Filename(Directory(dir), "src/hello.c"));
true
gap> PKGMAN_CompileDir(dir);
#I  Compilation failed (package may still be usable)
false

# Missing curlInterface: use wget instead
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> InstallPackage("4ti2Interface");
true
gap> RemovePackage("4ti2Interface", false);
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
gap> CreateDir(Filename(Directory(PKGMAN_PackageDir()), "Toric-1.9.4"));
true
gap> InstallPackage("https://github.com/gap-packages/toric/releases/download/v1.9.4/Toric-1.9.4.tar.gz");
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
gap> PackageInfo("HomalgToCAS");
[  ]
gap> PackageInfo("MatricesForHomalg");
[  ]
gap> InstallPackage("https://github.com/gap-packages/utils/releases/download/v0.59/utils-0.59.tar.gz");  # TEMP
true
gap> InstallPackage("HomalgToCAS");
true
gap> ForAll(["HomalgToCAS", "MatricesForHomalg", "GAPDoc", "IO"],
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
#I  Dependencies not satisfied for uuid-0.6
false
gap> InstallPackageFromHg("https://mtorpey@bitbucket.org/mtorpey/uuid");
#I  Required package MadeUpPackage unknown
#I  Dependencies not satisfied for uuid
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
gap> InstallPackageFromGit("https://github.com/mtorpey/uuid.git", false);
#I  Could not inspect tarball contents
#I  Dependencies not satisfied for uuid
false
gap> UpdatePackage("GAPDoc", false);  # Installed version is newer than online
true
gap> UpdatePackage("uuid", false);  # Newer version, but fails to install
#I  Could not inspect tarball contents
false
gap> RemovePackage("uuid", false);
true
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/uuid-too-new.tar.gz");
#I  Package GAPDoc >= 999.0 unavailable: only version 0.2 was found
#I  Dependencies not satisfied for uuid-0.6
false
gap> PKGMAN_PackageInfoURLList := urllist;;

# Fail to build doc with doc/make_doc (assumes GAP is located at ../../..)
gap> InstallPackage("https://github.com/gap-packages/grape.git");
#E  component `ArchiveURLSubset' must be bound to a list of strings denoting r\
elative paths to readable files or directories
#E  component `HTMLStart' must be bound to a string denoting a relative path t\
o a readable file
#E  component `PDFFile' must be bound to a string denoting a relative path to \
a readable file
#E  component `SixFile' must be bound to a string denoting a relative path to \
a readable file
#I  PackageInfo.g validation failed
false

# FINAL TEST
# (keep this at the end of the file)
gap> PKGMAN_SetCustomPackageDir(Filename(DirectoryTemporary(), "pkg/"));
