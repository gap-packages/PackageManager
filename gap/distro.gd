#
# Installing packages from the GAP package distribution.
#
# This functionality is used when specifying a package name, or when
# automatically installing dependencies.
#

#! @Description
#!   Attempts to download and install a package given only its name.  Returns
#!   <K>false</K> if something went wrong, and <K>true</K> otherwise.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell &ndash; to avoid this
#!   interactivity and use sane defaults instead, the optional argument
#!   <A>interactive</A> can be set to <K>false</K>.
#!
#!   A required version can also be specified using the optional argument
#!   <A>version</A>.  It works as described in the <Ref Func="InstallPackage" />
#!   function.
#! @Arguments name[, version][, interactive]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromName");

#! @Description
#!   Attempts to download and install the latest versions of all packages
#!   required for &GAP; to run.  Currently these packages are
#!   <Package>GAPDoc</Package>, <Package>primgrp</Package>,
#!   <Package>SmallGrp</Package>, and <Package>transgrp</Package>.
#!   Returns <K>false</K> if something went wrong, and
#!   <K>true</K> otherwise.
#!
#!   Clearly, since these packages are required for &GAP; to run, they must be
#!   loaded before this function can be executed.  However, this function
#!   installs the packages in the `~/.gap/pkg` directory, so that they can be
#!   managed by <Package>PackageManager</Package> in the future, and are
#!   available for other &GAP; installations on the machine.
#! @Arguments
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallRequiredPackages");

DeclareGlobalFunction("GetPackageURLs");
DeclareGlobalFunction("PKGMAN_InstallDependencies");

PKGMAN_PackageInfoURLList :=    # Source of latest package releases
  Concatenation("https://github.com/gap-system/PackageDistro/",
                "releases/download/latest/pkglist.csv");
PKGMAN_InstallQueue := [];      # Queue of dependencies to install
PKGMAN_MarkedForInstall := [];  # Packages currently halfway through installing
