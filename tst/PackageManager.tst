# Install and remove a package by name
gap> InstallPackage("atlasrep");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "atlasrep"));
true

# Install a package from a git repository
gap> InstallPackage("https://github.com/gap-packages/json.git");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "json"));
true

# Install a package from a PackageInfo.g URL (includes redirect)
gap> InstallPackage("https://gap-packages.github.io/cohomolo/PackageInfo.g");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "cohomolo"));
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

# InstallPackageFromGit failure
gap> InstallPackage("www.gap.rubbish/somepackage.git");
#I  Extraction unsuccessful
false
gap> InstallPackage(".git");
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
