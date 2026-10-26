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
gap> IsReadableFile(Filename(Directory(DirectoryPackageManager()), "orb"));
false

# Install a package from a git repository not ending in .git
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle");
true
gap> ForAny(DirectoryContents(DirectoryPackageManager()),
>           f -> StartsWith(f, "MathInTheMiddle"));
true
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle");
#I  Existing git repository for MathInTheMiddle found
#I  Uncommitted changes in git repository
#I  There may be upstream changes that haven't been merged
false
gap> RemovePackage("MathInTheMiddle");
true

# Repositories that don't contain GAP packages
gap> InstallPackage("https://github.com/mtorpey/planets.git", true);
#I  Could not find PackageInfo.g
false
gap> IsReadableFile(Filename(Directory(DirectoryPackageManager()), "planets"));
true

# InstallPackage from git: failure
gap> InstallPackage("www.gap.rubbish/somepackage.git");
#I  Cloning unsuccessful
false
gap> InstallPackage(".git");
#I  Could not find repository name (bad URL?)
false
