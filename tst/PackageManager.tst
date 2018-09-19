# Install and remove a package by name
gap> InstallPackage("atlasrep");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "atlasrep"));
true

# Install a package from a git repository
gap> InstallPackage("git@github.com:gap-packages/json.git");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "json"));
true

# RemovePackage failure
gap> RemovePackage("xyz");
#I  Package "xyz" not installed in user package directory
false
