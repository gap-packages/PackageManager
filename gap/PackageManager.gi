#
# PackageManager: Easily download and install GAP packages
#
# Implementations
#
InstallGlobalFunction(GetPackageList,
function()
  local url, get, packages, line, items;
  url := Concatenation("https://raw.githubusercontent.com/gap-system/",
                       "gap-distribution/master/DistributionUpdate/",
                       "PackageUpdate/currentPackageInfoURLList");
  get := DownloadURL(url);
  if not get.success then
    ErrorNoReturn("PackageManager: GetPackageList: could not contact server");
  fi;
  packages := [];
  for line in SplitString(get.result, "\n") do
    items := SplitString(line, "", WHITESPACE);
    if Length(items) = 0 or items[1][1] = '#' then
      continue;
    elif Length(items) <> 2 then
      ErrorNoReturn("PackageManager: GetPackageList: bad line:\n", line);
    fi;
    Add(packages, rec(name := items[1], url := items[2]));
  od;
  return packages;
end);

InstallGlobalFunction(InstallPackageURL,
function(pkg_name)
  local url, get, user_pkg_dir, filename;
  if not IsString(pkg_name) then
    ErrorNoReturn("PackageManager: InstallPackage: usage,\n",
                  "<pkg_name> should be a string,");
  fi;
  url := pkg_name;
  get := DownloadURL(url);
  if get.success <> true then
    return false;
  fi;
  user_pkg_dir := UserHomeExpand("~/.gap/pkg"); # TODO: cygwin?
  if not IsDirectoryPath(user_pkg_dir) then
    CreateDir(user_pkg_dir);
  fi;
  url := SplitString(url, "/");
  filename := Filename(DirectoryTemporary(), url[Length(url)]);
  FileString(filename, get.result);
  Exec("tar xf", filename, "-C", user_pkg_dir);
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
