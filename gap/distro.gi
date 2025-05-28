InstallGlobalFunction(InstallPackageFromName,
function(name, opts)
  local requirements;
  requirements := [[name, PKGMAN_Option("version", opts)]];
  return PKGMAN_InstallRequirements(requirements, opts);
end);

InstallGlobalFunction(PKGMAN_InstallRequirements,
function(requirements, opts)
  local plan, urls, package, url, dirs;
  # requirements: list of [name, version] pairs

  plan := PKGMAN_InstallationPlan(requirements, opts);
  
  # No successful plan?
  if plan = fail then
    return false;
  fi;
  
  # Nothing to do?
  if IsEmpty(plan) then
    Info(InfoPackageManager, 3, "Nothing to install");
    return true;
  fi;

  # Confirm install
  if not PKGMAN_Option("proceed", opts, "Continue?") then
    Info(InfoPackageManager, 1, "Installation aborted");
    return false; # TODO: appropriate return value?
  fi;

  # Install packages
  dirs := List(plan, PKGMAN_PullOrExtractPackage);

  # Compile packages (in reverse order) # TODO: ordering instead of sorting?
  return List(Reversed(dirs), PKGMAN_CompileDir);
end);

InstallGlobalFunction(PKGMAN_PullOrExtractPackage,
function(package)
  # Run git pull on this package (if applicable) to try to get the newest
  # version. If this doesn't work, then download and extract the newest version
  # of this package by archive.
  # package: record from installation plan
  local repo, best, url;
  
  # Try pulling any git repos first
  for repo in package.repos do
    Info(InfoPackageManager, 3, "Found git repo at ", repo);
    PKGMAN_GitPullDirectory(repo); # TODO: use return value?
    PKGMAN_RefreshPackageInfo();
  od;
  best := PKGMAN_UserPackageInfo(package.name)[1];
  if CompareVersionNumbers(best.Version, package.newest) then
    return best.InstallationPath;
  fi;
  
  # Pulling didn't work: install via archive URL instead
  url := PKGMAN_UrlFromInfo(PKGMAN_PackageMetadata().(LowercaseString(package.name)));
  return InstallPackageFromArchive(url);
end);

InstallGlobalFunction(PKGMAN_InstallationPlan,
function(requirements, opts)
  local upgrade, graph, upgrade_plan, no_upgrade_plan, gitpull, plan, package;
  #
  # Turns a set of requirements into an installation plan that includes all
  # missing dependencies.
  #
  # We proceed by finding two different installation plans: one that includes
  # all available upgrades to the requirements and their dependencies; and one
  # that refuses to upgrade any packages that are already installed. We choose
  # a plan by consulting user options and if necessary interactive prompts.
  #
  upgrade := PKGMAN_Option("upgrade", opts); # might be "ask"

  # Get all-upgrades installation plan
  if upgrade in [true, "ask"] then
    graph        := PKGMAN_DependencyGraph(requirements, opts);
    upgrade_plan := PKGMAN_PlanFromGraph(graph, true);
  else
    upgrade_plan := fail;
  fi;

  # Get no-upgrade installation plan
  if upgrade in [false, "ask"] then
    requirements    := PKGMAN_UnsatisfiedRequirements(requirements, opts);
    graph           := PKGMAN_DependencyGraph(requirements, opts);
    no_upgrade_plan := PKGMAN_PlanFromGraph(graph, false);
  else
    no_upgrade_plan := fail;
  fi;
  
  # Use git pull?
  gitpull := upgrade_plan <> fail
             and ForAny(upgrade_plan, p -> not IsEmpty(p.repos)) 
             and PKGMAN_Option("gitpull", opts, "Allow upgrading via git pull?");
  
  # Figure out which plan to follow
  if no_upgrade_plan = fail then
    if upgrade_plan = fail then
      # no valid plan
      Info(InfoPackageManager, 1, "No valid installation plan for the required packages");
      return fail;
    elif PKGMAN_Option("upgrade", opts, "Some packages will need to be upgraded. Okay?") then
      # must follow upgrade plan (and we have permission)
      plan := upgrade_plan;
      PKGMAN_ShowInstallationPlan(plan, [], gitpull);
    else
      # must follow upgrade plan, but options don't allow upgrades
      Info(InfoPackageManager, 1, "Some package upgrades are required, but are not allowed");
      return fail;
    fi;
  elif upgrade_plan = fail then
    # must follow no-upgrade plan (is this possible?)
    plan := no_upgrade_plan;
    PKGMAN_ShowInstallationPlan(plan, [], gitpull);
  elif Set(upgrade_plan) = Set(no_upgrade_plan) then
    # both plans are the same
    plan := no_upgrade_plan;
    PKGMAN_ShowInstallationPlan(plan, [], gitpull);
  else
    Assert(1, IsSubset(upgrade_plan, no_upgrade_plan));
    PKGMAN_ShowInstallationPlan(no_upgrade_plan, Difference(upgrade_plan, no_upgrade_plan), gitpull);
    if PKGMAN_Option("upgrade", opts, "Include optional upgrades?") then
      # user prefers the upgrade plan
      plan := upgrade_plan;
    else
      # user prefers the no-upgrade plan
      Info(InfoPackageManager, 3, "Optional upgrades will not be installed");
      plan := no_upgrade_plan;
    fi;
  fi;
  
  # Disable git pulling if appropriate
  if not gitpull then
    plan := Filtered(plan, p -> p.upgradable);
    for package in plan do
      package.repos := [];
    od;
  fi;
  
  return plan;
end);

InstallGlobalFunction(PKGMAN_UnsatisfiedRequirements,
function(requirements, opts)
  local queue, i, unsatisfied, suggested, name, required, installed, dependencies, r;
  queue := ShallowCopy(requirements);
  i := 0;
  unsatisfied := [];
  suggested := PKGMAN_Option("suggested", opts, "Include all suggested packages?");
  while i < Length(queue) do
    # Go to next requirement
    i := i + 1;
    name := queue[i][1];
    required := queue[i][2];

    # Find any currently installed version
    installed := PKGMAN_UserPackageInfo(name);
    if IsEmpty(installed) or not CompareVersionNumbers(installed[1].Version, required) then
      # Not satisfied: add to output list
      Add(unsatisfied, queue[i]);
    else
      # Satisfied: consider dependencies
      dependencies := StructuralCopy(installed[1].Dependencies.NeededOtherPackages);
      if suggested and i <= Length(requirements) then
        Append(dependencies, StructuralCopy(installed[1].Dependencies.SuggestedOtherPackages));
      fi;
      for r in dependencies do
        if not ForAny(queue, q -> LowercaseString(q[1]) = LowercaseString(r[1])
                                  and CompareVersionNumbers(q[2], r[2])) then
          # New dependency: add to queue
          Add(queue, r);
        fi;
      od;
    fi;
  od;
  return unsatisfied;
end);

InstallGlobalFunction(PKGMAN_DependencyGraph,
function(requirements, opts)
  # requirements: a list [name, version] pairs
  local metadata, queue, next, graph, name, required, info, installed, current,
        upgradable, repos, dependencies, suggested, d, pos, package, i,
        graphPackage, required_version;
  if IsEmpty(requirements) then
    return [];
  fi;

  metadata := PKGMAN_PackageMetadata();
  suggested := PKGMAN_Option("suggested", opts, "Include all suggested packages?");
  
  # Breadth-first search through dependencies, starting from input package
  queue := List(requirements, r -> [LowercaseString(r[1]), [r[2]]]);
  i := 0;
  graph := [];
  while i < Length(queue) do
    # Go to next package
    i := i + 1;
    name := queue[i][1];

    # Find metadata for that package
    if not IsBound(metadata.(name)) then
      Info(InfoPackageManager, 1, name, " package not available from package distribution");
      Info(InfoPackageManager, 3, "You can install it by calling InstallPackage with a URL to the package archive");
      Unbind(queue[i]);
      continue;
    fi;
    info := metadata.(name);

    # Find any currently installed version
    installed := PKGMAN_UserPackageInfo(name);
    if IsEmpty(installed) then
      current := fail;
      upgradable := true;
    else
      current := installed[1].Version;
      upgradable := not CompareVersionNumbers(current, info.Version);
    fi;
    
    # Note any git repos that could be pulled
    repos := PKGMAN_UserPackageGitRepoPaths(name);

    # Add any new dependencies to the queue
    dependencies := StructuralCopy(info.Dependencies.NeededOtherPackages);
    if suggested and i <= Length(requirements) then
      Append(dependencies, StructuralCopy(info.Dependencies.SuggestedOtherPackages));
    fi;
    for d in dependencies do
      pos := PositionProperty(queue, r -> r[1] = LowercaseString(d[1]));
      if pos = fail then # add to queue if not present
        Add(queue, [LowercaseString(d[1]), []]);
        pos := Length(queue);
      fi;
      Add(queue[pos][2], d[2]); # record the required version
    od;

    # Add discovered data to queue
    Add(graph, rec(name         := info.PackageName,
                   newest       := info.Version,
                   current      := current,
                   dependencies := dependencies,
                   url          := info.ArchiveURL,
                   upgradable   := upgradable,
                   repos        := repos,
                  ));
  od;
  
  # For each package, check whether an upgrade is needed
  for package in queue do
    name := package[1];
    required := package[2];
    graphPackage := First(graph, p -> LowercaseString(p.name) = name);
    graphPackage.upgradeNeeded := false;
    for required_version in required do
      #Print(graphPackage.name, "\t", required_version, " needed,\t", graphPackage.current, " installed,\t", graphPackage.newest, " available\n");
      if graphPackage.current = fail or not CompareVersionNumbers(graphPackage.current, required_version) then
        graphPackage.upgradeNeeded := true;
      fi;
      if not CompareVersionNumbers(graphPackage.newest, required_version) then
        Info(InfoPackageManager, 1, "Could not satisfy");
      fi;
    od;
  od;
  
  return graph;
end);

InstallGlobalFunction(PKGMAN_PlanFromGraph,
function(graph, allow_upgrades)
  local plan, package;
  plan := [];
  for package in graph do
    if package.upgradeNeeded and package.current <> fail and not allow_upgrades then
      return fail;
    fi;
    if (package.upgradable or not IsEmpty(package.repos))
       and (package.current = fail or allow_upgrades) then
      # TODO: just Add(plan, package)?
      Add(plan, package);
    fi;
  od;
  return plan;
end);

InstallGlobalFunction(PKGMAN_ShowInstallationPlan,
function(needed, optional, gitpull)
  # Print info messages explaining what is going to be installed
  local show_package, indent, p;
  
  # Show a single line describing one package, with version number indented
  show_package := function(p, indent)
    local space, message;
    space := ListWithIdenticalEntries(indent - Length(p.name), ' ');
    message := Concatenation("  ", p.name, space);
    if p.current <> fail then
      message := Concatenation(message, p.current, " -> ");
    fi;
    message := Concatenation(message, p.newest);
    if gitpull and not IsEmpty(p.repos) then
      message := Concatenation(message, " or newer (git)");
    fi;
    Info(InfoPackageManager, 3, message);
  end;

  # Skip if nothing is here
  if IsEmpty(needed) and IsEmpty(optional) then
    return;
  fi;
  
  # Column to align version numbers
  indent := Maximum(List(Concatenation(needed, optional), p -> Length(p.name))) + 2;
  
  # Show required installs followed by optional upgrades
  if not IsEmpty(needed) then
    Info(InfoPackageManager, 3, "The following packages will be installed:");
    for p in needed do
      show_package(p, indent);
    od;
  fi;
  if not IsEmpty(optional) then
    Info(InfoPackageManager, 3, "The following optional upgrades are available:");
    for p in optional do
      show_package(p, indent);
    od;
  fi;
end);

InstallMethod(InstallRequiredPackages, "with no arguments", [],
{} -> InstallRequiredPackages(rec()));

InstallMethod(InstallRequiredPackages, "for a record", [IsRecord],
opts -> PKGMAN_InstallRequirements(GAPInfo.Dependencies.NeededOtherPackages, opts));

InstallGlobalFunction(RefreshPackageMetadata,
function(opts)
  local url, download, instream, out, json;
  url := StringFormatted(PKGMAN_Option(opts, "distroLocation"), 
                         PKGMAN_Option(opts, "distroVersion"));
  download := PKGMAN_DownloadURL(url);
  # TODO: check download.success
  instream := InputTextString(download.result);;
  out := PKGMAN_Exec(".", "gunzip" : instream := instream);;
  # TODO: check out.code
  json := out.output;
  PKGMAN_PackageMetadataCache := PKGMAN_JsonToGap(json);
end);

InstallGlobalFunction(PKGMAN_PackageMetadata,
function(opts)
  if PKGMAN_PackageMetadataCache = fail then
    RefreshPackageMetadata(opts);
  fi;
  return PKGMAN_PackageMetadataCache;  # TODO: store multiple caches based on options
end);
