#!/bin/bash

#######################################
# Update codex and opencode
#######################################

die() {
	echo ERROR: "$@"
	exit 1
}

# update codex
npm install -g @openai/codex || die "Update codex Failed!"

# update opencode
npm install -g opencode-ai

echo "Update code tools ok."
