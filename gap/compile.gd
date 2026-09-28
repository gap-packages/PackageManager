#! @Chapter Commands
#! @Section Manual compilation

#! @Label for a string
#! @Description
#!   Attempts to compile an installed package.  Takes one argument <A>name</A>,
#!   which should be a string specifying the name of a package installed in the
#!   user &GAP; root (for example, one installed using
#!   <Ref Oper="InstallPackage" Label="for a string" />), see
#!   <Ref BookName="ref" Sect="GAP Root Directories"/>.
#!   Compilation is done automatically when a package is
#!   installed or updated, so in most cases this command is not needed.
#!   However, it may sometimes be necessary to recompile some packages if you
#!   update or move your &GAP; installation.
#!
#!   Compilation is done using the `etc/BuildPackages.sh` script bundled with
#!   &PackageManager;.  If the specified package does not have a compiled
#!   component, this function should have no effect.
#!
#!   This command's behaviour is affected by the user preferences that have been
#!   set for the PackageManager package. These can be set globally, or
#!   overridden for this command using the optional <A>prefs</A> argument, in
#!   the same way as for the
#!   <Ref Oper="InstallPackage" Label="for a string" /> command.
#!
#!   Returns <K>true</K> if compilation was successful or if no compilation was
#!   necessary.  Returns <K>false</K> otherwise.
#!
#! @BeginExample
#! gap> CompilePackage("digraphs");
#! #I  Running compilation script on /home/mtorpey/.gap/pkg/datastructures-0.4.3/ ...
#! #I  Running compilation script on /home/mtorpey/.gap/pkg/orb-5.1.0/ ...
#! #I  Running compilation script on /home/mtorpey/.gap/pkg/io-4.10.0/ ...
#! #I  Running compilation script on /home/mtorpey/.gap/pkg/digraphs-1.15.0/ ...
#! true
#! gap> CompilePackage("profiling", rec(compileDeps := false));
#! #I  Running compilation script on /home/mtorpey/.gap/pkg/profiling-2.6.3/ ...
#! true
#! @EndExample
#!
#! @Arguments name[, prefs]
#! @Returns
#!   <K>true</K> or <K>false</K>
DeclareOperation("CompilePackage", [IsString]);
DeclareOperation("CompilePackage", [IsString, IsRecord]);

DeclareGlobalFunction("PKGMAN_CompilePackageByName");
DeclareGlobalFunction("PKGMAN_CompileDir");

PKGMAN_BuildPackagesScript :=
  Filename(DirectoriesPackageLibrary("PackageManager", "etc"), "BuildPackages.sh");
