InstallGlobalFunction(InstallPackageFromName,
function(name, opts)
  local required, upgrade, requirements, graph, upgrade_plan,
        no_upgrade_plan, plan;

  required := PKGMAN_Option("version", opts);
  upgrade := PKGMAN_Option("upgrade", opts); # might be "ask"

  # Get all-upgrades installation plan
  if upgrade in [true, "ask"] then
    requirements := [[name, required]];
    graph        := PKGMAN_DependencyGraph(requirements, opts);
    upgrade_plan := PKGMAN_InstallationPlan(graph, true);
  else
    upgrade_plan := fail;
  fi;

  # Get no-upgrade installation plan
  if upgrade in [false, "ask"] then
    requirements    := PKGMAN_UnsatisfiedRequirements(name, required);
    graph           := PKGMAN_DependencyGraph(requirements, opts);
    no_upgrade_plan := PKGMAN_InstallationPlan(graph, false);
  else
    no_upgrade_plan := fail;
  fi;
  
  # Figure out which plan to follow
  if no_upgrade_plan = fail then
    if upgrade_plan = fail then
      # no valid plan
      Info(InfoPackageManager, 1, "No valid installation plan for ", name, " and its dependencies");
      return false;
    elif PKGMAN_Option("upgrade", opts, "Some packages will need to be upgraded. Okay?") then
      # must follow upgrade plan (if we get permission)
      plan := upgrade_plan;
      PKGMAN_ShowInstallationPlan(plan, []);
    else
      # must follow upgrade plan, but options don't allow upgrades
      Info(InfoPackageManager, 1, "Some package upgrades are required, but are not allowed");
      return false;
    fi;
  elif upgrade_plan = fail then
    # must follow no-upgrade plan (is this possible?)
    plan := no_upgrade_plan;
    PKGMAN_ShowInstallationPlan(plan, []);
  elif Set(upgrade_plan) = Set(no_upgrade_plan) then
    # both plans are the same
    plan := no_upgrade_plan;
    PKGMAN_ShowInstallationPlan(plan, []);
  else
    Assert(1, IsSubset(upgrade_plan, no_upgrade_plan));
    PKGMAN_ShowInstallationPlan(no_upgrade_plan, Difference(upgrade_plan, no_upgrade_plan));
    if PKGMAN_Option("upgrade", opts, "Include optional upgrades?") then
      # user prefers the upgrade plan
      plan := upgrade_plan;
    else
      # user prefers the no-upgrade plan
      Info(InfoPackageManager, 3, "Optional upgrades will not be installed");
      plan := no_upgrade_plan;
    fi;
  fi;
  
  # Nothing to do?
  if IsEmpty(plan) then
    Info(InfoPackageManager, 3, "All requirements are satisfied");
    return true;
  fi;

  # Confirm install
  if not PKGMAN_Option("install", opts, "Continue?") then
    Info(InfoPackageManager, 1, "Installation aborted");
    return true; # TODO: appropriate return value?
  fi;
  
  # Install and extract packages
  # Compile packages (in reverse order) # TODO: ordering instead of sorting?
  return plan;
end);

InstallGlobalFunction(PKGMAN_UnsatisfiedRequirements,
function(name, required)
  local installed;
  # TODO: this is recursive so it'll run forever if there are cyclic deps
  installed := PKGMAN_UserPackageInfo(name);
  if IsEmpty(installed) or not CompareVersionNumbers(installed[1].Version, required) then
    return [[name, required]];
  fi;
  return Concatenation(List(installed[1].Dependencies.NeededOtherPackages,
                            dep -> PKGMAN_UnsatisfiedRequirements(dep[1], dep[2])));
end);

InstallGlobalFunction(PKGMAN_DependencyGraph,
function(requirements, opts)
  # requirements: a list of pairs of the form [package_name, required_version]
  local metadata, queue, next, graph, name, required, info, installed, current,
        upgradable, dependencies, suggested, d, pos, package, i, graphPackage,
        required_version;
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
                  ));
  od;
  
  # Replace dependency names with pointers to graph indices
  for package in graph do
    for d in package.dependencies do
      i := PositionProperty(graph, p -> LowercaseString(p.name) = LowercaseString(d[1]));
      Assert(1, i <> fail);
      d[1] := i;
    od;
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

InstallGlobalFunction(PKGMAN_InstallationPlan,
function(graph, allow_upgrades)
  local plan, package;
  plan := [];
  for package in graph do
    if package.upgradeNeeded and package.current <> fail and not allow_upgrades then
      return fail;
    fi;
    if package.upgradable and (package.current = fail or allow_upgrades) then
      Add(plan, rec(name := package.name, current := package.current, newest := package.newest));
    fi;
  od;
  return plan;
end);

InstallGlobalFunction(PKGMAN_ShowInstallationPlan,
function(needed, optional)
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

InstallGlobalFunction(InstallRequiredPackages,
{} -> ForAll(GAPInfo.Dependencies.NeededOtherPackages, p -> InstallPackageFromName(p[1])));

InstallGlobalFunction(RefreshPackageMetadata,
function()
  local download, instream, out, json;
  download := PKGMAN_DownloadURL(PKGMAN_PackageMetadataUrl);
  # TODO: check download.success
  instream := InputTextString(download.result);;
  out := PKGMAN_Exec(".", "gunzip" : instream := instream);;
  # TODO: check out.code
  json := out.output;
  PKGMAN_PackageMetadataCache := PKGMAN_JsonToGap(json);
end);

InstallGlobalFunction(PKGMAN_PackageMetadata,
function()
  if PKGMAN_PackageMetadataCache = fail then
    RefreshPackageMetadata();
  fi;
  return PKGMAN_PackageMetadataCache;
end);
