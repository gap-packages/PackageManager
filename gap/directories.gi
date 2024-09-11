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
    Info(InfoPackageManager, 2, "Target directory ", dir, " exists and is non-empty");
    return false;
  fi;
  return true;
end);

InstallGlobalFunction(PKGMAN_RemoveDirOptional,
function(dir)
  if ValueOption("keepDirectory") <> true then
    PKGMAN_RemoveDir(dir);
  fi;
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

InstallGlobalFunction(PKGMAN_GapRootDir,
function()
  local sysinfo;
  sysinfo := PKGMAN_Sysinfo;
  if sysinfo = fail then
    Info(InfoPackageManager, 1, "No sysinfo.gap found");
    return fail;
  fi;
  return sysinfo{[1 .. Length(sysinfo) - Length("/sysinfo.gap")]};
end);
