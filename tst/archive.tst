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

# Updating old package that doesn't have the version number in its directory name
gap> InstallPackage("https://www.math.colostate.edu/~hulpke/transgrp/transgrp3.6.4.tar.gz");
true
gap> oldinfo := First(PackageInfo("transgrp"), x -> x.Version = "3.6.4");;
gap> oldinfo <> fail;
true
gap> PositionSublist(oldinfo.InstallationPath, "3.6.4");  # version number not in dir name
fail
gap> UpdatePackage("transgrp", false);  # also removes old version
#I  Package already installed at target location
#I  Appending '.old' to old version directory
true
gap> newinfo := PackageInfo("transgrp")[1];;
gap> CompareVersionNumbers(newinfo.Version, ">=3.6.5");
true
gap> RemovePackage("transgrp", false);
true

# Install to existing empty directory
gap> CreateDir(Filename(Directory(PKGMAN_PackageDir()), "Toric-1.9.5"));
true
gap> InstallPackage("https://github.com/gap-packages/toric/releases/download/v1.9.5/Toric-1.9.5.tar.gz");
true
gap> RemovePackage("toric", false);
true
