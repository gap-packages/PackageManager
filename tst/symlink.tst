# If the user package directory is given through a symlink, it must still
# match the resolved path GAP 4.17 and newer store (gap-system/gap#5930).
gap> olddir := PKGMAN_CustomPackageDir;;
gap> tmp := DirectoryTemporary();;
gap> CreateDir(Filename(tmp, "real"));
true
gap> PKGMAN_Exec(Filename(tmp, ""), "ln", "-s", "real", "link");
rec( code := 0, output := "" )
gap> PKGMAN_Exec(Filename(tmp, ""), "cp", "-r",
>   Filename(DirectoriesPackageLibrary("PackageManager", "tst/data/new"), "pmdummy"),
>   "real/");
rec( code := 0, output := "" )
gap> PKGMAN_InsertPackageDirectory(Filename(tmp, "real"));;
gap> PKGMAN_CustomPackageDir := Filename(tmp, "link");;
gap> Length(PKGMAN_UserPackageInfo("pmdummy"));
1
gap> RemovePackage("pmdummy", false);
true
gap> PKGMAN_CustomPackageDir := olddir;;
