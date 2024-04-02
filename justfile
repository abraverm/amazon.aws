# run ansible unit tests for changed files only
aws-full-unit-test:
  #!/usr/bin/env sh
  cd ansible_collections/amazon/aws
  ansible-test units --venv -v
  rm -rf collections

aws-changed-unit-test:
  #!/usr/bin/env sh
  cd ansible_collections/amazon/aws
  ansible-test units --venv -v --changed
  rm -rf collections