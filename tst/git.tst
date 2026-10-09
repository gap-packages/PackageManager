# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true

# Install a package from a git repository by branch
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle.git", false, "master");
true
gap> RemovePackage("MathInTheMiddle");
true
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle.git", "master");
true
gap> RemovePackage("MathInTheMiddle");
true
gap> InstallPackage("https://github.com/gap-packages/orb.git", false, "fiaenfq");
#I  Cloning unsuccessful
false

# Install a package from a git repository not ending in .git
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "MathInTheMiddle"));
true
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle");
#I  Package already installed at target location
false
gap> RemovePackage("MathInTheMiddle");
true

# Repositories that don't contain GAP packages
gap> InstallPackage("https://github.com/mtorpey/planets.git", true);
#I  Could not find PackageInfo.g
false
gap> IsReadableFile(Filename(Directory(PKGMAN_PackageDir()), "planets"));
false
gap> InstallPackage("https://github.com/mtorpey/planets.git", true : keepDirectory);
#I  Could not find PackageInfo.g
false
gap> IsReadableFile(Filename(Directory(PKGMAN_PackageDir()), "planets"));
true

# InstallPackage from git: failure
gap> InstallPackage("www.gap.rubbish/somepackage.git");
#I  Cloning unsuccessful
false
gap> InstallPackage(".git");
#I  Could not find repository name (bad URL?)
false
