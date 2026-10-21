#
# Installing packages from the GAP package distribution.
#
# This functionality is used when specifying a package name, or when
# automatically installing dependencies.
#

#! @Chapter PackageManager
#! @Section Commands

#! @Label with no required arguments
#! @Description
#!   Attempts to download and install the latest versions of all packages
#!   required for &GAP; to run.  Currently these packages are
#!   <Package>GAPDoc</Package>,
#!   <Package>PerfGrp</Package>,
#!   <Package>PrimGrp</Package>,
#!   <Package>SmallGrp</Package>, and
#!   <Package>TransGrp</Package>.
#!   Returns <K>false</K> if something went wrong, and <K>true</K> otherwise.
#!
#!   If these required packages are not currently installed, &GAP; can still be
#!   loaded with the  `--bare` option, which is sufficient to allow
#!   <Package>PackageManager</Package> to be loaded and this command to be run.
#!
#!   This command's behaviour is affected by the user preferences that have been
#!   set for the PackageManager package. These can be set globally, or
#!   overridden for this command using the optional <A>prefs</A> argument, in
#!   the same way as for the <Ref Oper="InstallPackage" Label="for a string" />
#!   command.
#!
#! @Arguments [prefs]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareOperation("InstallRequiredPackages", []);
DeclareOperation("InstallRequiredPackages", [IsRecord]);

#! @Label with no required arguments
#! @Description
#!   Attempts to upgrade all packages to their latest version.
#!   Returns <K>false</K> if something went wrong, and <K>true</K> otherwise.
#!
#!   Only packages in the directory managed by <Package>PackageManager</Package>
#!   will be considered. See Section
#!   <Ref Sect="Chapter_PackageManager_Section_Directories" /> for more details.
#!
#!   This command's behaviour is affected by the user preferences that have been
#!   set for the PackageManager package. These can be set globally, or
#!   overridden for this command using the optional <A>prefs</A> argument, in
#!   the same way as for the <Ref Oper="InstallPackage" Label="for a string" />
#!   command.
#!
#! @Arguments [prefs]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareOperation("UpgradeAllPackages", []);
DeclareOperation("UpgradeAllPackages", [IsRecord]);

#! @Label with no required arguments
#! @Description
#!   Attempts to download metadata for all available packages from the &GAP;
#!   package distribution.
#!
#!   Calling this function is not usually necessary, since the metadata is
#!   downloaded automatically the first time
#!   <Ref Oper="InstallPackage" Label="for a string" /> is called, and the
#!   result is cached for the rest of the &GAP; session. However, this command
#!   can be called to force the download and retrieve any updated information,
#!   which may be useful, for example, if the `distroLocation` or
#!   `distroVersion` user preferences have been changed, or if new package
#!   versions may have been added to the distribution online since this &GAP; 
#!   session started.
#!
#!   Returns <K>false</K> if something went wrong, and <K>true</K> otherwise.
#!
#!   This command's behaviour is affected by the user preferences that have been
#!   set for the PackageManager package. These can be set globally, or
#!   overridden for this command using the optional <A>prefs</A> argument, in
#!   the same way as for the <Ref Oper="InstallPackage" Label="for a string" />
#!   command.
#!
#! @Arguments [prefs]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareOperation("RefreshPackageMetadata", []);
DeclareOperation("RefreshPackageMetadata", [IsRecord]);

DeclareGlobalFunction("PKGMAN_InstallFromName");

DeclareGlobalFunction("PKGMAN_InstallRequirements");
DeclareGlobalFunction("PKGMAN_InstallationPlan");
DeclareGlobalFunction("PKGMAN_PullOrExtractPackage");
DeclareGlobalFunction("PKGMAN_UnsatisfiedRequirements");
DeclareGlobalFunction("PKGMAN_DependencyGraph");
DeclareGlobalFunction("PKGMAN_PlanFromGraph");
DeclareGlobalFunction("PKGMAN_ShowInstallationPlan");
DeclareGlobalFunction("PKGMAN_InstallDependencies");

# Source of latest package releases
PKGMAN_PackageMetadataCache := rec();
DeclareGlobalFunction("PKGMAN_PackageMetadata");
DeclareGlobalFunction("PKGMAN_MetadataUrl");
