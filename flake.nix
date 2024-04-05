{
  description = "Amazon AWS Ansible Collection";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          ( final: prev: {
            ansible-locale-archive = prev.ansible.overrideAttrs (old: rec {
              name = "${pname}-${old.version}";
              pname = "ansible-locale-archive";
              patches = (old.patches or [ ]) ++ [
                ./ansible-locale-archive.patch
              ];
            }); 
          })
        ];
      };
      devEnv = (pkgs.buildFHSUserEnv {
        name = "amazon.aws";
        targetPkgs = pkgs: (with pkgs; [
          micromamba
          just
          ansible-locale-archive
          zsh
        ]);
        runScript = "zsh";

        profile = ''
        eval "$(micromamba shell hook -s posix)"
        export MAMBA_ROOT_PREFIX=./.mamba
        if [[ ! -d ".mamba/envs/amazon_aws" ]]; then
          echo 'Creating environment'
          micromamba create -q -n amazon_aws -y -c conda-forge python="3.11"
        fi
        echo 'Activating environment'
        micromamba activate amazon_aws -q
        echo 'Installing requirements'
        micromamba install --yes -c conda-forge -f requirements.txt -q
        pip install MonkeyType -q
        pip install -r test-requirements.txt -q
        '';


      }).env;
    in {
      devShells.default = devEnv;
      packages.default = devEnv;
    }
  );
}
