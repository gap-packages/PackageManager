InstallGlobalFunction(CompilePackage,
function(name)
  local info;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("<name> must be a string");
  fi;

  # Locate the package
  info := PKGMAN_UserPackageInfo(name : warnIfNone, warnIfMultiple);

  # Package not installed
  if Length(info) = 0 then
    return false;
  fi;

  # Compile all installations that were found
  return ForAll(info, i -> PKGMAN_CompileDir(i.InstallationPath));
end);

InstallGlobalFunction(PKGMAN_CompileDir,
function(dir)
  local info, prerequisites, exec, pkg_dir, gap_root;

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
  gap_root := PKGMAN_GapRootDir();
  if gap_root = fail then
    return false;
  fi;

  # Is the compilation script available?
  if not (IsString(PKGMAN_BuildPackagesScript) and IsReadableFile(PKGMAN_BuildPackagesScript)) then
    Info(InfoPackageManager, 1, "Compilation script not found");
    return false;
  fi;

  # Call the script
  Info(InfoPackageManager, 3, "Running compilation script on ", dir, " ...");
  exec := PKGMAN_Exec(pkg_dir, PKGMAN_BuildPackagesScript, gap_root, dir);
  if exec = fail or exec.code <> 0 or PositionSublist(exec.output, "Failed to build") <> fail then
    Info(InfoPackageManager, 1, "Compilation failed for package '", info.PackageName, "'");
    Info(InfoPackageManager, 1, "(package may still be usable)");
    if exec <> fail then
      PKGMAN_InfoWithIndent(2, exec.output, 2);
    fi;
    return false;
  else
    PKGMAN_InfoWithIndent(3, exec.output, 2);
  fi;
  Info(InfoPackageManager, 4, "Compilation was successful");
  return true;
end);
