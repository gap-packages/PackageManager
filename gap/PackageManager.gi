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

InstallMethod(InstallPackage,
"for a string",
[IsString],
string -> InstallPackage(string, rec()));

InstallMethod(InstallPackage,
"for a string and a record",
[IsString, IsRecord],
function(string, prefs)
  # Tidy up the string
  NormalizeWhitespace(string);

  # Call the appropriate function
  if ForAny(PKGMAN_ArchiveFormats, ext -> EndsWith(string, ext)) then
    return InstallPackageFromArchive(string);
  elif EndsWith(string, ".git") then
    return InstallPackageFromGit(string, prefs);
  elif EndsWith(string, "PackageInfo.g") then
    return InstallPackageFromInfo(string);
  fi;
  return InstallPackageFromName(string, prefs);
end);

InstallMethod(RemovePackage,
"for a string",
[IsString],
name -> RemovePackage(name, rec()));

InstallMethod(RemovePackage,
"for a string and a record",
[IsString, IsRecord],
function(name, prefs)
  local infos, info, dir, question;
  
  # Locate the package
  infos := PKGMAN_UserPackageInfo(name : warnIfNone);

  # Warn if multiple versions were found
  if Length(infos) > 1 then
    Info(InfoPackageManager, 2, "Installations of ", name, " found at multiple locations: ");
    for info in infos do
      PKGMAN_InfoWithIndent(2, info.InstallationPath, 2);
    od;
  fi;
  
  # Offer to remove each directory carefully
  for info in infos do
    dir := ShallowCopy(info.InstallationPath);
    question := Concatenation("Delete directory ", dir, " ?");
    if PKGMAN_Pref("proceed", prefs, question) then
      PKGMAN_RemoveDir(dir);
    else
      Info(InfoPackageManager, 3, "Directory not deleted");
    fi;
  od;
  return true;
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

  # Attempt to compile.
  # This will often be unnecessary, but it's hard to tell whether compilation
  # has already been done, and recompiling is usually cheap.
  PKGMAN_CompileDir(dir);

  # Redo dependencies if needed
  #if TestPackageAvailability(info.PackageName, info.Version) = fail then
  #  if not PKGMAN_InstallDependencies(dir) then
  #    Info(InfoPackageManager, 1, "Dependencies not satisfied");
  #  fi;
  #fi;

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
  instream := ValueOption("instream");
  if instream = fail then
    instream := InputTextNone();
  fi;
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
  indent := ListWithIdenticalEntries(indentLevel, ' ');
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
