InstallGlobalFunction(InstallPackageFromArchive,
function(url)
  local archive_path, dir;
  
  # Download the archive
  archive_path := PKGMAN_DownloadUrlToTempFile(url);
  if archive_path = fail then return false; fi;
  
  # Extract the archive
  dir := PKGMAN_ExtractArchive(archive_path, PKGMAN_PackageDir());
  if dir = fail then return false; fi;

  # Install dependencies
  if PKGMAN_InstallDependencies(dir) <> true then
    Info(InfoPackageManager, 1, "Dependencies not satisfied for ", PKGMAN_TarTopDirectory(archive_path));
    PKGMAN_RemoveDirOptional(dir);
    return false;
  fi;

  # Check validity
  if PKGMAN_CheckPackage(dir) = false then
    PKGMAN_RemoveDirOptional(dir);
    return false;
  fi;

  PKGMAN_RefreshPackageInfo();
  return true;
end);

InstallGlobalFunction(PKGMAN_ExtractArchive,
function(archive_path, target_path)
  local topdir, dir, movedname, exec;
  # Find the name of the directory in the archive
  topdir := PKGMAN_TarTopDirectory(archive_path);
  if topdir = fail then
    return fail;
  fi;

  # Check availability of target location
  dir := Filename(Directory(target_path), topdir);
  if not PKGMAN_IsValidTargetDir(dir) then
    if IsDirectoryPath(dir) and IsWritableFile(dir) and IsReadableFile(dir) then
      # old version installed with the same name: change dir name
      movedname := Concatenation(dir, ".old");
      Info(InfoPackageManager, 1, "Appending '.old' to old version directory");
      exec := PKGMAN_Exec(".", "mv", dir, movedname);
      PKGMAN_RefreshPackageInfo();
      if exec.code <> 0 then
        Info(InfoPackageManager, 1, "Could not rename old package directory");
        return fail;
      fi;
    else
      return fail;
    fi;
  fi;

  # Extract package
  Info(InfoPackageManager, 2, "Extracting to ", dir, " ...");
  exec := PKGMAN_Exec(".", "tar", "xf", archive_path, "-C", target_path);
  if exec.code <> 0 then
    Info(InfoPackageManager, 1, "Extraction unsuccessful");
    return fail;
  fi;
  Info(InfoPackageManager, 4, "Extracted successfully");

  return dir;
end);

InstallGlobalFunction(PKGMAN_TarTopDirectory,
function(path)
  local tar, options, exec, files, topdir;
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
    return fail;
  fi;

  # Expect to find a single directory and nothing else
  files := SplitString(exec.output, "", "\n");
  topdir := Set(files, f -> SplitString(f, "/")[1]);
  if Length(topdir) <> 1 then
    Info(InfoPackageManager, 1, "Archive should contain 1 directory (not ", Length(topdir), ")");
    return fail;
  fi;

  return topdir[1];
end);
