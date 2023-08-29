#
# PackageManager: Easily download and install GAP packages
#
# Implementations
#

BindGlobal("PKGMAN_WHITESPACE", MakeImmutable(" \n\t\r"));

InstallGlobalFunction(GetPackageURLs,
function()
  local get, urls, line, items;
  # Get PackageInfo URLs from configurable list
  get := PKGMAN_DownloadURL(PKGMAN_PackageInfoURLList);
  urls := rec(success:= false);
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
      Info(InfoPackageManager, 1,
           "PackageManager: GetPackageURLs: bad line:\n#I  ", line);
      return urls;
    fi;
    urls.(LowercaseString(items[1])) := items[Length(items)];
  od;
  urls.success := true;
  return urls;
end);

InstallGlobalFunction(InstallPackage,
function(string, args...)
  local version, interactive;

  # Check input
  version := true;
  interactive := true;
  if not IsString(string) then
    ErrorNoReturn("PackageManager: InstallPackage: ",
                  "<string> must be a string");
  elif Length(args) > 2 then
    ErrorNoReturn("PackageManager: InstallPackage: ",
                  "requires 1 to 3 arguments (not ",
                  Length(args) + 1, ")");
  elif Length(args) = 1 then
    if IsString(args[1]) then
      version := args[1];
    elif args[1] = true or args[1] = false then
      interactive := args[1];
    else
      ErrorNoReturn("PackageManager: InstallPackage:\n",
                    "2nd argument must be true or false or a version string");
    fi;
  elif Length(args) = 2 then
    version := args[1];
    interactive := args[2];
  fi;

  # Call the appropriate function
  NormalizeWhitespace(string);
  if ForAny(PKGMAN_ArchiveFormats, ext -> EndsWith(string, ext)) then
    return InstallPackageFromArchive(string);
  elif EndsWith(string, ".git") then
    return InstallPackageFromGit(string);
  elif EndsWith(string, ".hg") then
    return InstallPackageFromHg(string);
  elif EndsWith(string, "PackageInfo.g") then
    return InstallPackageFromInfo(string);
  fi;
  return InstallPackageFromName(string, version, interactive);
end);

InstallGlobalFunction(InstallPackageFromName,
function(name, args...)
  local version, interactive, urls, allinfo, info, current, dirs, vc, q, newest;

  # Handle version condition and interactivity
  version := true;
  interactive := true;
  if not IsString(name) then
    ErrorNoReturn("PackageManager: InstallPackageFromName: ",
                  "<name> must be a string");
  elif Length(args) > 2 then
    ErrorNoReturn("PackageManager: InstallPackageFromName: ",
                  "requires 1 to 3 arguments (not ",
                  Length(args) + 1, ")");
  elif Length(args) = 1 then
    if IsString(args[1]) then
      version := args[1];
    elif args[1] = true or args[1] = false then
      interactive := args[1];
    else
      ErrorNoReturn("PackageManager: InstallPackageFromName:\n",
                    "2nd argument must be true or false or a version string");
    fi;
  elif Length(args) = 2 then
    version := args[1];
    interactive := args[2];
  fi;

  # Check arguments
  if not (IsString(version) or version = true) then
    ErrorNoReturn("PackageManager: InstallPackageFromName:\n",
                  "if specified, <version> must be a version string");
  elif not (interactive = true or interactive = false) then
    ErrorNoReturn("PackageManager: InstallPackageFromName:\n",
                  "if specified, <interactive> must be true or false");
  fi;

  # Get package URL from name
  name := LowercaseString(name);
  Info(InfoPackageManager, 3, "Getting PackageInfo URLs...");
  urls := GetPackageURLs();
  if urls.success = false then
    # An info message has already been printed.
    return false;
  elif not IsBound(urls.(name)) then
    Info(InfoPackageManager, 1,
         "Package \"", name, "\" not found in package list");
    return false;
  fi;

  # Check for already-installed versions
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));
  if not IsEmpty(info) then  # Already installed
    # Does the installed version already satisfy the prescribed version?
    current := info[1];  # Highest-priority installation in user pkg directory
    if version <> true and
       CompareVersionNumbers( current.Version, version ) then
      Info(InfoPackageManager, 2, "Version ", current.Version,
           " of package \"", name, "\" is already installed");
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
      if CompareVersionNumbers( newest.Version, version ) then
        # Updating to the newest version will satisfy the version condition.
        return UpdatePackage(name, interactive);
      else
        Info(InfoPackageManager, 1, "Version \"", version, "\" of package \"", 
             name, "\" cannot be satisfied");
        Info(InfoPackageManager, 2,
             "The newest version available is ", newest.Version);
        return false;
      fi;
    elif CompareVersionNumbers(newest.Version, current.Version, "equal") then
      Info(InfoPackageManager, 2, "The newest version of package \"", name,
           "\" is already installed");
      return PKGMAN_CheckPackage(current.InstallationPath);
    elif CompareVersionNumbers(newest.Version, current.Version) then
      q := Concatenation("Package \"", name, "\" version ", current.Version,
                         " is installed, but ", newest.Version,
                         " is available. Install it?");
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

InstallGlobalFunction(InstallPackageFromInfo,
function(info, version...)
  local formats, format, url;

  # Check input
  if not (IsString(info) or IsRecord(info)) then
    ErrorNoReturn("PackageManager: InstallPackageFromInfo: ",
                  "<info> should be a rec or URL");
  fi;

  # Get file from URL
  if IsString(info) then
    info := PKGMAN_DownloadPackageInfo(info);
    if info = fail then
      return false;
    fi;
  fi;

  # Check the version condition.
  if Length(version) = 1 and IsString(version[1])
     and not CompareVersionNumbers(info.Version, version[1]) then
    Info(InfoPackageManager, 1, "Version \"", version[1], "\" of package \"", 
         info.PackageName, "\" cannot be satisfied");
    Info(InfoPackageManager, 2,
         "The newest version available is ", info.Version);
    return false;
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

InstallGlobalFunction(InstallPackageFromArchive,
function(url)
  local get, user_pkg_dir, url_parts, filename, path, tar, options, exec,
  files, topdir, dir;

  # Download archive
  Info(InfoPackageManager, 3, "Downloading archive from URL ", url, " ...");
  get := PKGMAN_DownloadURL(url);
  if get.success <> true then
    Info(InfoPackageManager, 1, "Could not download from ", url);
    return false;
  fi;
  user_pkg_dir := PKGMAN_PackageDir();
  url_parts := SplitString(url, "/");
  filename := url_parts[Length(url_parts)];
  path := Filename(DirectoryTemporary(), filename);
  path := Concatenation(path, ".pkgman");  # TEMP: hack till GAP #4110 is merged
  FileString(path, get.result);
  Info(InfoPackageManager, 2, "Saved archive to ", path);

  # Check which version of tar we are using
  tar := PKGMAN_Exec(".", "tar", "--version");
  if StartsWith(tar.output, "tar (GNU tar)") then
    options := "--warning=none";
  else
    options := "";
  fi;

  # Check contents
  exec := PKGMAN_Exec(".", "tar", options, "-tf", path);
  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Could not inspect tarball contents");
    return false;
  fi;
  files := SplitString(exec.output, "", "\n");
  topdir := Set(files, f -> SplitString(f, "/")[1]);
  if Length(topdir) <> 1 then
    Info(InfoPackageManager, 1,
         "Archive should contain 1 directory (not ", Length(topdir), ")");
    return false;
  fi;
  topdir := topdir[1];

  # Check availability of target location
  dir := Filename(Directory(user_pkg_dir), topdir);
  if not PKGMAN_IsValidTargetDir(dir) then
    return false;
  fi;

  # Extract package
  Info(InfoPackageManager, 2, "Extracting to ", dir, " ...");
  exec := PKGMAN_Exec(".", "tar", "xf", path, "-C", user_pkg_dir);
  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Extraction unsuccessful");
    return false;
  fi;
  Info(InfoPackageManager, 4, "Extracted successfully");

  # Install dependencies
  if PKGMAN_InstallDependencies(dir) <> true then
    Info(InfoPackageManager, 1, "Dependencies not satisfied for ", topdir);
    if ValueOption("debug") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Check validity
  if PKGMAN_CheckPackage(dir) = false then
    if ValueOption("debug") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;
  PKGMAN_RefreshPackageInfo();

  return true;
end);

InstallGlobalFunction(InstallPackageFromGit,
function(url, args...)
  local interactive, branch, name, dir, allinfo, info, dirs, repo, q, exec;

  # Process args
  interactive := true;
  branch := fail;
  if Length(args) = 1 then
    if args[1] in [true, false] then
      interactive := args[1];
    elif IsString(args[1]) then
      branch := args[1];
    else
      ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                    "2nd argument should be true, false, or a string");
    fi;
  elif Length(args) = 2 then
    interactive := args[1];
    branch := args[2];
    if not interactive in [true, false] then
      ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                    "<interactive> should be true or false");
    elif not IsString(branch) then
      ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                    "<branch> should be a string");
    fi;
  elif Length(args) > 2 then
    ErrorNoReturn("PackageManager: InstallPackageFromGit:\n",
                  "requires 1, 2 or 3 arguments (not ",
                  Length(args) + 1, ")");
  fi;

  name := PKGMAN_NameOfGitRepo(url);
  if name = fail then
    Info(InfoPackageManager, 1, "Could not find repository name (bad URL?)");
    return false;
  fi;
  dir := Filename(Directory(PKGMAN_PackageDir()), name);

  # Check for existing repository
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));
  dirs := List(info, i -> ShallowCopy(i.InstallationPath));
  repo := Filename(List(dirs, Directory), ".git");
  if repo <> fail then  # TODO: check it's the same remote?
    q := Concatenation("Package \"", name,
                       "\" already installed via git. Update it?");
    if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
      return UpdatePackage(name, interactive);
    fi;
  fi;

  if not PKGMAN_IsValidTargetDir(dir) then
    return false;
  fi;
  Info(InfoPackageManager, 2, "Cloning to ", dir, " ...");

  if branch = fail then
    exec := PKGMAN_Exec(".", "git", "clone", url, dir);
  else
    exec := PKGMAN_Exec(".", "git", "clone", url, dir, "-b", branch);
  fi;

  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Cloning unsuccessful");
    return false;
  fi;
  Info(InfoPackageManager, 3, "Package cloned successfully");
  PKGMAN_RefreshPackageInfo();

  # Check for PackageInfo.g
  info := Filename(Directory(dir), "PackageInfo.g");
  if not IsReadableFile(info) then
    Info(InfoPackageManager, 1, "Could not find PackageInfo.g");
    if ValueOption("debug") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Install dependencies
  if PKGMAN_InstallDependencies(dir) <> true then
    Info(InfoPackageManager, 1, "Dependencies not satisfied for ", name);
    if ValueOption("debug") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Compile, make doc, and check
  return PKGMAN_CheckPackage(dir);
end);

InstallGlobalFunction(InstallPackageFromHg,
function(url, args...)
  local interactive, branch, name, dir, allinfo, info, dirs, repo, q, exec;

  # Process args
  interactive := true;
  branch := fail;
  if Length(args) = 1 then
    if args[1] in [true, false] then
      interactive := args[1];
    elif IsString(args[1]) then
      branch := args[1];
    else
      ErrorNoReturn("PackageManager: InstallPackageFromHg:\n",
                    "2nd argument should be true, false, or a string");
    fi;
  elif Length(args) = 2 then
    interactive := args[1];
    branch := args[2];
    if not interactive in [true, false] then
      ErrorNoReturn("PackageManager: InstallPackageFromHg:\n",
                    "<interactive> should be true or false");
    elif not IsString(branch) then
      ErrorNoReturn("PackageManager: InstallPackageFromHg:\n",
                    "<branch> should be a string");
    fi;
  elif Length(args) > 2 then
    ErrorNoReturn("PackageManager: InstallPackageFromHg:\n",
                  "requires 1, 2 or 3 arguments (not ",
                  Length(args) + 1, ")");
  fi;

  name := PKGMAN_NameOfHgRepo(url);
  if name = fail then
    Info(InfoPackageManager, 1, "Could not find repository name (bad URL?)");
    return false;
  fi;
  dir := Filename(Directory(PKGMAN_PackageDir()), name);

  # Check for existing repository
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> StartsWith(x.InstallationPath, PKGMAN_PackageDir()));
  dirs := List(info, i -> ShallowCopy(i.InstallationPath));
  repo := Filename(List(dirs, Directory), ".hg");
  if repo <> fail then
    q := Concatenation("Package \"", name,
                       "\" already installed via mercurial. Update it?");
    if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
      return UpdatePackage(name, interactive);
    fi;
  fi;

  if not PKGMAN_IsValidTargetDir(dir) then
    return false;
  fi;
  Info(InfoPackageManager, 2, "Cloning to ", dir, " ...");

  if branch = fail then
    exec := PKGMAN_Exec(".", "hg", "clone", url, dir);
  else
    exec := PKGMAN_Exec(".", "hg", "clone", url, dir, "-b", branch);
  fi;

  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Cloning unsuccessful");
    return false;
  fi;
  Info(InfoPackageManager, 3, "Package cloned successfully");
  PKGMAN_RefreshPackageInfo();

  # Check for PackageInfo.g
  info := Filename(Directory(dir), "PackageInfo.g");
  if not IsReadableFile(info) then
    Info(InfoPackageManager, 1, "Could not find PackageInfo.g");
    if ValueOption("debug") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Install dependencies
  if PKGMAN_InstallDependencies(dir) <> true then
    Info(InfoPackageManager, 1, "Dependencies not satisfied for ", name);
    if ValueOption("debug") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Compile, make doc, and check
  return PKGMAN_CheckPackage(dir);
end);

BindGlobal("PKGMAN_GetPackageInfo",
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
    current := Filtered(PackageInfo(dep[1]),
                        x -> StartsWith(x.InstallationPath,
                                        PKGMAN_PackageDir()));
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

InstallGlobalFunction(RemovePackage,
function(name, interactive...)
  local user_pkg_dir, allinfo, info, dir;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("PackageManager: RemovePackage: ",
                  "<name> must be a string");
  elif Length(interactive) > 1 then
    ErrorNoReturn("PackageManager: RemovePackage: ",
                  "requires 1 or 2 arguments (not ",
                  Length(interactive) + 1, ")");
  elif Length(interactive) = 1 then
    if interactive[1] = true or interactive[1] = false then
      interactive := interactive[1];
    else
      ErrorNoReturn("PackageManager: RemovePackage: ",
                    "<interactive> must be true or false");
    fi;
  else
    interactive := true;
  fi;

  # Locate the package
  user_pkg_dir := PKGMAN_PackageDir();
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> IsMatchingSublist(x.InstallationPath, user_pkg_dir));
  if Length(info) = 0 then
    Info(InfoPackageManager, 1,
         "Package \"", name, "\" not installed in user package directory");
    Info(InfoPackageManager, 2, "(currently set to ", PKGMAN_PackageDir(), ")");
    if not IsEmpty(allinfo) then
      Info(InfoPackageManager, 2, "installed at ",
           List(allinfo, i -> i.InstallationPath), ", not in ", user_pkg_dir);
    fi;
    return false;
  elif Length(info) >= 2 then
    Info(InfoPackageManager, 1,
         "Multiple versions of package ", name, " installed");
    Info(InfoPackageManager, 3, "at ", List(info, x -> x.InstallationPath));
    return false;
  fi;
  dir := ShallowCopy(info[1].InstallationPath);

  # Remove directory carefully
  if interactive = false or
      PKGMAN_AskYesNoQuestion("Really delete directory ", dir, " ?"
                              : default := false) then
    PKGMAN_RemoveDir(dir);
    return true;
  fi;
  Info(InfoPackageManager, 3, "Directory not deleted");
  return false;
end);

InstallGlobalFunction(UpdatePackage,
function(name, interactive...)
  local user_pkg_dir, allinfo, info, dirs, vc, repo, dir, status, pull, line,
        urls, newest, current, q, olddir;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("PackageManager: UpdatePackage: ",
                  "<name> must be a string");
  elif Length(interactive) > 1 then
    ErrorNoReturn("PackageManager: UpdatePackage: ",
                  "requires 1 or 2 arguments (not ",
                  Length(interactive) + 1, ")");
  elif Length(interactive) = 1 then
    if interactive[1] = true or interactive[1] = false then
      interactive := interactive[1];
    else
      ErrorNoReturn("PackageManager: UpdatePackage: ",
                    "<interactive> must be true or false");
    fi;
  else
    interactive := true;
  fi;

  # Locate the package
  name := LowercaseString(name);
  user_pkg_dir := PKGMAN_PackageDir();
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> IsMatchingSublist(x.InstallationPath, user_pkg_dir));

  # Package not installed
  if Length(info) = 0 then
    Info(InfoPackageManager, 1,
         "Package \"", name, "\" not installed in user package directory");
    Info(InfoPackageManager, 2, "(currently set to ", PKGMAN_PackageDir(), ")");
    if not IsEmpty(allinfo) then
      Info(InfoPackageManager, 2, "installed at ",
           List(allinfo, i -> i.InstallationPath), ", not in ", user_pkg_dir);
    fi;
    if interactive and PKGMAN_AskYesNoQuestion("Would you like to install ",
                                               name, "?" : default := true) then
      return InstallPackageFromName(name);
    fi;
    return false;
  fi;

  # Look for VC repos
  dirs := List(info, i -> ShallowCopy(i.InstallationPath));
  for vc in [rec(cmd := "git", stflags := "-s", pullflags := "--ff-only"),
             rec(cmd := "hg", stflags := "", pullflags := "-uy")] do
    repo := Filename(List(dirs, Directory), Concatenation(".", vc.cmd));
    if repo <> fail then
      dir := repo{[1 .. Length(repo) - Length("/.") - Length(vc.cmd)]};
      status := PKGMAN_Exec(dir, vc.cmd, "status", vc.stflags);
      if status = fail then
        return false;
      elif status.code = 0 and status.output = "" then
        Info(InfoPackageManager, 3, "Pulling from ", vc.cmd, " repository...");
        pull := PKGMAN_Exec(dir, vc.cmd, "pull", vc.pullflags);
        for line in SplitString(pull.output, "\n") do
          Info(InfoPackageManager, 3, vc.cmd, ": ", line);
        od;
        return (pull.code = 0) and PKGMAN_CompileDir(dir);
      else
        Info(InfoPackageManager, 1,
             "Uncommitted changes in ", vc.cmd, " repository");
        Info(InfoPackageManager, 2, "(at ", dir, ")");
        return false;
      fi;
    fi;
  od;

  # Installed only by archive
  urls := GetPackageURLs();
  if urls.success = false then
    # An info message has already been printed.
    return false;
  fi;
  newest  := PKGMAN_DownloadPackageInfo(urls.(name));
  current := info[1];  # Highest-priority version in user pkg directory
  if CompareVersionNumbers(newest.Version, current.Version, "equal") then
    Info(InfoPackageManager, 2,
         "The newest version of package \"", name, "\" is already installed");
  elif CompareVersionNumbers(newest.Version, current.Version) then
    Info(InfoPackageManager, 2, name, " version ", newest.Version,
         " will be installed, replacing ", current.Version);
    if InstallPackageFromInfo(newest) <> true then
      return false;
    fi;
    olddir := current.InstallationPath;
    q := Concatenation("Remove old version of ", name, " at ", olddir, " ?");
    if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
      PKGMAN_RemoveDir(olddir);
    fi;
    return true;
  else
    Info(InfoPackageManager, 2, "The installed version of package \"", name,
         "\" is newer than the latest available version!");
  fi;
  return PKGMAN_CheckPackage(current.InstallationPath);
end);

InstallGlobalFunction(CompilePackage,
function(name)
  local user_pkg_dir, allinfo, info;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("PackageManager: CompilePackage: ",
                  "<name> must be a string");
  fi;

  # Locate the package
  name := LowercaseString(name);
  user_pkg_dir := PKGMAN_PackageDir();
  allinfo := PackageInfo(name);
  info := Filtered(allinfo,
                   x -> IsMatchingSublist(x.InstallationPath, user_pkg_dir));

  # Package not installed
  if Length(info) = 0 then
    Info(InfoPackageManager, 1,
         "Package \"", name, "\" not installed in user package directory");
    Info(InfoPackageManager, 2, "(currently set to ", PKGMAN_PackageDir(), ")");
    if not IsEmpty(allinfo) then
      Info(InfoPackageManager, 2, "installed at ",
           List(allinfo, i -> i.InstallationPath), ", not in ", user_pkg_dir);
    fi;
    return false;
  fi;

  # Compile it
  return PKGMAN_CompileDir(info[1].InstallationPath);
end);

InstallGlobalFunction(PKGMAN_CheckPackage,
function(dir)
  local info, html;

  # Get PackageInfo
  info := PKGMAN_GetPackageInfo(dir);
  if info = fail then
    return false;
  fi;

  # Simple checks
  if not (IsBound(info.PackageName) and IsBound(info.PackageDoc)) then
    Info(InfoPackageManager, 1, "PackageInfo.g validation failed");
    Info(InfoPackageManager, 2, "(in ", dir, ")");
    return false;
  fi;

  # Make doc if needed
  if IsRecord(info.PackageDoc) then
    html := info.PackageDoc.HTMLStart;
  else
    html := info.PackageDoc[1].HTMLStart;
  fi;
  html := Filename(Directory(dir), html);
  # Check for html before full validate
  if not (IsReadableFile(html) and ValidatePackageInfo(info.InstallationPath)) then
    PKGMAN_MakeDoc(dir);
  fi;

  # Ensure valid PackageInfo before proceeding
  if not ValidatePackageInfo(info.InstallationPath) then
    Info(InfoPackageManager, 1, "PackageInfo.g validation failed");
    Info(InfoPackageManager, 2, "(in ", dir, ")");
    if IsPackageLoaded("gapdoc") then
      return false;
    else
      Info(InfoPackageManager, 1, "Proceeding anyway, since GAPDoc not loaded");
    fi;
  fi;

  # Compile if needed
  PKGMAN_RefreshPackageInfo();
  if TestPackageAvailability(info.PackageName, info.Version) = fail then
    PKGMAN_CompileDir(dir);
  fi;

  # Redo dependencies if needed
  if TestPackageAvailability(info.PackageName, info.Version) = fail then
    if not PKGMAN_InstallDependencies(dir) then
      Info(InfoPackageManager, 1, "Dependencies not satisfied");
    fi;
  fi;

  # Ensure package is available
  PKGMAN_RefreshPackageInfo();
  if TestPackageAvailability(info.PackageName, info.Version) = fail and
      not IsPackageLoaded(LowercaseString(info.PackageName)) then
    Info(InfoPackageManager, 1, "Package availability test failed");
    Info(InfoPackageManager, 2,
         "(for ", info.PackageName, " ", info.Version, ")");
    return false;
  fi;

  # PackageInfo is valid AND the package is available
  Info(InfoPackageManager, 4, "Package checks successful");
  return true;
end);

InstallGlobalFunction(PKGMAN_CompileDir,
function(dir)
  local prerequisites, exec, pkg_dir, scr, root, info;

  info := PKGMAN_GetPackageInfo(dir);
  if info = fail then
    return false;
  fi;

  # Run the prerequisites file if it exists
  # Note: this is mainly for installing Semigroups from GitHub
  prerequisites := Filename(Directory(dir), "prerequisites.sh");
  if IsReadableFile(prerequisites) then
    Info(InfoPackageManager, 3, "Running prerequisites.sh for ", info.PackageName, "...");
    exec := PKGMAN_Exec(dir, prerequisites);
  fi;

  # Check requirements, and prepare command
  pkg_dir := Filename(Directory(dir), "..");
  scr := PKGMAN_Sysinfo;
  if scr = fail then
    Info(InfoPackageManager, 1, "No sysinfo.gap found");
    return false;
  fi;
  root := scr{[1 .. Length(scr) - Length("/sysinfo.gap")]};

  # Is the compilation script available?
  if not (IsString(PKGMAN_BuildPackagesScript)
          and IsReadableFile(PKGMAN_BuildPackagesScript)) then
    Info(InfoPackageManager, 1, "Compilation script not found");
    return false;
  fi;

  # Call the script
  Info(InfoPackageManager, 3, "Running compilation script on ", dir, " ...");
  exec := PKGMAN_Exec(pkg_dir, PKGMAN_BuildPackagesScript, root, dir);
  if exec = fail or
     exec.code <> 0 or
     PositionSublist(exec.output, "Failed to build") <> fail then
    Info(InfoPackageManager, 1,
         "Compilation failed for package '", info.PackageName, "' (package may still be usable)");
    Info(InfoPackageManager, 2, exec.output);
    return false;
  else
    Info(InfoPackageManager, 3, exec.output);
  fi;
  Info(InfoPackageManager, 4, "Compilation was successful");
  return true;
end);

InstallGlobalFunction(PKGMAN_MakeDoc,
function(dir)
  local last_infogapdoc, last_infowarning, makedoc_g, doc_dir, doc_make_doc,
        last_dir, str, exec;
  if not IsPackageLoaded("gapdoc") then
    Info(InfoPackageManager, 1,
         "GAPDoc package not found, skipping building the documentation...");
    return;
  fi;

  # Mute GAPDoc
  if IsBoundGlobal("InfoGAPDoc") then
    last_infogapdoc := InfoLevel(ValueGlobal("InfoGAPDoc"));
    SetInfoLevel(ValueGlobal("InfoGAPDoc"), 0);
  fi;

  last_infowarning := InfoLevel(InfoWarning);
  SetInfoLevel(InfoWarning, 0);

  # Make documentation
  makedoc_g := Filename(Directory(dir), "makedoc.g");
  doc_dir := Filename(Directory(dir), "doc");
  doc_make_doc := Filename(Directory(doc_dir), "make_doc");
  if IsReadableFile(makedoc_g) then
    Info(InfoPackageManager, 3,
         "Building documentation (using makedoc.g)...");

    # Run makedoc.g, in the correct directory, without quitting
    last_dir := DirectoryCurrent();
    GAPInfo.DirectoryCurrent := Directory(dir);
    str := StringFile(makedoc_g);
    str := ReplacedString(str, "QUIT;", "");  # TODO: is there a better way?
    str := ReplacedString(str, "quit;", "");
    Read(InputTextString(str));
    GAPInfo.DirectoryCurrent := last_dir;

  elif IsReadableFile(doc_make_doc) then
    Info(InfoPackageManager, 3,
         "Building documentation (using doc/make_doc)...");
    exec := PKGMAN_Exec(doc_dir, doc_make_doc);
    if exec.code <> 0 then
      Info(InfoPackageManager, 3, "WARNING: doc/make_doc failed");
    fi;
  else
    Info(InfoPackageManager, 3,
         "WARNING: could not build doc (no makedoc.g or doc/make_doc)");
  fi;
  if IsBoundGlobal("InfoGAPDoc") then
    SetInfoLevel(ValueGlobal("InfoGAPDoc"), last_infogapdoc);
  fi;
  SetInfoLevel(InfoWarning, last_infowarning);
end);

InstallGlobalFunction(PKGMAN_Exec,
function(dir, cmd, args...)
  local sh, fullcmd, instream, out, outstream, code, logfile;

  # Check shell
  sh := Filename(DirectoriesSystemPrograms(), "sh");
  if sh = fail then
    Info(InfoPackageManager, 1, "No shell available called \"sh\"");
    return fail;
  fi;

  # Directory
  if IsString(dir) then
    dir := Directory(dir);
  fi;

  # Command
  if not IsString(cmd) then
    ErrorNoReturn("<cmd> should be a string");
  fi;
  if Position(cmd, '/') <> fail then
    # cmd is a path
    fullcmd := cmd;
  else
    # we must look up the path
    fullcmd := Filename(DirectoriesSystemPrograms(), cmd);
    if fullcmd = fail or not IsExecutableFile(fullcmd) then
      Info(InfoPackageManager, 4, "Command ", cmd, " not found");
      return fail;
    fi;
  fi;

  # Streams
  instream := InputTextNone();
  out := "";
  outstream := OutputTextString(out, true);

  # Execute the command (capture both stdout and stderr)
  sh := Filename(DirectoriesSystemPrograms(), "sh");
  args := JoinStringsWithSeparator(args, " ");
  fullcmd := Concatenation(fullcmd, " ", args, " 2>&1");
  code := Process(dir, sh, instream, outstream, ["-c", fullcmd]);
  CloseStream(outstream);

  if code <> 0 then
    Info(InfoPackageManager, 2,
         "Possible error detected, see log:");
    PKGMAN_InfoWithIndent(2, out, 2);
  fi;

  # Return all the information we captured
  return rec(code := code, output := out);
end);

InstallGlobalFunction(PKGMAN_NameOfGitRepo,
function(url)
  local parts, n;
  parts := SplitString(url, "", "/:. \n\t\r");
  n := Length(parts);
  if n <> 0 and parts[n] <> "git" then
    return parts[n];
  fi;
  if parts[n] = "git" and n > 1 then
    return parts[n-1];
  fi;
  return fail;
end);

InstallGlobalFunction(PKGMAN_NameOfHgRepo,
function(url)
  local parts, n;
  parts := SplitString(url, "", "/:. \n\t\r");
  n := Length(parts);
  if n <> 0 and parts[n] <> "hg" then
    return parts[n];
  fi;
  if parts[n] = "hg" and n > 1 then
    return parts[n-1];
  fi;
  return fail;
end);

InstallGlobalFunction(PKGMAN_RefreshPackageInfo,
function()
  GAPInfo.PackagesInfoInitialized := false;
  InitializePackagesInfoRecords();
  Info(InfoPackageManager, 4, "Reloaded all package info records");
end);

InstallGlobalFunction(PKGMAN_PackageDir,
function()
  local dir;
  if PKGMAN_CustomPackageDir <> "" then
    dir := PKGMAN_CustomPackageDir;
  else
    if GAPInfo.UserGapRoot = fail then
      ErrorNoReturn("UserGapRoot not set. Cannot determine package directory");
    fi;
    dir := Concatenation(GAPInfo.UserGapRoot, "/pkg");
  fi;
  if not IsDirectoryPath(dir) then
    PKGMAN_CreateDirRecursively(dir);
    PKGMAN_InsertPackageDirectory(dir);
  fi;
  return dir;
end);

InstallGlobalFunction(PKGMAN_CreateDirRecursively,
function(dir)
  local path, newdir, i, res;
  path := SplitString(dir, "/");
  newdir := "";
  for i in [1 .. Length(path)] do
    Append(newdir, path[i]);
    Append(newdir, "/");
    if not IsDirectoryPath(newdir) then
      res := CreateDir(newdir);
      if res <> true then
        Info(InfoPackageManager, 1, "Failed to create required directory");
        Info(InfoPackageManager, 2, "at ", newdir);
        return fail;
      fi;
      Info(InfoPackageManager, 2, "Created directory ", newdir);
    fi;
  od;
  return true;
end);

InstallGlobalFunction(PKGMAN_InsertPackageDirectory,
function(pkgpath)
  local parent;
  # Locate the parent directory
  if EndsWith(pkgpath, "/pkg") then
    parent := pkgpath{[1 .. Length(pkgpath) - 3]};
  elif EndsWith(pkgpath, "/pkg/") then
    parent := pkgpath{[1 .. Length(pkgpath) - 4]};
  else
    return fail;
  fi;
  if not parent in GAPInfo.RootPaths then
    # Append the new root paths.
    GAPInfo.RootPaths := Immutable(Concatenation([parent], GAPInfo.RootPaths));
  fi;
  # Clear the cache.
  GAPInfo.DirectoriesLibrary := AtomicRecord(rec());
  # Reread the package information.
  if IsBound(GAPInfo.PackagesInfoInitialized) and
      GAPInfo.PackagesInfoInitialized = true then
    GAPInfo.PackagesInfoInitialized := false;
    InitializePackagesInfoRecords();
  fi;
  return true;
end);

InstallGlobalFunction(PKGMAN_IsValidTargetDir,
function(dir)
  if not IsDirectoryPath(dir) then
    return true;  # Assume parent directory is PKGMAN_PackageDir()
  fi;
  if not IsWritableFile(dir) then
    Info(InfoPackageManager, 1, "Target location not writable");
    Info(InfoPackageManager, 2, "(check ", dir, ")");
    return false;
  elif not IsReadableFile(dir) then
    Info(InfoPackageManager, 1, "Target location not readable");
    Info(InfoPackageManager, 2, "(check ", dir, ")");
    return false;
  elif Length(DirectoryContents(dir)) > 2 then
    Info(InfoPackageManager, 1, "Package already installed at target location");
    Info(InfoPackageManager, 2,
         "Target directory ", dir, " exists and is non-empty");
    return false;
  fi;
  return true;
end);

InstallGlobalFunction(PKGMAN_SetCustomPackageDir,
function(dir)
  if not (EndsWith(dir, "/pkg") or EndsWith(dir, "/pkg/")) then
    return fail;
  fi;
  # Set the variable
  PKGMAN_CustomPackageDir := dir;
  # Create the directory if necessary
  PKGMAN_PackageDir();
  # Register as a pkg directory (with top priority)
  PKGMAN_InsertPackageDirectory(dir);
  # Get any packages already present there
  PKGMAN_RefreshPackageInfo();
  # No return value
end);

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

InstallGlobalFunction(PKGMAN_RemoveDir,
function(dir)
  # this 'if' statement is a paranoid check - it should always be true
  if StartsWith(dir, PKGMAN_PackageDir()) and dir <> PKGMAN_PackageDir() then
    RemoveDirectoryRecursively(dir);
    Info(InfoPackageManager, 2, "Removed directory ", dir);
    PKGMAN_RefreshPackageInfo();
  fi;
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
  if not ValidatePackageInfo(info) then
    Info(InfoPackageManager, 1, "Invalid PackageInfo.g file");
    return fail;
  fi;
  Info(InfoPackageManager, 4, "PackageInfo.g validated successfully");
  return ShallowCopy(info);
end);

InstallGlobalFunction(PKGMAN_InfoWithIndent,
function(infoLevel, message, indentLevel)
  local indent, line;
  indent := RepeatedString(" ", indentLevel);
  for line in SplitString(message, "\n") do
    Info(InfoPackageManager, infoLevel, indent, line);
  od;
end);
