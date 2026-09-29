# UpdatePackage should be a synonym for InstallPackage
gap> UpdatePackage = InstallPackage;
true

# interactive flag supported as second argument
gap> SetUserPreference("PackageManager", "interactive", true);
gap> InstallPackage("uuid", false);
true
gap> RemovePackage("uuid", false);
true
gap> SetUserPreference("PackageManager", "interactive", false);
