#! @Chapter PackageManager
#! @Section Directories

#! @Description
#!   Returns the directory that is currently being used by <Package>PackageManager</Package> for installing and removing packages. This is the only directory in the file system where <Package>PackageManager</Package> will add, delete or modify any files. It can be modified using <Ref Func="ChangeDirectoryPackageManager"/>.
#! @Arguments
#! @Returns
#!   a directory object
DeclareGlobalFunction("DirectoryPackageManager");

#! @Description
#!   Changes the directory used by <Package>PackageManager</Package> for installing and removing packages. See <Ref Func="DirectoryPackageManager"/>.
#!
#!   The argument <A>path</A> should be a string that represents a path to a directory. It will be created if it does not exist.
#!
#!   Returns <K>true</K> on success and <K>fail</K> on failure.
#! @Arguments path
#! @Returns
#!   <K>true</K> or <K>fail</K>
DeclareGlobalFunction("ChangeDirectoryPackageManager");

DeclareGlobalFunction("PKGMAN_CreateDirRecursively");
DeclareGlobalFunction("PKGMAN_InsertPackageDirectory");
DeclareGlobalFunction("PKGMAN_IsValidTargetDir");
DeclareGlobalFunction("PKGMAN_RemoveDirOptional");
DeclareGlobalFunction("PKGMAN_RemoveDir");
DeclareGlobalFunction("PKGMAN_GapRootDir");

PKGMAN_CustomPackageDir := "";  # Empty indicates no custom directory
PKGMAN_Sysinfo := Filename(DirectoriesLibrary(""), "sysinfo.gap");
