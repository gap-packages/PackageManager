# Install a package from a .tar.gz archive
gap> InstallPackage("https://github.com/gap-packages/example/releases/download/v4.2.1/Example-4.2.1.tar.gz");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(LowercaseString(f), "example"));
true
gap> RemovePackage("example", false);
true

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

# Updating old package that doesn't have the version number in its directory
# name.  We use a dummy package served by a local HTTP server: the real-world
# example used to be transgrp, but downloading it twice meant fetching 120MB
# from a third-party server on every test run.
gap> LoadPackage("io", false);
true
gap> ReadPackage("PackageManager", "tst/http-server.g");
true
gap> server := PKGMAN_StartHTTPTestServer(PKGMAN_PrepareTestData());;
gap> InstallPackage(Concatenation(server.url, "/pmdummy-1.0.tar.gz"));
true
gap> oldinfo := First(PackageInfo("pmdummy"), x -> x.Version = "1.0");;
gap> oldinfo <> fail;
true
gap> PositionSublist(oldinfo.InstallationPath, "1.0");  # version number not in dir name
fail
gap> urllist := PKGMAN_PackageInfoURLList;;
gap> PKGMAN_PackageInfoURLList := Concatenation(server.url, "/pkglist.csv");;
gap> UpdatePackage("pmdummy", false);  # also removes old version
#I  Package already installed at target location
#I  Appending '.old' to old version directory
true
gap> PKGMAN_PackageInfoURLList := urllist;;
gap> newinfo := PKGMAN_UserPackageInfo("pmdummy")[1];;
gap> newinfo.Version;
"2.0"
gap> RemovePackage("pmdummy", false);
true
gap> PKGMAN_StopHTTPTestServer(server);

# Install to existing empty directory
gap> CreateDir(Filename(Directory(PKGMAN_PackageDir()), "Toric-1.9.5"));
true
gap> InstallPackage("https://github.com/gap-packages/toric/releases/download/v1.9.5/Toric-1.9.5.tar.gz");
true
gap> RemovePackage("toric", false);
true
