InstallMethod(PKGMAN_Pref,
"for a string and a record",
[IsString, IsRecord],
function(name, prefs)
  if name in RecNames(prefs) then
    return prefs.(name);
  fi;
  return UserPreference("PackageManager", name);
end);

InstallMethod(PKGMAN_Pref,
"for a string, a record and a string",
[IsString, IsRecord, IsString],
function(name, prefs, question)
  local value;
  value := PKGMAN_Pref(name, prefs);
  if value = "ask" then
    value := PKGMAN_AskYesNoQuestion(question : default := true);
  fi;
  return value;
end);
