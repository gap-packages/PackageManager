InstallGlobalFunction(PKGMAN_FlushOutput,
function()
    Print("\c");
end);

InstallGlobalFunction(PKGMAN_AskYesNoQuestion,
function(question...)
  local stream, out, default, ans;

  question := Concatenation(question);
  stream := InputTextUser();

  Print(question);
  default := ValueOption( "default" );
  if default = true then
    Print(" [Y/n] "); PKGMAN_FlushOutput();
  elif default = false then
    Print(" [y/N] "); PKGMAN_FlushOutput();
  else
    default := fail;
    Print(" [y/n] "); PKGMAN_FlushOutput();
  fi;

  while true do
    ans := CharInt(ReadByte(stream));
    if ans in "yYnN" then
      Print([ans,'\n']);
      ans := ans in "yY";
      break;
    elif ans in "\n\r" and default <> fail then
      Print("\n");
      ans := default;
      break;
    elif ans = '\c' then
      # HACK since Ctrl-C does not work
      Print("\nUser aborted\n");
      # HACK, undocumented command
      JUMP_TO_CATCH("abort");
    fi;
  od;

  CloseStream(stream);
  return ans;
end);
