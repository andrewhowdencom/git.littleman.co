#!/bin/bash

set -e

git notes append "$GIT_HASH" -m "Deployment Failure"

# Push the notes to origin
git push origin /refs/notes/*
>&2 echo "$TRAVIS_BUILD_NUMBER"
>&2 echo "$TRAVIS_JOB_NUMBER"
>&2 echo "$TRAVIS_JOB_ID"
