InstallGlobalFunction(InstallPackageFromArchive,
function(url)
  local get, user_pkg_dir, url_parts, filename, path, exec, topdir, dir,
        movedname;

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

  # Find the name of the directory in the archive
  topdir := PKGMAN_TarTopDirectory(path);
  if topdir = fail then
    return false;
  fi;

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
