# Get AutoDoc (for testing)
gap> InstallPackage("autodoc");
true
gap> LoadPackage("autodoc", false);
true

# Install a package from a git repository not ending in .git
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "MathInTheMiddle"));
false
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "MathInTheMiddle"));
true
gap> InstallPackage("https://github.com/gap-packages/MathInTheMiddle");
#I  Existing git repository for MathInTheMiddle found
#I  Uncommitted changes in git repository
#I  There may be upstream changes that haven't been merged
false
gap> RemovePackage("MathInTheMiddle");
true
