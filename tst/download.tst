# Missing curlInterface: use wget instead
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> InstallPackage("https://gap-packages.github.io/Memoisation/PackageInfo.g");
true
gap> RemovePackage("Memoisation", false);
true
gap> PKGMAN_CurlIntReqVer := ver;;

# wget failure
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false
gap> PKGMAN_CurlIntReqVer := ver;;

# Missing curlInterface: use curl instead
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> tmp := PKGMAN_DownloadCmds[1];;
gap> PKGMAN_DownloadCmds[1] := PKGMAN_DownloadCmds[2];;
gap> PKGMAN_DownloadCmds[2] := tmp;;
gap> PKGMAN_DownloadCmds[1][1];
"curl"
gap> InstallPackage("uuid");
true
gap> RemovePackage("uuid", false);
true
gap> PKGMAN_CurlIntReqVer := ver;;

# curl failure
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> PKGMAN_DownloadCmds[1][1];
"curl"
gap> InstallPackage("www.gap.rubbish/somepackage.tar.gz");
#I  Could not download from www.gap.rubbish/somepackage.tar.gz
false
gap> PKGMAN_CurlIntReqVer := ver;;

# Missing first command
gap> ver := PKGMAN_CurlIntReqVer;;
gap> PKGMAN_CurlIntReqVer := ">= 100.0";;
gap> PKGMAN_DownloadCmds[1][1] := "abababaxyz";;
gap> InstallPackage("crypting");
true
gap> PKGMAN_CurlIntReqVer := ver;;
