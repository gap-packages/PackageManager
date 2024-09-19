#
# PackageManager: Easily download and install &GAP; packages
#
# Declarations
#
#! @Chapter Commands
#! @Section Main commands

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
#!   If installation fails, then any new directories that were created will be
#!   removed.  To override this behaviour, the option <K>keepDirectory</K> can
#!   be set to <K>true</K> using, for example,
#!   <C>InstallPackage("example" : keepDirectory)</C>,
#!   in which case such directories will be preserved for debugging.
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
#!   git, it will be updated using `git pull`, so
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
#!   Attempts to remove an installed package using its name.  The first argument
#!   <A>name</A> should be a string specifying the name of a package installed
#!   in the user &GAP; root,
#!   see <Ref BookName="ref" Sect="GAP Root Directories"/>.
#!   The second argument <A>interactive</A> is optional, and should
#!   be a boolean specifying whether to confirm certain decisions interactively
#!   (default value <K>true</K>).
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
#!   <K>true</K> or <K>false</K>
DeclareGlobalFunction("RemovePackage");

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
#!           being used, and package info validation
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
