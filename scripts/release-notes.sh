#!/bin/bash

DIR=$(dirname "${0}")
echo "${DIR}"
echo "HASH=$(git rev-parse HEAD)" >>$GITHUB_ENV
echo "${{ env.HASH }}"
# Get list of commits since last tag
LAST_TAG=$(git describe --match "v*" --abbrev=0)
echo "${LAST_TAG}"
COMMITS=$(git log --pretty='- %s' ${LAST_TAG}..HEAD | tac)
echo "${COMMITS}"
# Prepare template for release notes file
NOTES_FILE=$(mktemp /tmp/caduceus-release-notes.$$.XXXXXX)
cat <<EOF > ${NOTES_FILE}
__What's New?__

${COMMITS}

# This will be used to prepare Release Notes.
# Lines starting with # will be stripped out.
EOF

# Let user edit notes and then reconfirm
vi ${NOTES_FILE}
ENCODED_NOTES=$(grep -v '^#' ${NOTES_FILE} | base64  | tr -d \\n)
rm -f ${NOTES_FILE}

# Reconfirm, mimicing what CI will do
echo "-------------------------------------------------------------------------"
echo "${ENCODED_NOTES}" | base64 -d
echo "-------------------------------------------------------------------------"
read -p "Continue? " -r
[[ "${REPLY}" =~ ^[Yy]$ ]] || {
  echo "Aborted, no release triggered!"
  exit 2
}

# Pick current local version hash and send it also for verification -
# We want to make sure CI will publish the version we intended and not something newer.
echo "HASH=$(git rev-parse HEAD)" >>$GITHUB_ENV
echo "${{ env.HASH }}"

# Trigger release
#"${DIR}/dispatch-event.sh" "trigger-release" "{ \"hash\": \"${HASH}\", \"notes\": \"${ENCODED_NOTES}\" }"
