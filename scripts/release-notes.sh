#!/bin/bash

DIR=$(dirname "${0}")
echo "${DIR}"
echo "HASH=$(git rev-parse HEAD)" >>$GITHUB_ENV
echo "${{ env.HASH }}"

