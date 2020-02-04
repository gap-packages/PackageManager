#
# Memoisation: Shared persistent memoisation library for GAP and other systems
#
# This file runs package tests *excluding* BuildDoc.tst.  This is for systems
# that don't have texlive installed but still want to test the rest of the
# package.
#
PKGMAN_ExcludeTestFiles := ["BuildDoc.tst"];
Read(Filename(DirectoriesPackageLibrary("PackageManager", "tst")[1],
              "testall.g"));
