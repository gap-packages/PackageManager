#
# PackageManager: Easily download and install GAP packages
#
# Declarations
#

#! @Description
#!   Info class for the PackageManager package.  Set this to the following
#!   levels for different levels of information:
#!     * 0 - No messages
#!     * 1 - Problems only: messages describing what went wrong, with no
#!           messages if an operation is successful
#!     * 2 - Problems and directories: also displays directories that were used
#!           for package installation or removal
#!     * 3 - All: shows step-by-step progress of operations
#!   Set this using, for example <C>SetInfoLevel(InfoPackageManager, 3)</C>.
#!   Default value is 1.
DeclareInfoClass("InfoPackageManager");
SetInfoLevel(InfoPackageManager, 1);

DeclareGlobalFunction("GetPackageURLs");

#! @Description
#!   Attempts to download and install a package given only its name.
#! @Args name
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromName");

#! @Description
#!   Attempts to download and install a package by downloading its PackageInfo.g
#!   from the specified URL.
#! @Args url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromInfo");

#! @Description
#!   Attempts to download and install a package from an archive located at the
#!   given URL.
#! @Args url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromArchive");

#! @Description
#!   Attempts to remove an installed package using its name.
#! @Args pkg_name
#! @Returns
#!   true or false
DeclareGlobalFunction("RemovePackage");

DeclareGlobalFunction("PKGMAN_CheckPackage");
DeclareGlobalFunction("PKGMAN_Exec");
DeclareGlobalFunction("PKGMAN_PackageDir");
