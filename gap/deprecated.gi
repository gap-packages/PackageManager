InstallMethod(InstallPackage,
"for a string and a boolean (deprecated)",
[IsString, IsBool],
{string, interactive} -> InstallPackage(string, rec(interactive := interactive)));

InstallMethod(RemovePackage,
"for a string and a boolean (deprecated)",
[IsString, IsBool],
{string, interactive} -> RemovePackage(string, rec(interactive := interactive)));

InstallMethod(InstallPackage,
"for a string and a string (deprecated)",
[IsString, IsString],
{string, branch} -> InstallPackage(string, rec(branch := branch)));

InstallMethod(InstallPackage,
"for a string, a boolean and a string (deprecated)",
[IsString, IsBool, IsString],
{string, interactive, branch} -> InstallPackage(string, rec(interactive := interactive, branch := branch)));
