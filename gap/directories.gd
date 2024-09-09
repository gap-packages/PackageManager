DeclareGlobalFunction("PKGMAN_PackageDir");
DeclareGlobalFunction("PKGMAN_SetCustomPackageDir");
DeclareGlobalFunction("PKGMAN_CreateDirRecursively");
DeclareGlobalFunction("PKGMAN_InsertPackageDirectory");
DeclareGlobalFunction("PKGMAN_IsValidTargetDir");
DeclareGlobalFunction("PKGMAN_RemoveDirOptional");
DeclareGlobalFunction("PKGMAN_RemoveDir");

PKGMAN_CustomPackageDir := "";
PKGMAN_Sysinfo := Filename(DirectoriesLibrary(""), "sysinfo.gap");
