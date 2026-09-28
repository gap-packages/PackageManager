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
  local value, interactive;
  value := PKGMAN_Pref(name, prefs);
  interactive := PKGMAN_Pref("interactive", prefs);
  if value = "ask" then
    if interactive = false then
      value := true;
    else
      value := PKGMAN_AskYesNoQuestion(question : default := true);
    fi;
  fi;
  return value;
end);
