#
# PackageManager: Easily download and install GAP packages
#
# Declarations
#
#! @Chapter Commands

#! @Section Installing and updating packages

#! @Description
#!   Attempts to download and install a package.  The argument `string` should
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
#!   successful, or if this package is already installed, `true` is returned;
#!   otherwise, `false` is returned.
#!
#!   By default, packages will be installed in user's home directory at
#!   `~/.gap/pkg`.  Note that this location is not the default user pkg location
#!   on Mac OSX, but it will be created on any system if not already present.
#!   Note also that starting GAP with the `-r` flag will cause all packages in
#!   this directory to be ignored.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell - to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   `interactive` can be set to `false`.
#!
#!   To see more information about this process while it is ongoing, see
#!   `InfoPackageManager`.
#!
#! @BeginExample
#! gap> InstallPackage("digraphs");
#! true
#! @EndExample
#!
#! @Arguments string[, interactive]
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackage");

#! @Description
#!   Attempts to update an installed package to the latest version.  The first
#!   argument `name` should be a string specifying the name of a package
#!   installed in the user GAP root (for example, one installed using <Ref
#!   Func="InstallPackage" />).  The second argument `interactive` is optional,
#!   and should be a boolean specifying whether to confirm interactively before
#!   any directories are deleted (default value `true`).
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
#!   Returns `true` if a newer version was installed successfully, or if no
#!   newer version is available.  Returns `false` otherwise.
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
#!   true or false
DeclareGlobalFunction("UpdatePackage");

#! @Description
#!   Info class for the PackageManager package.  Set this to the following
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
#!   `false` if something went wrong, and `true` otherwise.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell - to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   `interactive` can be set to `false`.
#! @Arguments name[, interactive]
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromName");

#! @Description
#!   Attempts to download and install a package from a valid PackageInfo.g file.
#!   The argument `info` should be either a valid package info record, or a URL
#!   that points to a valid PackageInfo.g file.  Returns `true` if the
#!   installation was successful, and `false` otherwise.
#! @Arguments info
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromInfo");

#! @Description
#!   Attempts to download and install a package from an archive located at the
#!   given URL.  Returns `true` if the installation was successful, and `false`
#!   otherwise.
#! @Arguments url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromArchive");

#! @Description
#!   Attempts to download and install a package from a git repository located at
#!   the given URL.  Returns `false` if something went wrong, and `true`
#!   otherwise.
#!
#!   If the optional string argument `branch` is specified, this function will
#!   install the branch with this name.  Otherwise, the repository's default
#!   branch will be used.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell - to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   `interactive` can be set to `false`.
#! @Arguments url[, interactive][, branch]
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromGit");

#! @Description
#!   Attempts to download and install a package from a Mercurial repository
#!   located at the given URL.  Returns `false` if something went wrong, and
#!   `true` otherwise.
#!
#!   If the optional string argument `branch` is specified, this function will
#!   install the branch with this name.  Otherwise, the repository's default
#!   branch will be used.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell - to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   `interactive` can be set to `false`.
#! @Arguments url[, interactive][, branch]
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromHg");

#! @Description
#!   Attempts to download and install the latest versions of all packages
#!   required for GAP to run.  Currently these packages are GAPDoc, primgrp,
#!   SmallGrp, and transgrp.  Returns `false` if something went wrong, and
#!   `true` otherwise.
#!
#!   Clearly, since these packages are required for GAP to run, they must be
#!   loaded before this function can be executed.  However, this function
#!   installs the packages in the `~/.gap/pkg` directory, so that they can be
#!   managed by PackageManager in the future, and are available for other GAP
#!   installations on the machine.
#! @Arguments
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallRequiredPackages");

#! @Section Removing packages

#! @Description
#!   Attempts to remove an installed package using its name.  The first argument
#!   `name` should be a string specifying the name of a package installed in the
#!   user GAP root.  The second argument `interactive` is optional, and should
#!   be a boolean specifying whether to confirm certain decisions interactively
#!   (default value `true`).
#!
#!   Returns `true` if the removal was successful, and `false` otherwise.
#!
#! @BeginExample
#! gap> RemovePackage("digraphs");
#! Really delete directory /home/user/.gap/pkg/digraphs-0.13.0 ? [y/N] y
#! true
#! @EndExample
#!
#! @Arguments name[, interactive]
#! @Returns
#!   true or false
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

# Hidden variables
PKGMAN_CustomPackageDir := "";
PKGMAN_PackageInfoURLList :=
  Concatenation("https://raw.githubusercontent.com/gap-system/",
                "gap-distribution/master/DistributionUpdate/",
                "PackageUpdate/currentPackageInfoURLList");
PKGMAN_ArchiveFormats := [".tar.gz", ".tar.bz2"];
PKGMAN_DownloadCmds := [ [ "wget", ["--quiet", "-O", "-"] ],
                         [ "curl", ["--silent", "-L", "--output", "-"] ] ];
PKGMAN_CurlIntReqVer :=
  First(PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages,
        item -> item[1] = "curlInterface")[2];
PKGMAN_BuildPackagesScript := Filename(List(GAPInfo.RootPaths, Directory),
                                       "bin/BuildPackages.sh");
PKGMAN_InstallQueue := [];      # Queue of dependencies to install
PKGMAN_MarkedForInstall := [];  # Packages currently halfway through installing
