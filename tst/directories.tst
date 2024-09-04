# Fail to extract due to permissions
gap> dir := Filename(Directory(PKGMAN_PackageDir()), "badpackage");;
gap> CreateDir(dir);
true
gap> PKGMAN_Exec(".", "chmod", "000", dir);
rec( code := 0, output := "" )
gap> PKGMAN_CreateDirRecursively(Filename(Directory(dir), "subfolder"));
#I  Failed to create required directory
fail
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage.tar.gz");
#I  Target location not writable
false
gap> PKGMAN_Exec(".", "chmod", "222", dir);
rec( code := 0, output := "" )
gap> InstallPackage("https://gap-packages.github.io/PackageManager/dummy/badpackage.tar.gz");
#I  Target location not readable
false
gap> PKGMAN_Exec(".", "chmod", "777", dir);
rec( code := 0, output := "" )

# PKGMAN_CustomPackageDir
gap> olddir := PKGMAN_CustomPackageDir;;
gap> PKGMAN_CustomPackageDir := "";;
gap> EndsWith(PKGMAN_PackageDir(), "/.gap/pkg");
true
gap> PKGMAN_CustomPackageDir := olddir;;
gap> PKGMAN_SetCustomPackageDir("/home");  # not ending in pkg
fail
gap> PKGMAN_InsertPackageDirectory("/home");  # not ending in pkg
fail
