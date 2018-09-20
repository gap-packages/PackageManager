#
# PackageManager: Easily download and install GAP packages
#
# Implementations
#
InstallGlobalFunction(GetPackageURLs,
function()
  local get, urls, line, items;
  get := DownloadURL(PKGMAN_PackageInfoURLList);
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
    urls.(LowercaseString(items[1])) := items[2];
  od;
  return urls;
end);

InstallGlobalFunction(InstallPackage,
function(string)
  if not IsString(string) then
    ErrorNoReturn("PackageManager: InstallPackage: ",
                  "<string> must be a string");
  fi;
  NormalizeWhitespace(string);
  if EndsWith(string, ".tar.gz") then
    return InstallPackageFromArchive(string);
  elif EndsWith(string, ".git") then
    return InstallPackageFromGit(string);
  elif EndsWith(string, "PackageInfo.g") then
    return InstallPackageFromInfo(string);
  fi;
  return InstallPackageFromName(string);
end);

InstallGlobalFunction(InstallPackageFromName,
function(name)
  local urls;
  name := LowercaseString(name);
  urls := GetPackageURLs();
  Info(InfoPackageManager, 3, "Package directory retrieved");
  if not IsBound(urls.(name)) then
    Info(InfoPackageManager, 1,
         "Package \"", name, "\" not found in package list");
    return false;
  fi;
  return InstallPackageFromInfo(urls.(name));
end);

InstallGlobalFunction(InstallPackageFromInfo,
function(url)
  local get, stream, info, formats;
  get := DownloadURL(url);
  if not get.success then
    Info(InfoPackageManager, 1, "Unable to download from ", url);
    return false;
  fi;
  Info(InfoPackageManager, 3, "PackageInfo.g retrieved from ", url);
  stream := InputTextString(get.result);
  Read(stream);
  info := GAPInfo.PackageInfoCurrent;
  if not ValidatePackageInfo(info) then
    Info(InfoPackageManager, 1, "Invalid PackageInfo.g file");
    return false;
  fi;
  Info(InfoPackageManager, 3, "PackageInfo.g validated successfully");
  formats := SplitString(info.ArchiveFormats, "", ", \n\r\t");
  if not ".tar.gz" in formats then
    # TODO: support other formats
    Info(InfoPackageManager, 1, "No .tar.gz available, so could not install");
    Info(InfoPackageManager, 1, "Only ", formats, " available");
    return false;
  fi;
  url := Concatenation(info.ArchiveURL, ".tar.gz");
  Info(InfoPackageManager, 3, "Got archive URL ", url);
  return InstallPackageFromArchive(url);
end);

InstallGlobalFunction(InstallPackageFromArchive,
function(url)
  local get, user_pkg_dir, filename, exec, files, topdir, dir;
  get := DownloadURL(url);
  if get.success <> true then
    Info(InfoPackageManager, 1, "Could not download from ", url);
    return false;
  fi;
  Info(InfoPackageManager, 3, "Successfully downloaded from ", url);
  user_pkg_dir := PKGMAN_PackageDir();
  url := SplitString(url, "/");
  filename := Filename(DirectoryTemporary(), url[Length(url)]);
  FileString(filename, get.result);
  Info(InfoPackageManager, 3, "Saved archive to ", filename);
  exec := PKGMAN_Exec("tar", "-tf", filename);
  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Could not inspect tarball contents");
    return false;
  fi;
  files := SplitString(exec.output, "", WHITESPACE);
  topdir := Set(files, f -> SplitString(f, "/")[1]);
  if Length(topdir) <> 1 then
    Info(InfoPackageManager, 1,
         "Archive should contain 1 directory (not ", Length(topdir), ")");
    return false;
  fi;
  topdir := topdir[1];
  exec := PKGMAN_Exec("tar", "xf", filename, "-C", user_pkg_dir);
  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Extraction unsuccessful");
    return false;
  fi;
  dir := Filename(Directory(user_pkg_dir), topdir);
  Info(InfoPackageManager, 2, "Package extracted to ", dir);
  if PKGMAN_CheckPackage(dir) = false then
    if StartsWith(dir, PKGMAN_PackageDir()) and dir <> PKGMAN_PackageDir() then
      RemoveDirectoryRecursively(dir);
      Info(InfoPackageManager, 2, "Removed directory ", dir);
    fi;
    return false;
  fi;
  PKGMAN_RefreshPackageInfo();
  return true;
end);

InstallGlobalFunction(InstallPackageFromGit,
function(url)
  local name, dir, exec;
  name := PKGMAN_NameOfGitRepo(url);
  if name = fail then
    Info(InfoPackageManager, 1, "Could not find repository name (bad URL?)");
    return false;
  fi;
  dir := Filename(Directory(PKGMAN_PackageDir()), name);
  exec := PKGMAN_Exec("git", "clone", url, dir);
  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Extraction unsuccessful");
    return false;
  fi;
  Info(InfoPackageManager, 2, "Package cloned to ", dir);
  PKGMAN_RefreshPackageInfo();
  return true;
  # TODO: compile doc and return PKGMAN_CheckPackage(dir);
end);

InstallGlobalFunction(RemovePackage,
function(name)
  local user_pkg_dir, allinfo, info, dir, result;
  if not IsString(name) then
    ErrorNoReturn("PackageManager: RemovePackage: ",
                  "<name> must be a string");
  fi;
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
  if StartsWith(dir, user_pkg_dir) and dir <> user_pkg_dir then
    result := RemoveDirectoryRecursively(dir);
  fi;
  PKGMAN_RefreshPackageInfo();
  return result;
end);

InstallGlobalFunction(PKGMAN_CheckPackage,
function(dir)
  local info;
  info := Filename(Directory(dir), "PackageInfo.g");
  if not IsReadableFile(info) then
    Info(InfoPackageManager, 1, "Could not find PackageInfo.g file");
    return false;
  elif not ValidatePackageInfo(info) then
    Info(InfoPackageManager, 1, "Invalid PackageInfo.g file");
    return false;
  fi;
  Info(InfoPackageManager, 3, "PackageInfo.g validated successfully");
  return true;
end);

InstallGlobalFunction(PKGMAN_CompileDir,
function(dir)
  local sh, scr, root, argument, exec;
  sh := Filename( DirectoriesSystemPrograms(), "sh" );
  if sh = fail then
    Info(InfoPackageManager, 1, "No shell available called \"sh\"");
    return false;
  fi;
  if ChangeDirectoryCurrent(dir) = fail then
    Info(InfoPackageManager, 1, "Could not access directory ", dir);
    return false;
  fi;
  ChangeDirectoryCurrent(Filename(DirectoryCurrent(), ".."));
  scr := Filename(List(GAPInfo.RootPaths, Directory), "bin/BuildPackages.sh");
  if scr = fail then
    Info(InfoPackageManager, 1, "No bin/BuildPackages.sh script available");
    return false;
  fi;
  root := scr{[1 .. Length(scr) - Length("/bin/BuildPackages.sh")]};
  argument := Concatenation(root, "/bin/BuildPackages.sh",
                            " --strict",
                            " --with-gaproot=", root,
                            " ", dir);
  exec := PKGMAN_Exec("sh", "-c", argument);
  if exec = fail or exec.code <> 0 then
    Info(InfoPackageManager, 1, "Compilation failed");
    return false;
  fi;;
  Info(InfoPackageManager, 3, "Compilation was successful");
  return true;
end);

InstallGlobalFunction(PKGMAN_Exec,
function(cmd, args...)
  local fullcmd, dir, instream, out, outstream, code;

  # Simply concatenate the arguments
  if not IsString(cmd) then
    ErrorNoReturn("<cmd> should be a string");
  fi;
  fullcmd := Filename(DirectoriesSystemPrograms(), cmd);
  if fullcmd = fail then
    Info(InfoPackageManager, 1, "Command ", cmd, " not found");
    return fail;
  fi;

  # Choose working directory
  dir := DirectoryCurrent();

  # Streams
  instream := InputTextNone();
  out := "";;
  outstream := OutputTextString(out, true);

  # Execute the command
  code := Process(dir, fullcmd, instream, outstream, args);
  CloseStream(outstream);

  # Return all the information we captured
  return rec(code := code, output := out);
end);

InstallGlobalFunction(PKGMAN_NameOfGitRepo,
function(url)
  local parts, n;
  parts := SplitString(url, "", "/:. \n\t\r");
  n := Length(parts);
  if parts[n] <> "git" or n = 1 then
    return fail;
  fi;
  return parts[n-1];
end);

InstallGlobalFunction(PKGMAN_RefreshPackageInfo,
function()
  GAPInfo.PackagesInfoInitialized := false;
  InitializePackagesInfoRecords();
  Info(InfoPackageManager, 3, "Reloaded all package info records");
end);

InstallGlobalFunction(PKGMAN_PackageDir,
function()
  local dir;
  if PKGMAN_CustomPackageDir <> "" then
    dir := PKGMAN_CustomPackageDir;
  else
    dir := UserHomeExpand("~/.gap/pkg"); # TODO: cygwin?
  fi;
  if not IsDirectoryPath(dir) then
    CreateDir(dir);
    Info(InfoPackageManager, 3, "Created ", dir, " directory");
  fi;
  return dir;
end);

InstallGlobalFunction(PKGMAN_InsertPackageDirectories,
function(rootpaths)
  #
  # This function is based on ExtendRootDirectories from the library, the only
  # difference being that the paths are added *before* the existing root paths
  # instead of after.
  #
  rootpaths := Filtered(rootpaths, path -> not path in GAPInfo.RootPaths);
  if not IsEmpty(rootpaths) then
    # Append the new root paths.
    GAPInfo.RootPaths := Immutable(Concatenation(rootpaths, GAPInfo.RootPaths));
    # Clear the cache.
    GAPInfo.DirectoriesLibrary:= AtomicRecord(rec());
    # Reread the package information.
    if IsBound(GAPInfo.PackagesInfoInitialized) and
       GAPInfo.PackagesInfoInitialized = true then
      GAPInfo.PackagesInfoInitialized:= false;
      InitializePackagesInfoRecords();
    fi;
  fi;
end);

InstallGlobalFunction(PKGMAN_SetCustomPackageDir,
function(dir)
  local parent;
  if EndsWith(dir, "/pkg") then
    parent := dir{[1..Length(dir)-3]};
  elif EndsWith(dir, "/pkg/") then
    parent := dir{[1..Length(dir)-4]};
  else
    return fail;
  fi;
  PKGMAN_CustomPackageDir := dir;
  PKGMAN_PackageDir();
  PKGMAN_InsertPackageDirectories([parent]);
  PKGMAN_RefreshPackageInfo();
end);
