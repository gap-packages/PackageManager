#
# Installing packages from the GAP package distribution.
#
# This functionality is used when specifying a package name, or when
# automatically installing dependencies.
#

#! @Chapter Commands
#! @Section Main commands

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
DeclareOperation("InstallRequiredPackages", []);
DeclareOperation("InstallRequiredPackages", [IsRecord]);

DeclareOperation("RefreshPackageMetadata", []);
DeclareOperation("RefreshPackageMetadata", [IsRecord]);

DeclareGlobalFunction("InstallPackageFromName");

DeclareGlobalFunction("PKGMAN_InstallRequirements");
DeclareGlobalFunction("PKGMAN_InstallationPlan");
DeclareGlobalFunction("PKGMAN_PullOrExtractPackage");
DeclareGlobalFunction("PKGMAN_UnsatisfiedRequirements");
DeclareGlobalFunction("PKGMAN_DependencyGraph");
DeclareGlobalFunction("PKGMAN_PlanFromGraph");
DeclareGlobalFunction("PKGMAN_ShowInstallationPlan");

# Source of latest package releases
PKGMAN_PackageMetadataCache := rec();  # TODO: change name
DeclareGlobalFunction("PKGMAN_PackageMetadata");  # TODO: change name
DeclareGlobalFunction("PKGMAN_MetadataUrl");
