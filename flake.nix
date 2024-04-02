{
  description = "qestor ansible playbook";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      devEnv = (pkgs.buildFHSUserEnv {
        name = "qestor";
        targetPkgs = pkgs: (with pkgs; [
          micromamba
          just
          vscodium
        ]);
        runScript = "zsh";

        profile = ''
        export LC_ALL="C.UTF-8"
        eval "$(micromamba shell hook -s posix)"
        export MAMBA_ROOT_PREFIX=./.mamba
        if [[ ! -d ".mamba/envs/qestor" ]]; then
          echo 'Creating environment'
          micromamba create -q -n qestor
        fi
        echo 'Activating environment'
        micromamba activate qestor -q
        echo 'Installing requirements'
        micromamba install --yes -c conda-forge -f requirements.txt -q
        micromamba install --yes -c conda-forge -f test-requirements.txt -q
        '';


      }).env;
    in {
      devShells.default = devEnv;
      packages.default = devEnv;
    }
  );
}
