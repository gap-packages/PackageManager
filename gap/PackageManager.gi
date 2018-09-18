#
# PackageManager: Easily download and install GAP packages
#
# Implementations
#
InstallGlobalFunction(GetPackageURLs,
function()
  local url, get, urls, line, items;
  url := Concatenation("https://raw.githubusercontent.com/gap-system/",
                       "gap-distribution/master/DistributionUpdate/",
                       "PackageUpdate/currentPackageInfoURLList");
  get := DownloadURL(url);
  if not get.success then
    ErrorNoReturn("PackageManager: GetPackageList: could not contact server");
  fi;
  urls := rec();
  for line in SplitString(get.result, "\n") do
    items := SplitString(line, "", WHITESPACE);
    if Length(items) = 0 or items[1][1] = '#' then
      continue;
    elif Length(items) <> 2 then
      ErrorNoReturn("PackageManager: GetPackageList: bad line:\n", line);
    fi;
    urls.(items[1]) := items[2];
  od;
  return urls;
end);

InstallGlobalFunction(InstallPackageName,
function(pkg_name)
  local urls, get, stream, info, formats;
  urls := GetPackageURLs();
  if not IsBound(urls.(pkg_name)) then
    Info(InfoPackageManager, 1, "Package ", pkg_name, " not found in directory");
    return false;
  fi;
  get := DownloadURL(urls.(pkg_name));
  if not get.success then
    Info(InfoPackageManager, 1, "Unable to download from ", urls.(pkg_name));
  fi;
  stream := InputTextString(get.result);
  Read(stream);
  info := GAPInfo.PackageInfoCurrent;
  formats := SplitString(info.ArchiveFormats, "", ", \n\r\t");
  if not ".tar.gz" in formats then
    # TODO: support other formats
    Info(InfoPackageManager, 1, "No .tar.gz available, so could not install");
    Info(InfoPackageManager, 1, "Only ", formats, " available");
    return false;
  fi;
  return InstallPackageURL(Concatenation(info.ArchiveURL, ".tar.gz"));
end);

InstallGlobalFunction(InstallPackageURL,
function(url)
  local get, user_pkg_dir, filename;
  if not IsString(url) then
    ErrorNoReturn("PackageManager: InstallPackage: usage,\n",
                  "<pkg_name> should be a string,");
  fi;
  get := DownloadURL(url);
  if get.success <> true then
    return false;
  fi;
  Info(InfoPackageManager, 3, "Successfully downloaded from ", url);
  user_pkg_dir := UserHomeExpand("~/.gap/pkg"); # TODO: cygwin?
  if not IsDirectoryPath(user_pkg_dir) then
    CreateDir(user_pkg_dir);
    Info(InfoPackageManager, 3, "Created ", user_pkg_dir, " directory");
  fi;
  url := SplitString(url, "/");
  filename := Filename(DirectoryTemporary(), url[Length(url)]);
  FileString(filename, get.result);
  Info(InfoPackageManager, 3, "Wrote archive to ", filename);
  Exec("tar xf", filename, "-C", user_pkg_dir);
  Info(InfoPackageManager, 2, "Package extracted to ", user_pkg_dir);
  return true;
end);

InstallGlobalFunction(RemovePackage,
function(pkg_name)
  local info, dir, user_pkg_dir;
  if not IsString(pkg_name) then
    ErrorNoReturn("PackageManager: InstallPackage: usage,\n",
                  "<pkg_name> should be a string,");
  fi;
  info := PackageInfo(pkg_name);
  if Length(info) = 0 then
    Info(InfoPackageManager, 1, "Package ", pkg_name, " not installed");
    return false;
  elif Length(info) >= 2 then
    Info(InfoPackageManager, 1,
         "String \"", pkg_name, "\" matches multiple packages");
    return false;
  fi;
  dir := info[1].InstallationPath;
  if not IsDirectoryPath(dir) then
    Info(InfoPackageManager, 1, "Directory ", dir, " already removed");
    return false;
  fi;
  user_pkg_dir := UserHomeExpand("~/.gap/pkg"); # TODO: cygwin?
  if not IsMatchingSublist(dir, user_pkg_dir) then
    Info(InfoPackageManager, 1, "Package \"", pkg_name,
         "\" installed at ", dir, ", not in ", user_pkg_dir);
    return false;
  fi;
  return RemoveDirectoryRecursively(dir);
end);
