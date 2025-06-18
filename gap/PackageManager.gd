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
DeclareOperation("InstallPackage", [IsString]);
DeclareOperation("InstallPackage", [IsString, IsRecord]);

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
