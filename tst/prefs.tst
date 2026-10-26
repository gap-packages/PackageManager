# dependencies preference
gap> InstallPackage("IO_ForHomAlg", rec(dependencies := false));
true
gap> TestPackageAvailability("IO_ForHomAlg");
fail
gap> PKGMAN_UserPackageInfo("IO_ForHomAlg") <> [];
true
gap> TestPackageAvailability("HomalgToCAS");
fail
gap> InstallPackage("IO_ForHomAlg", rec(dependencies := true));
true
gap> TestPackageAvailability("IO_ForHomAlg") <> fail;
true
gap> TestPackageAvailability("HomalgToCAS") <> fail;
true

# git preference

# proceed preference

# suggested preference

# upgrade preference

# compile preference

# compileDeps preference

# interactive preference

# distroLocation preference

# distroVersion preference

# version preference

# branch preference
