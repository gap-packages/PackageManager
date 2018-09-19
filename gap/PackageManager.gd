#
# PackageManager: Easily download and install GAP packages
#
# Declarations
#

#! @Description
#!   Attempts to download and install a package.  The argument <A>string</A>
#!   should be a string containing one of the following:
#!     * the name of a package;
#!     * the URL of a package archive, ending in <C>.tar.gz</C>;
#!     * the URL of a git repository, ending in <C>.git</C>;
#!     * the URL of a valid <C>PackageInfo.g</C> file.
#!   The package will then be downloaded and installed in the user's pkg folder
#!   at <C>~/.gap/pkg</C>, if possible.  If this installation is successful,
#!   <K>true</K> is returned; otherwise, <K>false</K> is returned.  To see more
#!   information about this process while it is ongoing, see
#!   <C>InfoPackageManager</C>.
#! @Args string
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackage");

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
#!   Attempts to download and install a package from a git repository located at
#!   the given URL.
#! @Args url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromGit");

#! @Description
#!   Attempts to remove an installed package using its name.
#! @Args pkg_name
#! @Returns
#!   true or false
DeclareGlobalFunction("RemovePackage");

# Hidden functions
DeclareGlobalFunction("PKGMAN_CheckPackage");
DeclareGlobalFunction("PKGMAN_Exec");
DeclareGlobalFunction("PKGMAN_NameOfGitRepo");
DeclareGlobalFunction("PKGMAN_PackageDir");

# Hidden variables
PKGMAN_CustomPackageDir := "";
PKGMAN_PackageInfoURLList :=
  Concatenation("https://raw.githubusercontent.com/gap-system/",
                "gap-distribution/master/DistributionUpdate/",
                "PackageUpdate/currentPackageInfoURLList");
