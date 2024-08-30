InstallGlobalFunction(CompilePackage,
function(name)
  local user_pkg_dir, allinfo, info;

  # Check input
  if not IsString(name) then
    ErrorNoReturn("PackageManager: CompilePackage: ",
                  "<name> must be a string");
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
    return false;
  fi;

  # Compile it
  return PKGMAN_CompileDir(info[1].InstallationPath);
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
