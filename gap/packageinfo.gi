InstallGlobalFunction(InstallPackageFromInfo,
function(info, version...)
  local equal, formats, format, url;

  # Check input
  if not (IsString(info) or IsRecord(info)) then
    ErrorNoReturn("<info> should be a rec or URL");
  fi;

  # Get file from URL
  if IsString(info) then
    info := PKGMAN_DownloadPackageInfo(info);
    if info = fail then
      return false;
    fi;
  fi;

  # Check the version condition.
  if Length(version) = 1 and IsString(version[1]) then
    if StartsWith(version[1], "=" ) then
      equal:= "equal";
    else
      equal:= "";
    fi;
    if not CompareVersionNumbers(info.Version, version[1], equal) then
      Info(InfoPackageManager, 1, "Version \"", version[1], "\" of package \"",
           info.PackageName, "\" cannot be satisfied");
      Info(InfoPackageManager, 2,
           "The newest version available is ", info.Version);
      return false;
    fi;
  fi;

  # Read the information we want from it
  formats := SplitString(info.ArchiveFormats, "", ", \n\r\t");
  format := First(PKGMAN_ArchiveFormats, f -> f in formats);
  if format = fail then
    Info(InfoPackageManager, 1,
         "No supported archive formats available, so could not install");
    Info(InfoPackageManager, 1, "Only ", formats, " available");
    return false;
  fi;
  url := Concatenation(info.ArchiveURL, format);

  # Download the archive
  return InstallPackageFromArchive(url);
end);

InstallGlobalFunction(PKGMAN_GetPackageInfo,
function(dir_or_stream)
  local fname, info;
  if IsString(dir_or_stream) or IsDirectory(dir_or_stream) then
    fname := Filename(Directory(dir_or_stream), "PackageInfo.g");
    if not IsReadableFile(fname) then
      Info(InfoPackageManager, 1, "Could not find PackageInfo.g file");
      return fail;
    fi;
    Read(fname);
    GAPInfo.PackageInfoCurrent.InstallationPath := fname;
  elif IsInputStream(dir_or_stream) then
    info := dir_or_stream;
    Read(info);
  else
    Error("invalid input");
  fi;
  return GAPInfo.PackageInfoCurrent;
end);

InstallGlobalFunction(PKGMAN_RefreshPackageInfo,
function()
  GAPInfo.PackagesInfoInitialized := false;
  InitializePackagesInfoRecords();
  Info(InfoPackageManager, 4, "Reloaded all package info records");
end);

InstallGlobalFunction(PKGMAN_ValidatePackageInfo,
function(info)
  local quiet;
  # Suppress output unless info level is maximum
  quiet := InfoLevel(InfoPackageManager) < 4;
  return ValidatePackageInfo(info : quiet := quiet);
end);

# Return package info records for all packages installed with this name in the
# user package directory.
# Use warnIfNone and warnIfMultiple options to print info warnings.
InstallGlobalFunction(PKGMAN_UserPackageInfo,
function(name)
  local user_pkg_dir, allinfo, userinfo;

  user_pkg_dir := PKGMAN_PackageDir();
  allinfo := PackageInfo(name);
  userinfo := Filtered(allinfo, i -> StartsWith(i.InstallationPath, user_pkg_dir));

  # Package not found
  if ValueOption("warnIfNone") = true and Length(userinfo) = 0 then
    Info(InfoPackageManager, 1, "Package \"", name, "\" not installed in user package directory");
    Info(InfoPackageManager, 2, "(currently set to ", PKGMAN_PackageDir(), ")");
    if not IsEmpty(allinfo) then
      Info(InfoPackageManager, 2, "but installed at ", List(allinfo, i -> i.InstallationPath));
    fi;
  fi;

  # Multiple versions found
  if ValueOption("warnIfMultiple") = true and Length(userinfo) > 1 then
    Info(InfoPackageManager, 1, "Multiple versions of package ", name, " installed");
    Info(InfoPackageManager, 2, "at ", List(userinfo, i -> i.InstallationPath));
  fi;

  return userinfo;
end);
