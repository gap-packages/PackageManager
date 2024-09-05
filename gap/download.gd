DeclareGlobalFunction("PKGMAN_DownloadURL");
DeclareGlobalFunction("PKGMAN_DownloadPackageInfo");

# curlInterface minimum version worth using
PKGMAN_CurlIntReqVer :=
  First(PackageInfo("PackageManager")[1].Dependencies.SuggestedOtherPackages,
        item -> item[1] = "curlInterface")[2];

# Shell commands used for downloading if curlInterface not loaded
PKGMAN_DownloadCmds := [["wget", ["--quiet", "-O", "-"]],
                        ["curl", ["--silent", "-L", "--output", "-"]]];
