# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true

# Install a package from a git repository, and modify it
gap> InstallPackage("https://github.com/gap-packages/Example.git");
true
gap> dir := First(DirectoryContents(PKGMAN_PackageDir()),
>                 f -> StartsWith(f, "Example"));;
gap> dir := Filename(Directory(PKGMAN_PackageDir()), dir);;
gap> dir <> fail;
true
gap> readme := Filename(Directory(dir), "README.md");;
gap> FileString(readme, "Some change I've made", true);;  # edit file
gap> UpdatePackage("example");
#I  Uncommitted changes in git repository
false
gap> RemovePackage("example", false);
true

# Install a package from a git repository by branch
gap> InstallPackageFromGit("https://github.com/gap-packages/MathInTheMiddle.git", false, "master");
true
gap> RemovePackage("MathInTheMiddle", false);
true
gap> InstallPackageFromGit("https://github.com/gap-packages/MathInTheMiddle.git", "master");
true
gap> RemovePackage("MathInTheMiddle", false);
true
gap> InstallPackageFromGit("https://github.com/gap-packages/orb.git", false, "fiaenfq");
#I  Cloning unsuccessful
false
gap> InstallPackageFromGit("https://github.com/gap-packages/orb.git", "master", true);
Error, <interactive> should be true or false
gap> InstallPackageFromGit("https://github.com/a/b.git", false, 3);
Error, <branch> should be a string
gap> InstallPackageFromGit("https://github.com/a/b.git", 3);
Error, 2nd argument should be true, false, or a string
gap> InstallPackageFromGit("https://github.com/a/b.git", true, "master", "lol");
Error, requires 1, 2 or 3 arguments (not 4)

# Install a package from a git repository not ending in .git
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo", false);
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "RegisterPackageTNUMDemo"));
true
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo", false);
#I  Package already installed at target location
false

# Repositories that don't contain GAP packages
gap> InstallPackageFromGit("https://github.com/mtorpey/planets.git", true);
#I  Could not find PackageInfo.g
false
gap> IsReadableFile(Filename(Directory(PKGMAN_PackageDir()), "planets"));
false
gap> InstallPackageFromGit("https://github.com/mtorpey/planets.git", true : keepDirectory);
#I  Could not find PackageInfo.g
false
gap> IsReadableFile(Filename(Directory(PKGMAN_PackageDir()), "planets"));
true

# InstallPackageFromGit failure
gap> InstallPackage("www.gap.rubbish/somepackage.git");
#I  Cloning unsuccessful
false
gap> InstallPackage(".git");
#I  Could not find repository name (bad URL?)
false
