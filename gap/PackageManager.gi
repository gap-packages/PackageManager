#
# PackageManager: Easily download and install GAP packages
#
# Implementations
#

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
    ErrorNoReturn("<string> must be a string");
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

  # Tidy up the string
  NormalizeWhitespace(string);

  # Call the appropriate function
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

InstallGlobalFunction(RemovePackage,
function(name, interactive...)
  local info, dir, q;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("<name> must be a string");
  elif Length(interactive) > 1 then
    ErrorNoReturn("requires 1 or 2 arguments (not ", Length(interactive) + 1, ")");
  elif Length(interactive) = 1 then
    if interactive[1] = true or interactive[1] = false then
      interactive := interactive[1];
    else
      ErrorNoReturn("<interactive> must be true or false");
    fi;
  else
    interactive := true;
  fi;

  # Locate the package
  info := PKGMAN_UserPackageInfo(name : warnIfNone, warnIfMultiple);

  # Need precisely one version
  if Length(info) <> 1 then
    return false;
  fi;

  # Remove directory carefully
  dir := ShallowCopy(info[1].InstallationPath);
  q := Concatenation("Really delete directory ", dir, " ?");
  if interactive = false or PKGMAN_AskYesNoQuestion(q : default := false) then
    PKGMAN_RemoveDir(dir);
    return true;
  fi;
  Info(InfoPackageManager, 3, "Directory not deleted");
  return false;
end);

InstallGlobalFunction(UpdatePackage,
function(name, interactive...)
  local info, dirs, vc, repo, dir, status, pull, line, urls, newest, old,
        oldVer, olddir, q;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("<name> must be a string");
  elif Length(interactive) > 1 then
    ErrorNoReturn("requires 1 or 2 arguments (not ", Length(interactive) + 1, ")");
  elif Length(interactive) = 1 then
    if interactive[1] = true or interactive[1] = false then
      interactive := interactive[1];
    else
      ErrorNoReturn("<interactive> must be true or false");
    fi;
  else
    interactive := true;
  fi;

  # Package names should be case-insensitive
  name := LowercaseString(name);

  # Locate the package
  info := PKGMAN_UserPackageInfo(name : warnIfNone);

  # Package not installed
  if Length(info) = 0 then
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
    info := PKGMAN_UserPackageInfo(name);
    old := First(info, x -> x.Version = oldVer);
    olddir := old.InstallationPath;
    q := Concatenation("Remove old version of ", name, " at ", olddir, " ?");
    if interactive = false or PKGMAN_AskYesNoQuestion(q : default := false) then
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

InstallGlobalFunction(PKGMAN_InfoWithIndent,
function(infoLevel, message, indentLevel)
  local indent, line;
  indent := RepeatedString(" ", indentLevel);
  for line in SplitString(message, "\n") do
    Info(InfoPackageManager, infoLevel, indent, line);
  od;
end);

InstallGlobalFunction(PKGMAN_PathSystemProgram,
function(name)
  local dir, path;

  for dir in DirectoriesSystemPrograms() do
    path := Filename(dir, name);
    if IsExecutableFile(path) then
      return path;
    fi;
  od;
  return fail;
end);
