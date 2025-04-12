InstallGlobalFunction(InstallPackageFromName,
function(name, opts)
  local graph, unsatisfied, upgradable, marked, print_upgrade;
  graph       := PKGMAN_DependencyGraph([[name, PKGMAN_Option("version", opts)]], opts);
  name        := graph[1].name;  # standard capitalisation
  unsatisfied := Filtered(graph, p -> p.unsatisfied);
  upgradable  := Filtered(graph, p -> p.upgradable);

  # Determine packages to install
  marked := unsatisfied;
  if graph[1].upgradable then
    if graph[1].current <> fail then
      Info(InfoPackageManager, 2, name, " ", graph[1].current, " is installed, but ", graph[1].newest, " is available");
      if PKGMAN_Option("upgrade", opts, "Do you want to upgrade the package and its dependencies?") then
        marked := upgradable;
      fi;
    else
      Info(InfoPackageManager, 2, name, " ", graph[1].newest, " is available");
      if Length(upgradable) > Length(unsatisfied) and
         PKGMAN_Option("upgrade", opts, "Do you want to upgrade all the package's dependencies?") then
        marked := upgradable;
      fi;
    fi;
  else
    Info(InfoPackageManager, 2, name, " ", graph[1].newest, " (latest) already installed");
    if Length(upgradable) > Length(unsatisfied) and
       PKGMAN_Option("upgrade", opts, "Do you want to upgrade the package's dependencies?") then
      marked := upgradable;
    fi;
  fi;

  # Print planned upgrades
  print_upgrade := function(p)
    PrintFormatted("{name}\n\t", p);
    if p.current <> fail then
      Print(p.current, " ");
    fi;
    PrintFormatted("-> {newest}\n", p);
  end;
  Perform(marked, print_upgrade);
  
  
  return graph;
end);

InstallGlobalFunction(PKGMAN_DependencyGraph,
function(requirements, opts)
  local metadata, queue, next, graph, name, info, installed, current,
        upgradable, dependencies, suggested, d, package, i, required;
  metadata := PKGMAN_PackageMetadata();
  suggested := PKGMAN_Option("suggested", opts, "Do you want to include suggested packages?");
  
  # Breadth-first search through dependencies, starting from input package
  queue := List(requirements, r -> LowercaseString(r[1]));
  next := 1;
  graph := [];
  while next <= Length(queue) do
    # Go to next package
    name := queue[next];
    next := next + 1;

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
    if suggested then
      Append(dependencies, StructuralCopy(info.Dependencies.SuggestedOtherPackages));
    fi;
    for d in dependencies do
      if not LowercaseString(d[1]) in queue then
        Add(queue, LowercaseString(d[1]));
      fi;
    od;

    # Add discovered data to queue
    Add(graph, rec(name         := info.PackageName,
                   newest       := info.Version,
                   current      := current,
                   dependencies := dependencies,
                   url          := info.ArchiveURL,
                   upgradable   := upgradable,
                   unsatisfied  := false,
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
  
  # Mark any unsatisfied requirements
  queue := List([1 .. Length(requirements)], 
                i -> [i, requirements[i][2]]);  # entries of the form [index, requiredVersion]
  while not IsEmpty(queue) do
    # Get next requirement to check
    next := Remove(queue);
    package := graph[next[1]];
    required := next[2];
    
    # Have we already marked this as unsatisfied?
    if package.unsatisfied then
      continue;
    fi;
    
    # Does this package require an upgrade?
    if package.current = fail or 
       not CompareVersionNumbers(package.current, required) then
      package.unsatisfied := true;
      
      # Add this package's dependencies to the queue
      Append(queue, package.dependencies);
    fi;
  od;
  return graph;
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
