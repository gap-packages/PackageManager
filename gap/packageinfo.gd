#! @Description
#!   Attempts to download and install a package from a valid `PackageInfo.g`
#!   file.  The argument <A>info</A> should be either a valid package info
#!   record, or a URL that points to a valid `PackageInfo.g` file.  Returns
#!   <K>true</K> if the installation was successful, and <K>false</K> otherwise.
#! @Arguments info
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromInfo");

DeclareGlobalFunction("PKGMAN_GetPackageInfo");
DeclareGlobalFunction("PKGMAN_RefreshPackageInfo");
DeclareGlobalFunction("PKGMAN_ValidatePackageInfo");
DeclareGlobalFunction("PKGMAN_UserPackageInfo");

# PackageInfo files must at least contain the following:
PKGMAN_RequiredPackageInfoFields := ["PackageName",
                                     "PackageDoc",
                                     "Version",
                                     "Date"];
