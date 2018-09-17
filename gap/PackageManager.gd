#
# PackageManager: Easily download and install GAP packages
#
# Declarations
#

DeclareGlobalFunction("GetPackageURLs");
DeclareGlobalFunction("InstallPackageName");

#! @Description
#!   Attempts to download and install a package
#! @Args pkg_name
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageURL");

#! @Description
#!   Attempts to remove an installed package
#! @Args pkg_name
#! @Returns
#!   true or false
DeclareGlobalFunction("RemovePackage");
