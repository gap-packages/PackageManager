#
# PackageManager: Easily download and install GAP packages
#
# Declarations
#
#! @Chapter Commands

#! @Section Installing packages

#! @Description
#!   Attempts to download and install a package.  The argument <A>string</A>
#!   should be a string containing one of the following:
#!     * the name of a package;
#!     * the URL of a package archive, ending in <C>.tar.gz</C>;
#!     * the URL of a git repository, ending in <C>.git</C>;
#!     * the URL of a mercurial repository, ending in <C>.hg</C>;
#!     * the URL of a valid <C>PackageInfo.g</C> file.
#!
#!   The package will then be downloaded and installed, along with any
#!   additional packages that are required in order for it to be loaded.  If
#!   this installation is successful, <K>true</K> is returned; otherwise,
#!   <K>false</K> is returned.
#!
#!   By default, packages will be installed in user's home directory at
#!   <C>~/.gap/pkg</C>.  Note that this location is not the default user pkg
#!   location on Mac OSX, but it will be created on any system if not already
#!   present.  Note also that starting GAP with the <C>-r</C> flag will cause
#!   all packages in this directory to be ignored.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell - to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   <A>interactive</A> can be set to <K>false</K>.
#!
#!   To see more information about this process while it is ongoing, see
#!   <C>InfoPackageManager</C>.
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
#!   Info class for the PackageManager package.  Set this to the following
#!   levels for different levels of information:
#!     * 0 - No messages
#!     * 1 - Problems only: messages describing what went wrong, with no
#!           messages if an operation is successful
#!     * 2 - Problems and directories: also displays directories that were used
#!           for package installation or removal
#!     * 3 - Progress: also shows step-by-step progress of operations
#!     * 4 - All: includes extra information such as whether curlInterface is
#!           being used
#!
#!   Set this using, for example <C>SetInfoLevel(InfoPackageManager, 1)</C>.
#!   Default value is 3.
DeclareInfoClass("InfoPackageManager");
SetInfoLevel(InfoPackageManager, 3);

#! @Description
#!   Attempts to download and install a package given only its name.  Returns
#!   <K>true</K> if the installation was successful, and <K>false</K> otherwise.
#!
#!   Certain decisions, such as installing newer versions of packages, will be
#!   confirmed by the user via an interactive shell - to avoid this
#!   interactivity and use sane defaults instead, the optional second argument
#!   <A>interactive</A> can be set to <K>false</K>.
#! @Arguments name[, interactive]
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromName");

#! @Description
#!   Attempts to download and install a package from a valid PackageInfo.g file.
#!   The argument <A>info</A> should be either a valid package info record, or a
#!   URL that points to a valid PackageInfo.g file.  Returns <K>true</K> if the
#!   installation was successful, and <K>false</K> otherwise.
#! @Arguments info
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromInfo");

#! @Description
#!   Attempts to download and install a package from an archive located at the
#!   given URL.  Returns <K>true</K> if the installation was successful, and
#!   <K>false</K> otherwise.
#! @Arguments url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromArchive");

#! @Description
#!   Attempts to download and install a package from a git repository located at
#!   the given URL.  Returns <K>true</K> if the installation was successful, and
#!   <K>false</K> otherwise.
#! @Arguments url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromGit");

#! @Description
#!   Attempts to download and install a package from a Mercurial repository
#!   located at the given URL.  Returns <K>true</K> if the installation was
#!   successful, and <K>false</K> otherwise.
#! @Arguments url
#! @Returns
#!   true or false
DeclareGlobalFunction("InstallPackageFromHg");

#! @Section Removing packages

#! @Description
#!   Attempts to remove an installed package using its name.  The first argument
#!   <A>name</A> should be a string specifying the name of a package installed
#!   in the user GAP root.  The second argument <A>interactive</A> is optional,
#!   and should be a boolean specifying whether to confirm interactively before
#!   any directories are deleted (default value <K>true</K>).
#!
#!   Returns <K>true</K> if the removal was successful, and <K>false</K>
#!   otherwise.
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
PKGMAN_DownloadCmds := [ [ "wget", ["--quiet", "-O", "-"] ],
                         [ "curl", ["--silent", "-L", "--output", "-"] ] ];
PKGMAN_CurlIntReqVer :=
  First(PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages,
        item -> item[1] = "curlInterface")[2];
PKGMAN_BuildPackagesScript := Filename(List(GAPInfo.RootPaths, Directory),
                                       "bin/BuildPackages.sh");
PKGMAN_MarkedForInstall := [];
