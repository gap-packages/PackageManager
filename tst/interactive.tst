# PKGMAN_AskYesNoQuestion (tested via hacked streams)
gap> f_in := InputTextUser;;
gap> MakeReadWriteGlobal("InputTextUser");
gap> InputTextUser := {} -> InputTextString("w\nn");;
gap> PKGMAN_AskYesNoQuestion("Do you like ice cream?");
Do you like ice cream? [y/n] n
false
gap> PKGMAN_AskYesNoQuestion("You like ice cream, right?" : default := true);
You like ice cream, right? [Y/n] 
true
gap> InputTextUser := {} -> InputTextString("\cw\nn");;
gap> PKGMAN_AskYesNoQuestion("Do you like ice cream?");
Do you like ice cream? [y/n] 
User aborted
gap> InputTextUser := f_in;;
gap> MakeReadOnlyGlobal("InputTextUser");
gap> Print(InputTextUser, "\n");
function (  )
    return InputTextFile( "*stdin*" );
end
