# Try to compile IO (which should be installed but not in the user pkg dir)
gap> CompilePackage("io");
#I  The io package is installed, but not in the user package directory
#I  You can install a user-managed version with InstallPackage("io")
false

# Try to compile something that's not there at all
gap> CompilePackage("madeUpPackage");
#I  No package named "madeUpPackage" is installed
false

# CompilePackage bad input
gap> CompilePackage(3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CompilePackage' on 1 arguments
gap> CompilePackage(true);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CompilePackage' on 1 arguments

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
gap> RemovePackage("toric");
true
