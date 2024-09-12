# Try to compile IO (which should be installed but not in the user pkg dir)
gap> CompilePackage("io");
#I  Package "io" not installed in user package directory
false

# Try to compile something that's not there at all
gap> CompilePackage("madeUpPackage");
#I  Package "madeUpPackage" not installed in user package directory
false

# Check package can be recompiled and removed
gap> InstallPackage("example");
true
gap> CompilePackage("example");
true
gap> RemovePackage("example", false);
true

# CompilePackage bad input
gap> CompilePackage(3);
Error, <name> must be a string
gap> CompilePackage(true);
Error, <name> must be a string

# PKGMAN_CompileDir error: no shell
gap> InstallPackage("example");
true
gap> InstallPackage("example");  # latest version already installed
true
gap> progs := GAPInfo.DirectoriesPrograms;;
gap> GAPInfo.DirectoriesPrograms := [];;  # terrible vandalism
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No shell available called "sh"
#I  Compilation failed for package 'Example'
#I  (package may still be usable)
false
gap> GAPInfo.DirectoriesPrograms := progs;;

# PKGMAN_CompileDir error: no etc/BuildPackages.sh
gap> InstallPackage("example", false);
true
gap> sysinfo_scr := PKGMAN_Sysinfo;;
gap> PKGMAN_Sysinfo := fail;;
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> PKGMAN_CompileDir(dir);
#I  No sysinfo.gap found
false
gap> PKGMAN_Sysinfo := sysinfo_scr;;

# PKGMAN_CompileDir error: missing source
gap> InstallPackage("example");
true
gap> dir := PackageInfo("example")[1].InstallationPath;;
gap> RemoveFile(Filename(Directory(dir), "src/hello.c"));
true
gap> PKGMAN_CompileDir(dir);
#I  Compilation failed for package 'Example'
#I  (package may still be usable)
false

# Missing BuildPackages script
gap> temp := PKGMAN_BuildPackagesScript;;
gap> PKGMAN_BuildPackagesScript := fail;;
gap> CompilePackage("example");
#I  Compilation script not found
false
gap> PKGMAN_BuildPackagesScript := temp;;
gap> RemovePackage("example", false);
true

# Compile already compiled
gap> InstallPackage("toric");
true
gap> CompilePackage("toric");
true
