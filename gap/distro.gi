InstallGlobalFunction(InstallPackageFromName,
function(name, args...)
  local version, interactive, equal, urls, info, current, dirs, vc, q, newest;

  # Handle version condition and interactivity
  version := true;
  interactive := true;
  if not IsString(name) then
    ErrorNoReturn("<name> must be a string");
  elif Length(args) > 2 then
    ErrorNoReturn("requires 1 to 3 arguments (not ", Length(args) + 1, ")");
  elif Length(args) = 1 then
    if IsString(args[1]) then
      version := args[1];
    elif args[1] = true or args[1] = false then
      interactive := args[1];
    else
      ErrorNoReturn("2nd argument must be true or false or a version string");
    fi;
  elif Length(args) = 2 then
    version := args[1];
    interactive := args[2];
  fi;
  if IsString(version) and StartsWith(version, "=") then
    equal := "equal";
  else
    equal := "";
  fi;

  # Check arguments
  if not (IsString(version) or version = true) then
    ErrorNoReturn("if specified, <version> must be a version string");
  elif not (interactive = true or interactive = false) then
    ErrorNoReturn("if specified, <interactive> must be true or false");
  fi;

  # Get package URL from name
  name := LowercaseString(name);
  Info(InfoPackageManager, 3, "Getting PackageInfo URLs...");
  urls := GetPackageURLs();
  if urls.success = false then
    # An info message has already been printed.
    return false;
  elif not IsBound(urls.(name)) then
    Info(InfoPackageManager, 1, "Package \"", name, "\" not found in package list");
    return false;
  fi;

  # Check for already-installed versions
  info := PKGMAN_UserPackageInfo(name);
  if not IsEmpty(info) then  # Already installed
    # Does the installed version already satisfy the prescribed version?
    current := info[1];  # Highest-priority installation in user pkg directory
    if version <> true and
        CompareVersionNumbers(current.Version, version, equal) then
      Info(InfoPackageManager, 2, "Version ", current.Version, " of package \"", name, "\" is already installed");
      return PKGMAN_CheckPackage(current.InstallationPath);
    fi;

    # Any VC installations?
    # (This step is not relevant in case of a prescribed version number.)
    dirs := List(info, i -> ShallowCopy(i.InstallationPath));
    for vc in ["git", "hg"] do
      if Filename(List(dirs, Directory), Concatenation(".", vc)) <> fail then
        q := Concatenation("Package \"", name, "\" already installed via ", vc,
                           ". Update it?");
        if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
          return UpdatePackage(name, interactive);
        fi;
      fi;
    od;

    # Installed by archive only
    newest  := PKGMAN_DownloadPackageInfo(urls.(name));
    if version <> true then
      # Update or give up, but do not ask questions.
      if CompareVersionNumbers(newest.Version, version, equal) then
        # Updating to the newest version will satisfy the version condition.
        return UpdatePackage(name, interactive);
      else
        Info(InfoPackageManager, 1, "Version \"", version, "\" of package \"", name, "\" cannot be satisfied");
        Info(InfoPackageManager, 2, "The newest version available is ", newest.Version);
        return false;
      fi;
    elif CompareVersionNumbers(newest.Version, current.Version, "equal") then
      Info(InfoPackageManager, 2, "The newest version of package \"", name, "\" is already installed");
      return PKGMAN_CheckPackage(current.InstallationPath);
    elif CompareVersionNumbers(newest.Version, current.Version) then
      q := "Package \"{}\" version {} is installed, but {} is available. Install it?";
      q := StringFormatted(q, name, current.Version, newest.Version);
      if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
        return UpdatePackage(name, interactive);
      else
        return PKGMAN_CheckPackage(current.InstallationPath);
      fi;
    fi;
  fi;

  # Not installed yet
  return InstallPackageFromInfo(urls.(name), version);
end);

InstallGlobalFunction(InstallRequiredPackages,
function()
  local pkg;
  for pkg in List(GAPInfo.Dependencies.NeededOtherPackages, l -> l[1]) do
    if not InstallPackageFromName(pkg) then
      return false;
    fi;
  od;
  return true;
end);

InstallGlobalFunction(GetPackageURLs,
function()
  local get, urls, line, items;
  # Get PackageInfo URLs from configurable list
  get := PKGMAN_DownloadURL(PKGMAN_PackageInfoURLList);
  urls := rec(success := false);
  if not get.success then
    Info(InfoPackageManager, 1,
         "PackageManager: GetPackageURLs: could not contact server");
    return urls;
  fi;
  for line in SplitString(get.result, "\n") do
    # Format: <name> [MOVE] <URL>
    items := SplitString(line, "", PKGMAN_WHITESPACE);
    if Length(items) = 0 or items[1][1] = '#' then
      continue;
    elif Length(items) = 1 or Length(items) > 3
         or (Length(items) = 3 and items[2] <> "MOVE") then
      if Length(line) > 74 then  # don't show too much
        line := Concatenation(line{[1 .. 71]}, "...");
      fi;
      Info(InfoPackageManager, 1,
           "PackageManager: GetPackageURLs: bad line:\n#I  ", line);
      return urls;
    fi;
    urls.(LowercaseString(items[1])) := items[Length(items)];
  od;
  urls.success := true;
  return urls;
end);

InstallGlobalFunction(PKGMAN_InstallDependencies,
function(dir)
  local info, deps, to_install, dep, got, info_urls, dep_infos, current,
        dep_info, i;
  info := PKGMAN_GetPackageInfo(dir);
  if IsBound(info.Dependencies) then
    deps := info.Dependencies.NeededOtherPackages;
  else
    deps := [];
  fi;
  if IsEmpty(deps) then
    return true;
  fi;
  # Mark this package as installing in case of circular dependencies
  Add(PKGMAN_MarkedForInstall,
      [LowercaseString(info.PackageName), info.Version]);
  to_install := [];
  Info(InfoPackageManager, 3,
       "Checking dependencies for ", info.PackageName, "...");
  for dep in deps do
    # Do we already have it?
    got := TestPackageAvailability(dep[1], dep[2]) <> fail or
           PositionProperty(PKGMAN_MarkedForInstall,
                            x -> x[1] = dep[1]
                                 and CompareVersionNumbers(x[2], dep[2]))
#TODO: dep[2] may start with "="
#      (this does not happen for the currently distributed packages)
           <> fail;
    Info(InfoPackageManager, 3, "  ", dep[1], " ", dep[2], ": ", got);
    if not got then
      Add(to_install, dep);
    fi;
  od;

  info_urls := GetPackageURLs();
  if info_urls.success = false then
    # An info message has already been printed.
    return false;
  fi;
  dep_infos := [];
  for dep in to_install do
    # Already installed, but needs recompiling?
    current := PKGMAN_UserPackageInfo(dep[1]);
    if not IsEmpty(current) then
      current := current[1];
      if CompareVersionNumbers(current.Version, dep[2]) then
        Info(InfoPackageManager, 3, dep[1], "-", current.Version,
             " installed but not loadable: trying to fix...");
        if PKGMAN_CheckPackage(current.InstallationPath) then
          continue;  # package fixed!
        fi;
      fi;
    fi;

    # Otherwise, prepare to install a fresh version
    if not IsBound(info_urls.(LowercaseString(dep[1]))) then
      Info(InfoPackageManager, 1, "Required package ", dep[1], " unknown");
      PKGMAN_InstallQueue := [];
      PKGMAN_MarkedForInstall := [];
      return false;
    fi;
    dep_info := PKGMAN_DownloadPackageInfo(info_urls.(LowercaseString(dep[1])));
    if not CompareVersionNumbers(dep_info.Version, dep[2]) then
      Info(InfoPackageManager, 1, "Package ", dep[1], " ", dep[2],
           " unavailable: only version ", dep_info.Version, " was found");
      PKGMAN_InstallQueue := [];
      PKGMAN_MarkedForInstall := [];
      return false;
    fi;
    Add(dep_infos, dep_info);

    # If this is already marked for install later, unmark it
    for i in [1 .. Length(PKGMAN_InstallQueue)] do
      if PKGMAN_InstallQueue[i].PackageName = dep_info.PackageName
          and PKGMAN_InstallQueue[i].Version = dep_info.Version then
        Remove(PKGMAN_InstallQueue, i);
        break;
      fi;
    od;
  od;

  # Add these new dependencies at the front of the queue
  PKGMAN_InstallQueue := Concatenation(dep_infos, PKGMAN_InstallQueue);

  # Do the installations (the whole global queue)
  while not IsEmpty(PKGMAN_InstallQueue) do
    dep_info := Remove(PKGMAN_InstallQueue, 1);
    Info(InfoPackageManager, 3, "Installing dependency ",
         dep_info.PackageName, " ", dep_info.Version, " ...");
    if InstallPackageFromInfo(dep_info) <> true then
      PKGMAN_InstallQueue := [];
      PKGMAN_MarkedForInstall := [];
      return false;
    fi;
  od;
  PKGMAN_RefreshPackageInfo();
  Remove(PKGMAN_MarkedForInstall);  # this package
  return true;
end);
