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
#!   Attempts to download and install a package from its name
#! @Args pkg_name
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageName");

#! @Description
#!   Attempts to download and install a package from its URL
#! @Args url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageURL");

#! @Description
#!   Attempts to remove an installed package
#! @Args pkg_name
#! @Returns
#!   true or false
DeclareGlobalFunction("RemovePackage");
