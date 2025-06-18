DeclareGlobalFunction("PKGMAN_InstallFromInfo");

DeclareGlobalFunction("PKGMAN_UrlFromInfo");
DeclareGlobalFunction("PKGMAN_GetPackageInfo");
DeclareGlobalFunction("PKGMAN_RefreshPackageInfo");
DeclareGlobalFunction("PKGMAN_ValidatePackageInfo");
DeclareGlobalFunction("PKGMAN_UserPackageInfo");

# PackageInfo files must at least contain the following:
PKGMAN_RequiredPackageInfoFields := ["PackageName",
                                     "PackageDoc",
                                     "Version",
                                     "Date"];
