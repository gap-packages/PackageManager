#
# PackageManager: Easily download and install GAP packages
#
# Reading the declaration part of the package.
#

# If curlInterface is not loaded, set dummy variable
if not IsPackageMarkedForLoading("curlInterface", ">=2.1.0") then
  DownloadURL := ReturnFalse;
fi;

ReadPackage("PackageManager", "gap/PackageManager.gd");
ReadPackage("PackageManager", "gap/Interactive.gd");
