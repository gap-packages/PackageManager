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
gap> InstallPackage("https://github.com/gap-packages/crypting.git");
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
gap> PKGMAN_Exec(dir, "git", "reset", "--hard", "v0.9").code;
0
gap> PKGMAN_RefreshPackageInfo();
true
gap> InstallPackage("crypting", rec(git := false, compile := false)); # might be hard to compile v0.9
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
gap> RemovePackage("LAGUNA");
true
gap> RemovePackage("Sophus");
true

# upgrade preference
gap> InstallPackage("https://github.com/gap-packages/sophus/releases/download/v1.26/sophus-1.26.tar.gz");
true
gap> InstallPackage("LAGUNA", rec(suggested := true, upgrade := false));
true
gap> PKGMAN_UserPackageInfo("Sophus")[1].Version;
"1.26"
gap> InstallPackage("LAGUNA", rec(suggested := true, upgrade := true));
true
gap> CompareVersionNumbers(PKGMAN_UserPackageInfo("Sophus")[1].Version, ">=1.27");
true

# compile preference
gap> InstallPackage("edim", rec(compile := false));
true
gap> LoadPackage("edim", false);
true
gap> IsBound(ElementaryDivisorsPPartRkExpSmall);  # only available if compiled
false
gap> RemovePackage("edim");
true

# compileDeps preference
gap> InstallPackage("kan", rec(compileDeps := false)); # requires kbmag
true
gap> Length(PKGMAN_UserPackageInfo("kbmag")); # kbmag is installed...
1
gap> LoadPackage("kbmag", false); # ...but has not been compiled
fail

# distroVersion preference
gap> InstallPackage("crypting", rec(distroVersion := "v4.15.0"));
true
gap> PackageInfo("crypting")[1].Version;
"0.10.6"
gap> RemovePackage("crypting");
true
gap> InstallPackage("crypting", rec(distroVersion := "latest"));
true
gap> CompareVersionNumbers(PackageInfo("crypting")[1].Version, ">=0.10.7");
true
gap> RemovePackage("crypting");
true

# branch preference
gap> InstallPackage("https://github.com/mtorpey/uuid.git", rec(branch := "stable-3.1"));
true
gap> PackageInfo("uuid")[1].Version;
"3.1"
gap> RemovePackage("uuid");
true
