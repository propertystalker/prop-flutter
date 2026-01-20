# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05";

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk21
    pkgs.unzip
    pkgs.openssh
    pkgs.postgresql
    pkgs.supabase-cli
    pkgs.docker
  ];

  # Enable the Docker daemon service, making it available to the workspace.
  services.docker.enable = true;

  # Sets environment variables in the workspace
  env = {};

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      # Runs when a workspace is first created
      onCreate = {};
      # Runs on every workspace startup
      onStart = {};
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT" ];
          manager = "flutter";
        };
      };
    };
  };
}
