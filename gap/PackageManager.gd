#
# PackageManager: Easily download and install &GAP; packages
#
# Declarations
#
#! @Chapter Commands
#! @Section Main commands

#! @Label for a string
#! @Description
#!   Attempts to download and install a package.  The argument <A>string</A>
#!   should be a string containing one of the following:
#!     * the name of a package;
#!     * the URL of a package archive, ending in `.tar.gz` or `.tar.bz2`;
#!     * the URL of a git repository, ending in `.git`;
#!     * the URL of a valid `PackageInfo.g` file.
#!
#!   The package will then be downloaded and installed, along with any
#!   additional packages that are required in order for it to be loaded.  Its
#!   documentation will also be built if necessary.  If the installation is
#!   completed successfully, or if this package is already installed,
#!   <K>true</K> is returned; otherwise, <K>false</K> is returned.
#!
#!   By default, packages will be installed in the `pkg` subdirectory of
#!   <C>GAPInfo.UserGapRoot</C>
#!   (see <Ref BookName="ref" Sect="GAP Root Directories"/>).
#!   Note that this location is not the default user pkg location
#!   on Mac OSX, but it will be created on any system if not already present.
#!   Note also that starting &GAP; with the `-r` flag will cause all packages in
#!   this directory to be ignored.
#!
#!   This command's behaviour is affected by the user preferences that have been
#!   set for the PackageManager package. These can be updated using, for
#!   example, <C>SetUserPreference("PackageManager", "compile", true);</C> but
#!   these can also be overridden for this call by passing a record to this
#!   function, for example <C>InstallPackage(name, rec(compile := false));</C>
#!
#!   The available preferences are as follows:
#!     * <C>dependencies</C> - whether to install the package's dependencies as well
#!     * <C>suggested</C> - whether to include suggested as well as required dependencies
#!     * <C>compile</C> - whether to attempt to compile newly installed packages
#!     * <C>compileDeps</C> - whether to attempt to compile the dependencies of newly installed packages
#!     * <C>upgrade</C> - whether to upgrade already installed packages if an upgrade is available
#!     * <C>git</C> - whether to attempt to pull from Git repos when upgrading
#!     * <C>proceed</C> - whether to proceed with the installation at all (after printing the installation plan)
#!     * <C>interactive</C> - set this to <C>false</C> to disable all interactive prompting (preferences set to "ask" are instead treated as <C>true</C>)
#!     * <C>distroLocation</C> - the URL to download the GAP package distribution info from
#!     * <C>distroVersion</C> - the version of the package distribution info to use (choose a version of GAP, or just "latest")
#!     * <C>version</C> - the version of a particular package to attempt to install
#!
#!   All boolean preferences above (those described as "whether to...") can be set to <C>true</C>, <C>false</C>, or "ask" which will prompt the user interactively. This is the default setting for many of them.
#!
#!   To see more information about the install process while it is ongoing, see
#!   <Ref InfoClass="InfoPackageManager"/>.
#!
#!   If the <C>version</C> preference is specified, then it is interpreted as
#!   described in Section
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
#!   If installation fails, then any new directories that were created will be
#!   preserved. To remove them, the
#!   <Ref Oper="RemovePackage" Label="for a string" /> operation can be used.
#!
#! @BeginExample
#! gap> InstallPackage("digraphs");
#! #I  The following packages will be installed:
#! #I    Digraphs        1.15.0
#! #I    orb             5.1.0
#! #I    datastructures  0.4.3
#! Continue? [Y/n] y
#! true
#! gap> InstallPackage("profiling", rec(interactive := false,
#! >                                    suggested := true,
#! >                                    compileDeps := false));
#! #I  The following packages will be installed:
#! #I    profiling  2.6.3
#! true
#! @EndExample
#!
#! @Arguments string[, prefs]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareOperation("InstallPackage", [IsString]);
DeclareOperation("InstallPackage", [IsString, IsRecord]);

#! @Label for a string
#! @Description
#!   Attempts to remove an installed package using its name.  The first argument
#!   <A>name</A> should be a string specifying the name of a package installed
#!   in the user &GAP; root,
#!   see <Ref BookName="ref" Sect="GAP Root Directories"/>.
#!
#!   This command's behaviour is affected by the user preferences that have been
#!   set for the PackageManager package. These can be set globally, or
#!   overridden for this command using the optional <A>prefs</A> argument, in
#!   the same way as for the
#!   <Ref Oper="InstallPackage" Label="for a string" /> command.
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
#! @Arguments name[, prefs]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareOperation("RemovePackage", [IsString]);
DeclareOperation("RemovePackage", [IsString, IsRecord]);

#! @Section Info warnings

#! @Description
#!   Info class for the <Package>PackageManager</Package> package.  Set this to
#!   the following levels for different levels of information:
#!     * 0 - No messages
#!     * 1 - Problems only: messages describing what went wrong, with no
#!           messages if an operation is successful
#!     * 2 - Directories and versions: also displays informations about package
#!           versions and installation directories
#!     * 3 - Progress: also shows step-by-step progress of operations
#!     * 4 - All: includes extra information such as whether curlInterface is
#!           being used, package info validation and compilation output
#!
#!   Set this using, for example `SetInfoLevel(InfoPackageManager, 1)`.
#!   Default value is 3.
DeclareInfoClass("InfoPackageManager");
SetInfoLevel(InfoPackageManager, 3);

DeclareGlobalFunction("PKGMAN_CheckPackage");
DeclareGlobalFunction("PKGMAN_Exec");
DeclareGlobalFunction("PKGMAN_InfoWithIndent");
DeclareGlobalFunction("PKGMAN_PathSystemProgram");

BindGlobal("PKGMAN_WHITESPACE", MakeImmutable(" \n\t\r"));
