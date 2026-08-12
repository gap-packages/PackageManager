#############################################################################
##
##  A small HTTP server for the tests, so that they do not depend on any
##  remote server being reachable.  Requires the IO package.
##
##  Adapted from the equivalent file in the utils package.
##
##  The server hands out the files in a document root directory, which is
##  prepared by PKGMAN_PrepareTestData from the contents of tst/data.  Since
##  the server listens on an arbitrary free port, files that need to refer to
##  the server itself contain the placeholder "@SERVER@", which is replaced by
##  the actual address when such a file is served (but not when it is packed
##  into a tarball).
##

##  Note that we assign the globals below instead of using BindGlobal, since
##  several test files read this file in the same GAP session.

# Set by PKGMAN_StartHTTPTestServer before forking, so that the forked
# processes inherit them.
PKGMAN_HTTPTestRoot := fail;
PKGMAN_HTTPTestAddress := fail;

PKGMAN_HandleHTTPTestRequest := function(listener, socket)
  local connection, line, parts, name, pos, body, status;

  IO_close(listener);
  connection := IO_WrapFD(socket, IO.DefaultBufSize, IO.DefaultBufSize);
  line := IO_ReadLine(connection);
  parts := SplitString(line, " \r\n");
  if Length(parts) < 2 then
    IO_Close(connection);
    IO_exit(1);
  fi;

  # Skip the request headers
  repeat
    line := IO_ReadLine(connection);
  until line = fail or line = "" or line = "\n" or line = "\r\n";

  # We serve a flat directory only, so the file name must be a plain name
  name := parts[2];
  pos := Position(name, '?');
  if pos <> fail then
    name := name{[1 .. pos - 1]};
  fi;
  if StartsWith(name, "/") then
    name := name{[2 .. Length(name)]};
  fi;
  if name = "" or '/' in name or name = ".." then
    body := fail;
  else
    body := StringFile(Filename(Directory(PKGMAN_HTTPTestRoot), name));
  fi;

  if body = fail then
    status := "404 Not Found";
    body := "no such file\n";
  else
    status := "200 OK";
    if not ForAny([".tar.gz", ".tar.bz2"], ext -> EndsWith(name, ext)) then
      body := ReplacedString(body, "@SERVER@", PKGMAN_HTTPTestAddress);
    fi;
  fi;

  IO_Write(connection,
           "HTTP/1.1 ", status, "\r\n",
           "Content-Type: application/octet-stream\r\n",
           "Content-Length: ", String(Length(body)), "\r\n",
           "Connection: close\r\n\r\n",
           body);
  IO_Flush(connection);
  IO_Close(connection);
  IO_exit(0);
end;

# Start the server in a forked process, serving the files in the directory
# <root> on an ephemeral port of the loopback interface.  Returns a record
# with components 'pid' and 'url', the latter being the base URL.
PKGMAN_StartHTTPTestServer := function(root)
  local listener, address, port, pid, socket, handler;

  listener := IO_socket(IO.PF_INET, IO.SOCK_STREAM, "tcp");
  if listener = fail or
     IO_bind(listener, IO_MakeIPAddressPort("127.0.0.1", 0)) = fail or
     IO_listen(listener, 8) <> true then
    Error("cannot start the HTTP test server");
  fi;
  address := IO_getsockname(listener);
  port := 256 * INT_CHAR(address[3]) + INT_CHAR(address[4]);

  PKGMAN_HTTPTestRoot := root;
  PKGMAN_HTTPTestAddress := Concatenation("127.0.0.1:", String(port));

  pid := IO_fork();
  if pid = 0 then
    while true do
      socket := IO_accept(listener, IO_MakeIPAddressPort("0.0.0.0", 0));
      if socket = fail then
        IO_exit(0);
      fi;
      handler := IO_fork();
      if handler = 0 then
        PKGMAN_HandleHTTPTestRequest(listener, socket);
      elif handler < 0 then
        IO_close(socket);
        IO_exit(1);
      else
        IO_close(socket);
        IO_IgnorePid(handler);
      fi;
    od;
  elif pid < 0 then
    IO_close(listener);
    Error("cannot fork the HTTP test server");
  fi;

  IO_close(listener);
  return rec(pid := pid,
             url := Concatenation("http://", PKGMAN_HTTPTestAddress));
end;

PKGMAN_StopHTTPTestServer := function(server)
  IO_kill(server.pid, IO.SIGTERM);
  IO_WaitPid(server.pid, true);
end;

# A URL on the loopback interface with nothing listening on it, so that
# connecting to it fails immediately.  We ask the kernel for a free port and
# then release it again; note that we deliberately do not simulate an
# unresponsive server instead, since wget would retry that many times.
PKGMAN_UnusedURL := function()
  local socket, address, port;

  socket := IO_socket(IO.PF_INET, IO.SOCK_STREAM, "tcp");
  if socket = fail or
     IO_bind(socket, IO_MakeIPAddressPort("127.0.0.1", 0)) = fail then
    Error("cannot find an unused port");
  fi;
  address := IO_getsockname(socket);
  port := 256 * INT_CHAR(address[3]) + INT_CHAR(address[4]);
  IO_close(socket);
  return Concatenation("http://127.0.0.1:", String(port));
end;

# Assemble a document root for the test server in a temporary directory: the
# plain files of tst/data, plus a tarball of each dummy package version.  Note
# that the tarballs are built here rather than checked in, so that their
# contents stay reviewable.
PKGMAN_PrepareTestData := function()
  local data, root, name, exec;

  data := Filename(DirectoriesPackageLibrary("PackageManager", "tst"), "data");
  root := Filename(DirectoryTemporary(), "");

  for name in ["badurls.txt", "pkglist.csv"] do
    exec := PKGMAN_Exec(".", "cp", Filename(Directory(data), name), root);
    if exec.code <> 0 then
      Error("cannot copy the test data");
    fi;
  od;

  # The PackageInfo.g of the newest version, as the distribution serves it
  exec := PKGMAN_Exec(".", "cp",
                      Filename(Directory(data), "new/pmdummy/PackageInfo.g"),
                      root);
  if exec.code <> 0 then
    Error("cannot copy the test data");
  fi;

  # Both tarballs unpack into a directory "pmdummy" without a version number
  for name in [["old", "1.0"], ["new", "2.0"]] do
    exec := PKGMAN_Exec(".", "tar", "-czf",
                        Filename(Directory(root),
                                 Concatenation("pmdummy-", name[2], ".tar.gz")),
                        "-C", Filename(Directory(data), name[1]), "pmdummy");
    if exec.code <> 0 then
      Error("cannot build the dummy package tarballs");
    fi;
  od;

  return root;
end;
