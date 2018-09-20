# Install and remove a package by name
gap> InstallPackage("matgrp");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "matgrp"));
true
gap> RemovePackage("matgrp");
true
gap> RemovePackage("matgrp");
#I  Package "matgrp" not installed in user package directory
false

# Install a package from a git repository
gap> InstallPackage("https://github.com/gap-packages/Example.git");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "Example"));
true

# Install a package from a git repository not ending in .git
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "RegisterPackageTNUMDemo"));
true

# Install a package from a Mercurial repository not ending in .hg
gap> InstallPackageFromHg("https://bitbucket.org/jdebeule/forms");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "forms"));
true

# Install a package from a PackageInfo.g URL (includes redirect)
gap> InstallPackage("https://gap-packages.github.io/autpgrp/PackageInfo.g");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "autpgrp"));
true

# Install a package from a .tar.gz archive
gap> InstallPackage("https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/mapclass-1.2.tar.gz");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "mapclass"));
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

# Installing multiple versions
gap> InstallPackage("https://github.com/gap-packages/uuid/releases/download/v0.5/uuid-0.5.tar.gz");
true
gap> InstallPackage("https://github.com/gap-packages/uuid/releases/download/v0.4/uuid-0.4.tar.gz");
true
gap> RemovePackage("uuid");
#I  Multiple versions of package uuid installed
false
gap> LoadPackage("uuid", false);
true

# GetPackageURLs failure
gap> default_url := PKGMAN_PackageInfoURLList;;
gap> PKGMAN_PackageInfoURLList := "http://www.nothing.rubbish/abc.txt";;
gap> GetPackageURLs();
Error, PackageManager: GetPackageList: could not contact server
gap> PKGMAN_PackageInfoURLList := "https://www.gap-system.org";;
gap> GetPackageURLs();
Error, PackageManager: GetPackageList: bad line:
<?xml version="1.0" encoding="utf-8"?>
gap> PKGMAN_PackageInfoURLList := default_url;;

# InstallPackage input failure
gap> InstallPackage(3);
Error, PackageManager: InstallPackage: <string> must be a string

# InstallPackageFromName failure
gap> InstallPackage("sillypackage");
#I  Package "sillypackage" not found in package list
false

# InstallPackageFromInfo failure (Remove #E messages after they leave GAP)
gap> InstallPackage("http://www.nothing.rubbish/PackageInfo.g");
#I  Unable to download from http://www.nothing.rubbish/PackageInfo.g
false
gap> InstallPackage("https://mtorpey.github.io/PackageManager/dummy/PackageInfo.g");
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
#I  No .tar.gz available, so could not install
#I  Only [ ".zip" ] available
false

# InstallPackageFromArchive failure
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false
gap> InstallPackage("https://mtorpey.github.io/PackageManager/dummy/bad-tarball.tar.gz");
#I  Could not inspect tarball contents
false
gap> InstallPackage("https://mtorpey.github.io/PackageManager/dummy/twodirs.tar.gz");
#I  Archive should contain 1 directory (not 2)
false
gap> InstallPackage("https://mtorpey.github.io/PackageManager/dummy/badpackage.tar.gz");
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

# Fail to extract due to permissions
gap> dir := Filename(Directory(PKGMAN_PackageDir()), "badpackage");;
gap> CreateDir(dir);
true
gap> PKGMAN_Exec(".", "chmod", "000", dir);
rec( code := 0, output := "" )
gap> InstallPackage("https://mtorpey.github.io/PackageManager/dummy/badpackage.tar.gz");
#I  Extraction unsuccessful
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
gap> PKGMAN_SetCustomPackageDir("/home"); # not ending in pkg
fail

# PKGMAN_CompileDir error: no shell
gap> InstallPackage("example");
true
gap> progs := GAPInfo.DirectoriesPrograms;;
gap> GAPInfo.DirectoriesPrograms := [];;  # terrible vandalism
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No shell available called "sh"
false
gap> GAPInfo.DirectoriesPrograms := progs;;

# PKGMAN_CompileDir error: no bin/BuildPackages.sh
gap> InstallPackage("example");
true
gap> roots := GAPInfo.RootPaths;;
gap> GAPInfo.RootPaths := [];;  # also terrible vandalism
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No bin/BuildPackages.sh script available
false
gap> GAPInfo.RootPaths := roots;;

# PKGMAN_CompileDir error: missing source
gap> InstallPackage("example");
true
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> RemoveFile(Filename(Directory(dir), "src/hello.c"));
true
gap> PKGMAN_CompileDir(dir);
#I  Compilation failed
false
gap> GAPInfo.RootPaths := roots;;

# Missing curlInterface: use wget instead
gap> s := PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages;;
gap> First(s, item -> item[1] = "curlInterface")[2] := ">= 100.0";;
gap> First(s, item -> item[1] = "curlInterface")[2];
">= 100.0"
gap> InstallPackage("qaos");
true

# wget failure
gap> s := PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages;;
gap> First(s, item -> item[1] = "curlInterface")[2] := ">= 100.0";;
gap> First(s, item -> item[1] = "curlInterface")[2];
">= 100.0"
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false

# Missing curlInterface: use curl instead
gap> s := PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages;;
gap> First(s, item -> item[1] = "curlInterface")[2] := ">= 100.0";;
gap> First(s, item -> item[1] = "curlInterface")[2];
">= 100.0"
gap> tmp := PKGMAN_DownloadCmds[1];;
gap> PKGMAN_DownloadCmds[1] := PKGMAN_DownloadCmds[2];;
gap> PKGMAN_DownloadCmds[2] := tmp;;
gap> PKGMAN_DownloadCmds[1][1];
"curl"
gap> InstallPackage("grpconst");
true

# curl failure
gap> s := PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages;;
gap> First(s, item -> item[1] = "curlInterface")[2] := ">= 100.0";;
gap> First(s, item -> item[1] = "curlInterface")[2];
">= 100.0"
gap> PKGMAN_DownloadCmds[1][1];
"curl"
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false

# Missing first command
gap> s := PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages;;
gap> First(s, item -> item[1] = "curlInterface")[2] := ">= 100.0";;
gap> First(s, item -> item[1] = "curlInterface")[2];
">= 100.0"
gap> PKGMAN_DownloadCmds[1][1] := "abababaxyz";;
gap> InstallPackage("grpconst");
true

# FINAL TEST
# (keep this at the end of the file)
gap> PKGMAN_SetCustomPackageDir(Filename(DirectoryTemporary(), "pkg/"));
