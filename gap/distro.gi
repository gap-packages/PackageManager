InstallGlobalFunction(InstallPackageFromName,
function(name, opts)
  local graph, unsatisfied, upgradable, marked;
  graph       := PKGMAN_DependencyGraph(name, opts);
  name        := graph[1].name;  # standard capitalisation
  #unsatisfied := PKGMAN_UnsatisfiedDependencies(graph);
  #upgradable  := PKGMAN_UpgradableDependencies(graph);

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
         PKGMAN_Option("upgrade", opts, "Do you want to upgrade the package and its dependencies?") then
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

  # Do something with the graph
  return graph;
end);

InstallGlobalFunction(PKGMAN_DependencyGraph,
function(name, opts)
  local metadata, queue, next, graph, info, installed, current, dependencies, d, package, i;

  metadata := PKGMAN_PackageMetadata();
  queue := [LowercaseString(name)];
  next := 1;
  graph := [];
  while next <= Length(queue) do
    name := queue[next];
    next := next + 1;
    if not IsBound(metadata.(name)) then
      Error("missing dep ", name);
      continue;
    fi;
    info := metadata.(name);
    installed := PKGMAN_UserPackageInfo(name);
    if IsEmpty(installed) then
      current := fail;
    else
      current := installed[1].Version;
    fi;
    dependencies := info.Dependencies.NeededOtherPackages;
    for d in dependencies do
      if not LowercaseString(d[1]) in queue then
        Add(queue, LowercaseString(d[1]));
      fi;
    od;
    Print(queue, "\n");
    Add(graph, rec(name := info.PackageName,
                   newest := info.Version,
                   current := current,
                   dependencies := dependencies));
  od;
  for package in graph do
    for d in package.dependencies do
      i := PositionProperty(graph, p -> LowercaseString(p.name) = LowercaseString(d[1]));
      Assert(1, i <> fail);
      d[1] := i;
    od;
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
