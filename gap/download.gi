InstallGlobalFunction(PKGMAN_DownloadURL,
function(url)
  local tool, exec;

  # Use curlInterface if available
  if TestPackageAvailability("curlInterface", PKGMAN_CurlIntReqVer) = true then
    Info(InfoPackageManager, 4, "Using curlInterface to download...");
    return ValueGlobal("DownloadURL")(url);
  fi;

  # Try command line tools (wget/curl)
  for tool in PKGMAN_DownloadCmds do
    Info(InfoPackageManager, 4, "Using ", tool[1], " to download...");
    exec := CallFuncList(PKGMAN_Exec,
                         Concatenation(["."], [tool[1]], tool[2], [url]));
    if exec = fail then
      Info(InfoPackageManager, 4, tool[1], " unavailable");
    elif exec.code <> 0 then
      Info(InfoPackageManager, 4, "Download failed with ", tool[1]);
    else
      return rec(success := true, result := exec.output);
    fi;
  od;

  return rec(success := false, error := "no download method is available");
end);

InstallGlobalFunction(PKGMAN_DownloadPackageInfo,
function(url)
  local get, info;

  Info(InfoPackageManager, 3, "Retrieving PackageInfo.g from ", url, " ...");
  get := PKGMAN_DownloadURL(url);
  if not get.success then
    Info(InfoPackageManager, 1, "Unable to download from ", url);
    return fail;
  fi;
  info := PKGMAN_GetPackageInfo(InputTextString(get.result));

  # Read the information we want from it
  if PKGMAN_ValidatePackageInfo(info) then
    Info(InfoPackageManager, 4, "PackageInfo.g validated successfully");
  else
    Info(InfoPackageManager, 1, "PackageInfo.g validation failed");
    Info(InfoPackageManager, 1, "There may be problems with the package");
  fi;
  return ShallowCopy(info);
end);
