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
  local dir;
  # Tidy up the string
  NormalizeWhitespace(string);

  # Call the appropriate function
  if ForAny(PKGMAN_ArchiveFormats, ext -> EndsWith(string, ext)) then
    dir := PKGMAN_InstallFromArchive(string);
    if dir = fail then
      return false;
    fi;
    return PKGMAN_FinishPackageSetup(dir, prefs);
  elif PKGMAN_IsGitUrl(string) then
    return PKGMAN_InstallFromGit(string, prefs);
  elif EndsWith(string, "PackageInfo.g") then
    return PKGMAN_InstallFromInfo(string);
  fi;
  return PKGMAN_InstallFromName(string, prefs);
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
  infos := PKGMAN_UserPackageInfo(name : warnIfNone, warnIfMultiple);

  if Length(infos) = 0 then
    # Removal was not successful
    return false;
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

InstallGlobalFunction(PKGMAN_CheckPackageBasic,
function(dir)
  # Checks that PackageInfo.g contains the basic things needed
  local info, fname, badfile, contents;

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
      # Leaving the bad PackageInfo.g file can make GAP unloadable
      badfile := Filename(Directory(dir), "PackageInfo.g");
      contents := StringFile(badfile);
      FileString(Filename(Directory(dir), "bad-PackageInfo.g"), contents);
      RemoveFile(badfile);
      Info(InfoPackageManager, 2, "Renamed to bad-PackageInfo.g");
      return false;
    fi;
  od;
  
  return true;
end);

InstallGlobalFunction(PKGMAN_FinishPackageSetup,
function(dir, prefs)
  local info, html;
  info := PKGMAN_GetPackageInfo(dir);
  
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
  if PKGMAN_Pref("compile", prefs, "Compile package?") then
    PKGMAN_CompileDir(dir);
  fi;

  # Redo dependencies if needed
  PKGMAN_InstallDependencies(dir, prefs);

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
