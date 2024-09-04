#
# PackageManager: Easily download and install GAP packages
#
# Implementations
#

BindGlobal("PKGMAN_WHITESPACE", MakeImmutable(" \n\t\r"));

BindGlobal("PKGMAN_PathSystemProgram", function(name)
  local dir, path;

  for dir in DirectoriesSystemPrograms() do
    path:= Filename(dir, name);
    if IsExecutableFile(path) then
      return path;
    fi;
  od;
  return fail;
end);

# Install fallback ChangeDirectoryCurrent if GAP is too old and io isn't loaded
if not IsBound(ChangeDirectoryCurrent) then
  ChangeDirectoryCurrent := function(dir)
    GAPInfo.DirectoryCurrent := Directory(dir);
  end;
fi;

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
    return InstallPackageFromGit(string, interactive);
  elif EndsWith(string, ".hg") then
    return InstallPackageFromHg(string, interactive);
  elif EndsWith(string, "PackageInfo.g") then
    return InstallPackageFromInfo(string);
  fi;
  return InstallPackageFromName(string, version, interactive);
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
  files, topdir, dir, movedname;

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
    if IsDirectoryPath(dir) and IsWritableFile(dir) and IsReadableFile(dir) then
      # old version installed with the same name: change dir name
      movedname := Concatenation(dir, ".old");
      Info(InfoPackageManager, 1, "Appending '.old' to old version directory");
      exec := PKGMAN_Exec(".", "mv", dir, movedname);
      PKGMAN_RefreshPackageInfo();
      if exec.code <> 0 then
        Info(InfoPackageManager, 1, "Could not rename old package directory");
        return false;
      fi;
    else
      return false;
    fi;
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
    if ValueOption("keepDirectory") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;

  # Check validity
  if PKGMAN_CheckPackage(dir) = false then
    if ValueOption("keepDirectory") <> true then
      PKGMAN_RemoveDir(dir);
    fi;
    return false;
  fi;
  PKGMAN_RefreshPackageInfo();

  return true;
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
        urls, newest, old, oldVer, olddir, q;

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
        if pull.code = 0 then
          PKGMAN_CompileDir(dir);
          return true;
        else
          return false;
        fi;
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
  old := info[1];  # Highest-priority version in user pkg directory
  oldVer := old.Version;
  if CompareVersionNumbers(newest.Version, oldVer, "equal") then
    Info(InfoPackageManager, 2,
         "The newest version of package \"", name, "\" is already installed");
    return PKGMAN_CheckPackage(old.InstallationPath);
  elif CompareVersionNumbers(newest.Version, oldVer) then
    Info(InfoPackageManager, 2, name, " version ", newest.Version,
         " will be installed, replacing ", oldVer);
    if InstallPackageFromInfo(newest) <> true then
      return false;
    fi;

    # Remove old version (which might have changed its name)
    allinfo := PackageInfo(name);
    info := Filtered(allinfo,
                     x -> IsMatchingSublist(x.InstallationPath, user_pkg_dir));
    old := First(info, x -> x.Version = oldVer);
    olddir := old.InstallationPath;
    q := Concatenation("Remove old version of ", name, " at ", olddir, " ?");
    if interactive and PKGMAN_AskYesNoQuestion(q : default := false) then
      PKGMAN_RemoveDir(olddir);
    fi;
    return true;
  else
    Info(InfoPackageManager, 2, "The installed version of package \"", name,
         "\" is newer than the latest available version!");
    return PKGMAN_CheckPackage(old.InstallationPath);
  fi;
end);

InstallGlobalFunction(PKGMAN_CheckPackage,
function(dir)
  local info, fname, html;

  # Get PackageInfo
  info := PKGMAN_GetPackageInfo(dir);
  if info = fail then
    return false;
  fi;

  # Simple checks
  for fname in PKGMAN_RequiredPackageInfoFields do
    if not IsBound(info.(fname)) then
      Info(InfoPackageManager, 1, "PackageInfo.g lacks ", fname, " field");
      Info(InfoPackageManager, 2, "(in ", dir, ")");
      return false;
    fi;
  od;

  # Make doc if needed
  if IsRecord(info.PackageDoc) then
    html := info.PackageDoc.HTMLStart;
  else
    html := info.PackageDoc[1].HTMLStart;
  fi;
  html := Filename(Directory(dir), html);
  if not (IsReadableFile(html)) then
    PKGMAN_MakeDoc(dir);
  fi;

  # Validate PackageInfo before proceeding
  if not PKGMAN_ValidatePackageInfo(info.InstallationPath) then
    Info(InfoPackageManager, 1, "PackageInfo.g validation failed");
    Info(InfoPackageManager, 2, "(in ", dir, ")");
    Info(InfoPackageManager, 1, "There may be problems with the package");
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

InstallGlobalFunction(PKGMAN_Exec,
function(dir, cmd, args...)
  local sh, fullcmd, instream, out, outstream, code;

  # Check shell
  sh := PKGMAN_PathSystemProgram("sh");
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
    fullcmd := PKGMAN_PathSystemProgram(cmd);
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
  sh := PKGMAN_PathSystemProgram("sh");
  args := JoinStringsWithSeparator(args, " ");
  fullcmd := Concatenation(fullcmd, " ", args, " 2>&1");
  # avoids temporary dir problems in stable-4.12
  ChangeDirectoryCurrent(".");
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

InstallGlobalFunction(PKGMAN_InfoWithIndent,
function(infoLevel, message, indentLevel)
  local indent, line;
  indent := RepeatedString(" ", indentLevel);
  for line in SplitString(message, "\n") do
    Info(InfoPackageManager, infoLevel, indent, line);
  od;
end);
