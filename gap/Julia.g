# We know that PackageManager's `PKGMAN_DownloadURL` is already bound
# when this file gets read.
# If the GAP session has access to a Julia session,
# via the Julia package GAP.jl (which we detect from the availability
# of the GAP package JuliaInterface),
# then we use the Julia package Downloads.jl for the download.
# (Note that Downloads.jl gets loaded by GAP.jl.)
# For that, we replace the code of `PKGMAN_DownloadURL`.

if IsBound(Julia) then
  MakeReadWriteGlobal("PKGMAN_DownloadURL");
  UnbindGlobal("PKGMAN_DownloadURL");
  BindGlobal("PKGMAN_DownloadURL", function(url)
    local res;

    res := Julia.GAP.call_with_catch(
             Julia.GAP.UnwrapJuliaFunc(Julia.GAP.kwarg_wrapper),
               GAPToJulia([Julia.GAP.Packages.Downloads.download,
                   [Julia.string(url), Julia.IOBuffer()],
                   rec(downloader:= Julia.getindex(
                         Julia.GAP.Packages.DOWNLOAD_HELPER))]));
    if res[1] = true then
      res := Julia.String(Julia.take\!(res[2]));
      return rec(success := true, result := JuliaToGAP(IsString, res));
    else
      return rec(success := false);
    fi;
  end);
fi;
