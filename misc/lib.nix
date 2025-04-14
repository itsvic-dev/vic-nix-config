lib: {
  importAllFromFolder = folder:
    let
      toImport = name: value: folder + ("/" + name);
      imports = lib.mapAttrsToList toImport (builtins.readDir folder);
    in imports;
}
