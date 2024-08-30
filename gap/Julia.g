# We know that PackageManager's `PKGMAN_DownloadURL` is already bound
# when this file gets read.
# If the GAP session has access to a Julia session,
# via the Julia package GAP.jl (which we detect from the availability
# of the GAP package JuliaInterface),
# then we use the Julia package Downloads.jl for the download.
# (Note that Downloads.jl gets loaded by GAP.jl.)
# For that, we replace the code of `PKGMAN_DownloadURL`.

if IsBound(Julia) and JuliaImportPackage("Downloads") = true then
  MakeReadWriteGlobal("PKGMAN_DownloadURL");
  UnbindGlobal("PKGMAN_DownloadURL");
  BindGlobal("PKGMAN_DownloadURL", function(url)
    local res;

    res := CallJuliaFunctionWithCatch(Julia.Downloads.download,
               [Julia.string(url), Julia.IOBuffer()]);
    if res.ok then
      res := Julia.String(Julia.("take!")(res.value));
      return rec(success := true, result := JuliaToGAP(IsString, res));
    else
      return rec(success := false);
    fi;
  end);
fi;
