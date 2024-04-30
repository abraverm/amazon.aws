default:
    @{{just_executable()}} --list

# run ansible unit tests for changed files only
aws-full-unit-test:
  #!/usr/bin/env sh
  cd ansible_collections/amazon/aws
  ansible-test units --venv -v
  rm -rf collections

# run ansible unit tests for changed files only
aws-changed-unit-test:
  #!/usr/bin/env sh
  cd ansible_collections/amazon/aws
  ansible-test units --venv -v --changed
  rm -rf collections

generate-stubs targets:
  #!/usr/bin/env sh
  source <(gpg -d aws_creds.gpg)
  monkeytype run stubgenerate.py -t {{targets}}

apply-stubs:
  monkeytype list-modules | xargs -n 1 monkeytype apply

integration-test target:
  #!/usr/bin/env bash
  set -x
  rm -rf ~/.aws
  exclude="($(ls plugins/modules/*.py | grep -v {{target}} | sed -e 's/plugins\/modules\///' -e 's/\.py//' | tr '\n' '|' | sed 's/|$//'))"
  /usr/bin/ansible-test integration --local --exclude $exclude --python-interpreter $PWD/.mamba/envs/amazon_aws/bin/python3.11 -vv