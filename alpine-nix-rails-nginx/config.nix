{
  packageOverrides = pkgs: {
    nginx = pkgs.nginx.override { moreheaders = true; };
  };
}
