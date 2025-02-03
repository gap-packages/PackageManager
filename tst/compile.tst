# Try to compile IO (which should be installed but not in the user pkg dir)
gap> CompilePackage("io");
#I  Package "io" not installed in user package directory
false

# Try to compile something that's not there at all
gap> CompilePackage("madeUpPackage");
#I  Package "madeUpPackage" not installed in user package directory
false

# CompilePackage bad input
gap> CompilePackage(3);
Error, <name> must be a string
gap> CompilePackage(true);
Error, <name> must be a string

# Compile already compiled
gap> InstallPackage("toric");
true
gap> CompilePackage("toric");
true

# Missing BuildPackages script
gap> temp := PKGMAN_BuildPackagesScript;;
gap> PKGMAN_BuildPackagesScript := fail;;
gap> CompilePackage("toric");
#I  Compilation script not found
false
gap> PKGMAN_BuildPackagesScript := temp;;
gap> RemovePackage("toric", false);
true
