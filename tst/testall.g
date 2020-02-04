#
# PackageManager: Easily download and install GAP packages
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage("PackageManager");

# Info levels
SetInfoLevel(InfoPackageManager, 1);

# Use a temporary directory for packages
PKGMAN_SetCustomPackageDir(Filename(DirectoryTemporary(), "pkg"));

# Any files to exclude?
if not IsBound(PKGMAN_ExcludeTestFiles) then
  PKGMAN_ExcludeTestFiles := [];
fi;

# Run tests
TestDirectory(DirectoriesPackageLibrary("PackageManager", "tst"),
              rec(exitGAP := true,
                  exclude := PKGMAN_ExcludeTestFiles));

FORCE_QUIT_GAP(1);  # If we ever get here, there was an error
