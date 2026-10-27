# dependencies preference
gap> InstallPackage("IO_ForHomAlg", rec(dependencies := false));
true
gap> PKGMAN_UserPackageInfo("IO_ForHomAlg") <> [];
true
gap> PKGMAN_UserPackageInfo("HomalgToCAS");
[  ]
gap> InstallPackage("IO_ForHomAlg", rec(dependencies := true));
true
gap> PKGMAN_UserPackageInfo("IO_ForHomAlg") <> [];
true
gap> PKGMAN_UserPackageInfo("HomalgToCAS") <> [];
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
