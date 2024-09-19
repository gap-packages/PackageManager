#! @Chapter Commands
#! @Section Manual compilation

#! @Description
#!   Attempts to compile an installed package.  Takes one argument <A>name</A>,
#!   which should be a string specifying the name of a package installed in the
#!   user &GAP; root (for example, one installed using <Ref
#!   Func="InstallPackage" />), see <Ref BookName="ref" Sect="GAP Root
#!   Directories"/>.  Compilation is done automatically when a package is
#!   installed or updated, so in most cases this command is not needed.
#!   However, it may sometimes be necessary to recompile some packages if you
#!   update or move your &GAP; installation.
#!
#!   Compilation is done using the `etc/BuildPackages.sh` script bundled with
#!   &PackageManager;.  If the specified package does not have a compiled
#!   component, this function should have no effect.
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

DeclareGlobalFunction("PKGMAN_CompileDir");

PKGMAN_BuildPackagesScript :=
  Filename(DirectoriesPackageLibrary("PackageManager", "etc"), "BuildPackages.sh");
