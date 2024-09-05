InstallGlobalFunction(CompilePackage,
function(name)
  local info;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("<name> must be a string");
  fi;

  # Locate the package
  name := LowercaseString(name);
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
  local prerequisites, exec, pkg_dir, scr, root, info;

  info := PKGMAN_GetPackageInfo(dir);
  if info = fail then
    return false;
  fi;

  # Run the prerequisites file if it exists
  # Note: this is mainly for installing Semigroups from GitHub
  prerequisites := Filename(Directory(dir), "prerequisites.sh");
  if IsReadableFile(prerequisites) then
    Info(InfoPackageManager, 3,
         "Running prerequisites.sh for ", info.PackageName, "...");
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
         "Compilation failed for package '",
         info.PackageName,
         "' (package may still be usable)");
    Info(InfoPackageManager, 2, exec.output);
    return false;
  else
    Info(InfoPackageManager, 3, exec.output);
  fi;
  Info(InfoPackageManager, 4, "Compilation was successful");
  return true;
end);
