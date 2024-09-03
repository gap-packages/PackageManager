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

# Install a package from a git repository not ending in .git
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo", false);
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "RegisterPackageTNUMDemo"));
true
gap> InstallPackageFromGit("https://github.com/gap-packages/RegisterPackageTNUMDemo", false);
#I  Package already installed at target location
false

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
Error, PackageManager: InstallPackageFromGit:
<interactive> should be true or false
gap> InstallPackageFromGit("https://github.com/a/b.git", false, 3);
Error, PackageManager: InstallPackageFromGit:
<branch> should be a string
gap> InstallPackageFromGit("https://github.com/a/b.git", 3);
Error, PackageManager: InstallPackageFromGit:
2nd argument should be true, false, or a string
gap> InstallPackageFromGit("https://github.com/a/b.git", true, "master", "lol");
Error, PackageManager: InstallPackageFromGit:
requires 1, 2 or 3 arguments (not 4)

# Bad package info
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage2.tar.gz");
#I  PackageInfo.g lacks Version field
false

# The big one: install semigroups, and mess with its dependencies
# TEMP: removed since semigroups now takes around 10 minutes to compile
# gap> InstallPackage("semigroups");
# true
# gap> dig := First(PackageInfo("digraphs"),
# >                 x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));;
# gap> PKGMAN_RemoveDir(Filename(Directory(dig.InstallationPath), "bin"));
# gap> UpdatePackage("semigroups");  # should recompile digraphs
# true
# gap> dig := First(PackageInfo("digraphs"),
# >                 x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));;
# gap> RemoveFile(Filename(Directory(dig.InstallationPath), "PackageInfo.g"));
# true
# gap> UpdatePackage("semigroups");  # recompiling doesn't work
# #I  Package already installed at target location
# #I  Dependencies not satisfied
# #I  Package availability test failed
# false
# gap> RemovePackage("semigroups", false);
# true
