# Install a package from a PackageInfo.g URL (includes redirect)
gap> InstallPackage("https://gap-packages.github.io/autpgrp/PackageInfo.g");
true
gap> ForAny(DirectoryContents(PKGMAN_PackageDir()),
>           f -> StartsWith(f, "autpgrp"));
true
gap> RemovePackage("autpgrp", false);
true

# InstallPackageFromInfo input failure
gap> InstallPackageFromInfo(42);
Error, <info> should be a rec or URL

# InstallPackageFromInfo failure
gap> InstallPackage("http://www.nothing.rubbish/PackageInfo.g");
#I  Unable to download from http://www.nothing.rubbish/PackageInfo.g
false
