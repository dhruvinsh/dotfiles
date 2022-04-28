#!/usr/bin/env bash

exec shellcheck -s bash -x \
  home/.chezmoiscripts/linux/*.sh \
  scripts/*.bash \
