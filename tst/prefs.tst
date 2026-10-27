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
gap> InstallPackage("git@github.com:gap-packages/crypting.git");
true
gap> dir := PKGMAN_UserPackageInfo("crypting")[1].InstallationPath;;
gap> PKGMAN_Exec(dir, "git", "reset", "--hard", "v0.10.6");
rec( code := 0, output := "HEAD is now at e5149e5 Version 0.10.6\n" )
gap> PKGMAN_RefreshPackageInfo();
true
gap> InstallPackage("crypting", rec(git := true));
true
gap> Length(PKGMAN_UserPackageInfo("crypting"));
1
gap> PKGMAN_Exec(dir, "git", "reset", "--hard", "v0.10.6").code;
0
gap> PKGMAN_RefreshPackageInfo();
true
gap> InstallPackage("crypting", rec(git := false));
true
gap> Length(PKGMAN_UserPackageInfo("crypting"));
2

# proceed preference
gap> RemovePackage("crypting", rec(proceed := false));
#I  Multiple versions of package crypting installed
true
gap> Length(PKGMAN_UserPackageInfo("crypting"));
2
gap> RemovePackage("crypting", rec(proceed := true));
#I  Multiple versions of package crypting installed
true
gap> Length(PKGMAN_UserPackageInfo("crypting"));
0

# suggested preference
gap> InstallPackage("LAGUNA", rec(suggested := false));
true
gap> Length(PKGMAN_UserPackageInfo("LAGUNA"));
1
gap> Length(PKGMAN_UserPackageInfo("Sophus"));
0
gap> InstallPackage("LAGUNA", rec(suggested := true));
true
gap> Length(PKGMAN_UserPackageInfo("Sophus"));
1

# upgrade preference

# compile preference

# compileDeps preference

# interactive preference

# distroLocation preference

# distroVersion preference

# version preference

# branch preference
