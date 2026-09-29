InstallGlobalFunction(PKGMAN_InstallFromGit,
function(url, prefs)
  local branch, name, repos, success, repo, result, dir, exec, info;
  branch := fail; # TODO: support branch option
  
  # Get package name
  name := PKGMAN_NameOfGitRepo(url);
  if name = fail then
    Info(InfoPackageManager, 1, "Could not find repository name (bad URL?)");
    return false;
  fi;

  # Check for existing repository
  repos := PKGMAN_UserPackageGitRepoPaths(name);
  success := true;
  for repo in repos do
    Info(InfoPackageManager, 1, "Existing git repository for ", name, " found");
    Info(InfoPackageManager, 2, "at ", repo);
    if PKGMAN_Pref("git", prefs, "Upgrade via git pull?") then
      result := PKGMAN_GitPullDirectory(repo);
      if result = true then
        dir := repo;
      else
        success := false;
      fi;
    fi;
  od;
  
  # No existing repository: clone!
  if IsEmpty(repos) then
    # Check for a valid location
    dir := Filename(Directory(PKGMAN_PackageDir()), name);
    if not PKGMAN_IsValidTargetDir(dir) then
      return false;
    fi;

    # Do the cloning
    Info(InfoPackageManager, 2, "Cloning to ", dir, " ...");
    if branch = fail then
      exec := PKGMAN_Exec(".", "git", "clone", url, dir);
    else
      exec := PKGMAN_Exec(".", "git", "clone", url, dir, "-b", branch);
    fi;

    # Was the download successful?
    if exec.code <> 0 then
      Info(InfoPackageManager, 1, "Cloning unsuccessful");
      return false;
    fi;
    Info(InfoPackageManager, 3, "Package cloned successfully");
    PKGMAN_RefreshPackageInfo();

    # Check for PackageInfo.g
    info := Filename(Directory(dir), "PackageInfo.g");
    if not IsReadableFile(info) then
      Info(InfoPackageManager, 1, "Could not find PackageInfo.g");
      return false;
    fi;
  fi;
  
  # Compile, dependencies and make doc
  success := success and PKGMAN_CheckPackageBasic(dir) and PKGMAN_FinishPackageSetup(dir, prefs);
  return success;
 end);

InstallGlobalFunction(PKGMAN_NameOfGitRepo,
function(url)
  local parts, n;
  parts := SplitString(url, "", "/:. \n\t\r");
  n := Length(parts);
  if n > 0 and parts[n] <> "git" then
    return parts[n];
  elif n > 1 and parts[n] = "git" then
    return parts[n - 1];
  fi;
  return fail;
end);

InstallGlobalFunction(PKGMAN_UserPackageGitRepoPaths,
function(name)
  # Returns a list of paths to all user-installed git repos for this package
  local info, dirs, repos;
  info := PKGMAN_UserPackageInfo(name);
  dirs := List(info, i -> i.InstallationPath);
  repos := Filtered(dirs, PKGMAN_IsGitRepoDir);
  return repos;
end);

InstallGlobalFunction(PKGMAN_IsGitRepoDir,
dir -> IsDirectoryPath(Concatenation(dir, ".git/")));

InstallGlobalFunction(PKGMAN_GitPullDirectory,
function(dir)
  local status, pull, line;
  Info(InfoPackageManager, 3, "Checking git status in ", dir, "...");
  status := PKGMAN_Exec(dir, "git", "status", "-s");
  if status = fail then
    return false;
  elif status.code = 0 and status.output = "" then
    Info(InfoPackageManager, 3, "Pulling from git repository...");
    pull := PKGMAN_Exec(dir, "git", "pull", "--ff-only");
    for line in SplitString(pull.output, "\n") do
      Info(InfoPackageManager, 3, "git: ", line);
    od;
    return pull.code = 0;
  else
    Info(InfoPackageManager, 1, "Uncommitted changes in git repository");
    Info(InfoPackageManager, 2, "(at ", dir, ")");
    return false;
  fi;
end);
