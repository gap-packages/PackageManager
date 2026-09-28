InstallMethod(InstallPackage,
"for a string and a boolean (deprecated)",
[IsString, IsBool],
{string, interactive} -> InstallPackage(string, rec(interactive := interactive)));

InstallMethod(RemovePackage,
"for a string and a boolean (deprecated)",
[IsString, IsBool],
{string, interactive} -> RemovePackage(string, rec(interactive := interactive)));
