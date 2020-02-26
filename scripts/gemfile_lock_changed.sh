#!/bin/sh

ERROR_MSG=$(cat << EOF
  Gemfile was updated but Gemfile.lock was not updated.

  Usually, when Gemfile is updated, you should run
  \`\`\`
  bundle install
  \`\`\`

  or

  \`\`\`
  bundle update <the-added-or-updated-gem>
  \`\`\`

  and commit the Gemfile.lock changes.
EOF
)

function gemfile_lock_changed() {
  if [ ! -z "$(git diff --name-only -- Gemfile.lock)" ]; then
    printf "$ERROR_MSG"

    exit 1
  fi
}

gemfile_lock_changed
