InstallMethod(PKGMAN_Option,
"for a string and a record",
[IsString, IsRecord],
function(name, local_options)
  if name in RecNames(local_options) then
    return local_options.(name);
  elif name in RecNames(PKGMAN_GlobalOptions) then
    return PKGMAN_GlobalOptions.(name);
  fi;
  Error("'", name, "' is not a supported option");
end);

InstallMethod(PKGMAN_Option,
"for a string, a record and a string",
[IsString, IsRecord, IsString],
function(name, local_options, question)
  local value;
  value := PKGMAN_Option(name, local_options);
  if value = "ask" then
    value := PKGMAN_AskYesNoQuestion(question : default := true);
  fi;
  return value;
end);
