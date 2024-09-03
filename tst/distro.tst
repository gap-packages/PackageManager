gap> LoadPackage("curlInterface", false);
true

# IO should be pre-installed for these tests to pass
gap> IsEmpty(PackageInfo("io"));
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

# InstallPackageFromName failure
gap> InstallPackage("sillypackage");
#I  Package "sillypackage" not found in package list
false

# TODO: package that doesn't offer a ".tar.gz" archive
# I'm not sure any such packages currently exist.
#gap> InstallPackage("nilmat");
##I  No supported archive formats available, so could not install
##I  Only [ ".zip" ] available
#false

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
