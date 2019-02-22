# Install and remove a package by name
gap> InstallPackage("matgrp");
true
gap> InstallPackage("matgrp");
#I  The newest version of package "matgrp" is already installed
false
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "matgrp"));
true
gap> RemovePackage("matgrp", false);
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
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo");
#I  Package already installed at target location
false

# Install a package from a Mercurial repository not ending in .hg
gap> InstallPackageFromHg("https://bitbucket.org/jdebeule/forms");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "forms"));
true
gap> InstallPackageFromHg("https://bitbucket.org/jdebeule/forms");
#I  Package already installed at target location
false

# Repositories that don't contain GAP packages
gap> InstallPackageFromGit("https://github.com/mtorpey/planets.git");
#I  Could not find PackageInfo.g
false
gap> InstallPackageFromHg("https://bitbucket.org/mtorpey/lowindex");
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

# Interactive tests (via hacking in/out streams)
gap> InstallPackage("https://github.com/gap-packages/uuid/releases/download/v0.5/uuid-0.5.tar.gz");
true
gap> out := "";;
gap> f_in := InputTextUser;;
gap> oldPrint := Print;;
gap> newPrint := function(args...)
>   CallFuncList(PrintTo, Concatenation([OutputTextString(out, true)], args));
> end;;
gap> MakeReadWriteGlobal("InputTextUser");
gap> MakeReadWriteGlobal("Print");
gap> InputTextUser := {} -> InputTextString("n");;
gap> Print := newPrint;;
gap> res := RemovePackage("uuid");;
gap> Print := oldPrint;;
gap> res;
false
gap> PositionSublist(out,
>                    StringFormatted("Really delete directory {} ? [y/N] n\n",
>                                    Filename(Directory(PKGMAN_PackageDir()),
>                                             "uuid-0.5"))) <> fail;
true
gap> InputTextUser := {} -> InputTextString("x\n");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := InstallPackage("uuid", true);;
gap> Print := oldPrint;;
gap> res;
false
gap> exp := Concatenation("Package \"uuid\" version 0.5 is installed, but ",
>                         PKGMAN_DownloadPackageInfo(GetPackageURLs().uuid).Version,
>                         " is available. Install it? [y/N] \n");;
gap> PositionSublist(out, exp) <> fail;
true
gap> InputTextUser := {} -> InputTextString("y");;
gap> out := "";;
gap> Print := newPrint;;
gap> res := RemovePackage("uuid", true);;
gap> Print := oldPrint;;
gap> res;
true
gap> PositionSublist(out,
>                    StringFormatted("Really delete directory {} ? [y/N] y\n",
>                                    Filename(Directory(PKGMAN_PackageDir()),
>                                             "uuid-0.5"))) <> fail;
true
gap> InputTextUser := f_in;;
gap> MakeReadOnlyGlobal("InputTextUser");
gap> MakeReadOnlyGlobal("Print");
gap> Print(InputTextUser, "\n");
function (  )
    return InputTextFile( "*stdin*" );
end
gap> Print = oldPrint;
true
gap> Print = newPrint;
false

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
Error, PackageManager: GetPackageList: could not contact server
gap> PKGMAN_PackageInfoURLList := "https://www.gap-system.org";;
gap> GetPackageURLs();
Error, PackageManager: GetPackageList: bad line:
<?xml version="1.0" encoding="utf-8"?>
gap> PKGMAN_PackageInfoURLList := default_url;;

# InstallPackage input failure
gap> InstallPackage(3);
Error, PackageManager: InstallPackage: <string> must be a string
gap> InstallPackage("qaos", "yes");
Error, PackageManager: InstallPackage: <interactive> must be true or false
gap> InstallPackage("qaos", "yes", "actually no");
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
#I  No .tar.gz available, so could not install
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
gap> PKGMAN_InsertPackageDirectory("/home"); # not ending in pkg
fail

# PKGMAN_CompileDir error: no shell
gap> InstallPackage("example");
#I  The newest version of package "example" is already installed
false
gap> progs := GAPInfo.DirectoriesPrograms;;
gap> GAPInfo.DirectoriesPrograms := [];;  # terrible vandalism
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No shell available called "sh"
#I  Compilation failed (package may still be usable)
false
gap> GAPInfo.DirectoriesPrograms := progs;;

# PKGMAN_CompileDir error: no bin/BuildPackages.sh
gap> InstallPackage("example", false);
#I  The newest version of package "example" is already installed
false
gap> build_scr := PKGMAN_BuildPackagesScript;;
gap> PKGMAN_BuildPackagesScript := fail;;
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No bin/BuildPackages.sh script available
false
gap> PKGMAN_BuildPackagesScript := build_scr;;

# PKGMAN_CompileDir error: missing source
gap> InstallPackage("example");
#I  The newest version of package "example" is already installed
false
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> RemoveFile(Filename(Directory(dir), "src/hello.c"));
true
gap> PKGMAN_CompileDir(dir);
#I  Compilation failed (package may still be usable)
false

# Missing curlInterface: use wget instead
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> InstallPackage("qaos");
true
gap> RemovePackage("qaos", false);
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
gap> GAPInfo.DirectoriesLibrary:= AtomicRecord(rec());;
gap> if IsBound(GAPInfo.PackagesInfoInitialized) and
>   GAPInfo.PackagesInfoInitialized = true then
>   GAPInfo.PackagesInfoInitialized:= false;
>   InitializePackagesInfoRecords();
> fi;
gap> PackageInfo("qaos");
[  ]
gap> PackageInfo("HomalgToCAS");
[  ]
gap> PackageInfo("MatricesForHomalg");
[  ]
gap> PackageInfo("ToolsForHomalg");
[  ]
gap> InstallPackage("HomalgToCAS");
true
gap> ForAll(["HomalgToCAS", "MatricesForHomalg", "ToolsForHomalg"],
>           name -> Length(PackageInfo(name)) = 1 or
>                   IsPackageLoaded(LowercaseString(name)));
true
gap> GAPInfo.RootPaths := old_paths;;
gap> GAPInfo.DirectoriesLibrary:= AtomicRecord(rec());;
gap> if IsBound(GAPInfo.PackagesInfoInitialized) and
>   GAPInfo.PackagesInfoInitialized = true then
>   GAPInfo.PackagesInfoInitialized:= false;
>   InitializePackagesInfoRecords();
> fi;

# Dependency failure
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/uuid-too-new.tar.gz");
#I  Package GAPDoc >= 999.0 unavailable: only version 1.6.2 was found
#I  Dependencies not satisfied for uuid-0.6
false
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/uuid-badname.tar.gz");
#I  Required package madeuppackage unknown
#I  Dependencies not satisfied for uuid-0.6
false
gap> InstallPackageFromHg("https://mtorpey@bitbucket.org/mtorpey/uuid");
#I  Required package MadeUpPackage unknown
#I  Dependencies not satisfied for uuid
false
gap> InstallPackageFromGit("https://github.com/mtorpey/uuid.git");
#I  Required package MadeUpPackage unknown
#I  Dependencies not satisfied for uuid
false

# Fail to install a dependency (sabotaged PackageInfoURLList)
gap> urllist := PKGMAN_PackageInfoURLList;;
gap> PKGMAN_PackageInfoURLList :=
> "https://gap-packages.github.io/PackageManager/dummy/badurls.txt";;
gap> InstallPackageFromGit("https://github.com/mtorpey/uuid.git");
#I  Could not inspect tarball contents
#I  Dependencies not satisfied for uuid
false
gap> PKGMAN_PackageInfoURLList := urllist;;
gap> RemovePackage("uuid");
#I  Package "uuid" not installed in user package directory
false

# FINAL TEST
# (keep this at the end of the file)
gap> PKGMAN_SetCustomPackageDir(Filename(DirectoryTemporary(), "pkg/"));
