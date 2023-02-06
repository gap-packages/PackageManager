#
# PackageManager: Easily download and install &GAP; packages
#
# Declarations
#
#! @Chapter Commands

#! @Section Installing and updating packages

#! @Description
#!   Attempts to download and install a package.  The argument <A>string</A> should
#!   be a string containing one of the following:
#!     * the name of a package;
#!     * the URL of a package archive, ending in `.tar.gz` or `.tar.bz2`;
#!     * the URL of a git repository, ending in `.git`;
#!     * the URL of a mercurial repository;
#!     * the URL of a valid `PackageInfo.g` file.
#!
#!   The package will then be downloaded and installed, along with any
#!   additional packages that are required in order for it to be loaded.  Its
#!   documentation will also be built if necessary.  If this installation is
#!   successful, or if this package is already installed,
#!   <K>true</K> is returned; otherwise, <K>false</K> is returned.
#!
#!   By default, packages will be installed in the `pkg` subdirectory of the
#!   user's home directory, see <Ref BookName="ref" Func="UserHomeExpand"/>.
#!   Note that this location is not the default user pkg location
#!   on Mac OSX, but it will be created on any system if not already present.
#!   Note also that starting &GAP; with the `-r` flag will cause all packages in
#!   this directory to be ignored.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell &ndash; to avoid this
#!   interactivity and use sane defaults instead, the optional argument
#!   <A>interactive</A> can be set to <K>false</K>.
#!
#!   To see more information about this process while it is ongoing, see
#!   <Ref InfoClass="InfoPackageManager"/>.
#!
#!   If <A>string</A> is the name of the package in question then one can specify
#!   a required package version via a string as value of the optional argument
#!   <A>version</A>, which is interpreted as described in Section
#!   <Ref Sect="Version Numbers" BookName="ref"/>.
#!   In particular, if <A>version</A> starts with `=` then the
#!   function will try to install exactly the given version, and otherwise
#!   it will try to install a version that is not smaller than the given one.
#!   If an installed version satisfies the condition on the version then
#!   <K>true</K> is returned without an attempt to upgrade the package.
#!   If the package is not yet installed or if no installed version satisfies
#!   the version condition then an upgrade is tried only if the package version
#!   that is listed on the &GAP; webpages satisfies the condition.
#!   (The function will not update a dev version of the package if a version
#!   number is prescribed;
#!   otherwise it could happen that one updates the installation and
#!   afterwards notices that the version condition is still not satisfied.)
#!
#! @BeginExample
#! gap> InstallPackage("digraphs");
#! true
#! @EndExample
#!
#! @Arguments string[, version][, interactive]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackage");

#! @Description
#!   Attempts to update an installed package to the latest version.  The first
#!   argument <A>name</A> should be a string specifying the name of a package
#!   installed in the user &GAP; root (for example, one installed using <Ref
#!   Func="InstallPackage" />),
#!   see <Ref BookName="ref" Sect="GAP Root Directories"/>.
#!   The second argument <A>interactive</A> is optional,
#!   and should be a boolean specifying whether to confirm interactively before
#!   any directories are deleted (default value <K>true</K>).
#!
#!   If the package was installed via archive, the new version will be installed
#!   in a new directory, and the old version will be deleted.  If installed via
#!   git or mercurial, it will be updated using `git pull` or `hg pull -u`, so
#!   long as there are no outstanding changes.  If no newer version is
#!   available, no changes will be made.
#!
#!   This process will also attempt to fix the package if it is broken, for
#!   example if it needs to be recompiled or if one of its dependencies is
#!   missing or broken.
#!
#!   Returns <K>true</K> if a newer version was installed successfully, or if no
#!   newer version is available.  Returns <K>false</K> otherwise.
#!
#! @BeginExample
#! gap> UpdatePackage("io");
#! #I  io version 4.6.0 will be installed, replacing 4.5.4
#! #I  Saved archive to /tmp/tm7r5Ug7/io-4.6.0.tar.gz
#! Remove old version of io at /home/user/.gap/pkg/io-4.5.4 ? [y/N] y
#! true
#! @EndExample
#!
#! @Arguments name[, interactive]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("UpdatePackage");

#! @Description
#!   Attempts to compile an installed package.  Takes one argument <A>name</A>, which
#!   should be a string specifying the name of a package installed in the user
#!   &GAP; root (for example, one installed using <Ref Func="InstallPackage" />),
#!   see <Ref BookName="ref" Sect="GAP Root Directories"/>.
#!   Compilation is done automatically when a package is installed or updated,
#!   so in most cases this command is not needed.  However, it may sometimes be
#!   necessary to recompile some packages if you update or move your &GAP;
#!   installation.
#!
#!   Compilation is done using the `etc/BuildPackages.sh` script bundled with
#!   &PackageManager;.  If the specified package does not have a compiled component, this
#!   function should have no effect.
#!
#!   Returns <K>true</K> if compilation was successful or if no compilation was
#!   necessary.  Returns <K>false</K> otherwise.
#!
#! @BeginExample
#! gap> CompilePackage("orb");
#! #I  Running compilation script on /home/user/.gap/pkg/orb-4.8.3 ...
#! true
#! @EndExample
#!
#! @Arguments name
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("CompilePackage");

#! @Description
#!   Info class for the <Package>PackageManager</Package> package.  Set this to the following
#!   levels for different levels of information:
#!     * 0 - No messages
#!     * 1 - Problems only: messages describing what went wrong, with no
#!           messages if an operation is successful
#!     * 2 - Directories and versions: also displays informations about package
#!           versions and installation directories
#!     * 3 - Progress: also shows step-by-step progress of operations
#!     * 4 - All: includes extra information such as whether curlInterface is
#!           being used
#!
#!   Set this using, for example `SetInfoLevel(InfoPackageManager, 1)`.
#!   Default value is 3.
DeclareInfoClass("InfoPackageManager");
SetInfoLevel(InfoPackageManager, 3);

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
#!   Attempts to download and install a package from a valid `PackageInfo.g` file.
#!   The argument <A>info</A> should be either a valid package info record, or a URL
#!   that points to a valid `PackageInfo.g` file.  Returns <K>true</K> if the
#!   installation was successful, and <K>false</K> otherwise.
#! @Arguments info
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromInfo");

#! @Description
#!   Attempts to download and install a package from an archive located at the
#!   given URL.  Returns <K>true</K> if the installation was successful, and <K>false</K>
#!   otherwise.
#! @Arguments url
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromArchive");

#! @Description
#!   Attempts to download and install a package from a git repository located at
#!   the given URL.  Returns <K>false</K> if something went wrong, and <K>true</K>
#!   otherwise.
#!
#!   If the optional string argument <A>branch</A> is specified, this function will
#!   install the branch with this name.  Otherwise, the repository's default
#!   branch will be used.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell &ndash; to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   <A>interactive</A> can be set to <K>false</K>.
#! @Arguments url[, interactive][, branch]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromGit");

#! @Description
#!   Attempts to download and install a package from a Mercurial repository
#!   located at the given URL.  Returns <K>false</K> if something went wrong, and
#!   <K>true</K> otherwise.
#!
#!   If the optional string argument <A>branch</A> is specified, this function will
#!   install the branch with this name.  Otherwise, the repository's default
#!   branch will be used.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell &ndash; to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   <A>interactive</A> can be set to <K>false</K>.
#! @Arguments url[, interactive][, branch]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallPackageFromHg");

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
#!   managed by <Package>PackageManager</Package> in the future, and are available for other &GAP;
#!   installations on the machine.
#! @Arguments
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("InstallRequiredPackages");

#! @Section Removing packages

#! @Description
#!   Attempts to remove an installed package using its name.  The first argument
#!   <A>name</A> should be a string specifying the name of a package installed in the
#!   user &GAP; root,
#!   see <Ref BookName="ref" Sect="GAP Root Directories"/>.
#!   The second argument <A>interactive</A> is optional, and should
#!   be a boolean specifying whether to confirm certain decisions interactively
#!   (default value <K>true</K>).
#!
#!   Returns <K>true</K> if the removal was successful, and <K>false</K> otherwise.
#!
#! @BeginExample
#! gap> RemovePackage("digraphs");
#! Really delete directory /home/user/.gap/pkg/digraphs-0.13.0 ? [y/N] y
#! true
#! @EndExample
#!
#! @Arguments name[, interactive]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("RemovePackage");

DeclareGlobalFunction("GetPackageURLs");

# Hidden functions
DeclareGlobalFunction("PKGMAN_InstallDependencies");
DeclareGlobalFunction("PKGMAN_CheckPackage");
DeclareGlobalFunction("PKGMAN_CompileDir");
DeclareGlobalFunction("PKGMAN_MakeDoc");
DeclareGlobalFunction("PKGMAN_Exec");
DeclareGlobalFunction("PKGMAN_NameOfGitRepo");
DeclareGlobalFunction("PKGMAN_NameOfHgRepo");
DeclareGlobalFunction("PKGMAN_PackageDir");
DeclareGlobalFunction("PKGMAN_CreateDirRecursively");
DeclareGlobalFunction("PKGMAN_IsValidTargetDir");
DeclareGlobalFunction("PKGMAN_RefreshPackageInfo");
DeclareGlobalFunction("PKGMAN_InsertPackageDirectory");
DeclareGlobalFunction("PKGMAN_SetCustomPackageDir");
DeclareGlobalFunction("PKGMAN_DownloadURL");
DeclareGlobalFunction("PKGMAN_RemoveDir");
DeclareGlobalFunction("PKGMAN_DownloadPackageInfo");
DeclareGlobalFunction("PKGMAN_InfoWithIndent");

# Hidden variables
PKGMAN_CustomPackageDir := "";
PKGMAN_PackageInfoURLList :=
  "https://github.com/gap-system/PackageDistro/releases/download/latest/pkglist.csv";
PKGMAN_ArchiveFormats := [".tar.gz", ".tar.bz2"];
PKGMAN_DownloadCmds := [ [ "wget", ["--quiet", "-O", "-"] ],
                         [ "curl", ["--silent", "-L", "--output", "-"] ] ];
PKGMAN_CurlIntReqVer :=
  First(PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages,
        item -> item[1] = "curlInterface")[2];
PKGMAN_BuildPackagesScript := Filename(DirectoriesPackageLibrary("PackageManager", "etc"),
                                       "BuildPackages.sh");
PKGMAN_Sysinfo := Filename(DirectoriesLibrary(""), "sysinfo.gap");
PKGMAN_InstallQueue := [];      # Queue of dependencies to install
PKGMAN_MarkedForInstall := [];  # Packages currently halfway through installing
