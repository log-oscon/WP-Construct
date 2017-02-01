#!/bin/bash

# Intended to deploy a Composer controlled repo to a specific branch on the
# same remote or not.
#
# Usage: ./deploy-kinsta.sh -e environment -d destination
#
# Options:
# - environment, -e: current branch name [default]
#   The slug that identifies the deploy branch; the deploy branch name is based
#   on this, ex. deploy/production has a slug "production".
#
# - destination, -d: current repository [default]
#   The git repository that is to be used as the destination for the commit of the
#   deploy branch.

# TODO: Handle Git submodules

(
  # Uncomment these lines to profile the script
  # set -x
  # PS4='$(date "+%s.%N ($LINENO) + ")'

  WHOAMI=`whoami`

  ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)
  BUILD_DIR="$ROOT_DIR/.deploy_build"
  DIST_DIR="$ROOT_DIR/.deploy_git"

  DEPLOY_REPO=`git config --get remote.origin.url`

  RED='\e[0;31m'
  GREEN='\e[0;32m'
  YELLOW='\e[0;33m'
  RESET='\e[0m' # No Color

  # SETUP AND SANITY CHECKS
  # =======================
  while getopts e:d:live OPTION 2>/dev/null; do
    case $OPTION
    in
      e) ENVIRONMENT=${OPTARG};;
      d) DESTINATION=${OPTARG};;
    esac
  done

  echo -e "${YELLOW}Cleaning up...${RESET}"

  rm -rf "$BUILD_DIR"
  rm -rf "$DIST_DIR"

  # VALIDATIONS
  # ===========

  echo -e "Checking you have a Git user setup..."
  if [[ $(git config --list) != *user.email* || $(git config --list) != *user.name* ]]; then
    git config --global user.name "log.OSCON"
    git config --global user.email "engenharia@log.pt"
  fi

  if [ -z "$ENVIRONMENT" ]; then
    $ENVIRONMENT = $(git symbolic-ref --short HEAD)
  fi

  # Get around Codeship's shallow clones:
  git pull --unshallow

  # BUILD THE PROJECT
  # ==================

  echo -e "${YELLOW}Cloning the project for building...${RESET}"

  git clone --recursive "$ROOT_DIR" "$BUILD_DIR"
  if [ 0 != $? ]; then
    echo -e "${RED}There was an error cloning the repository.${RESET}"
    exit 3
  fi

  cd "$BUILD_DIR"

  echo -e "${YELLOW}Building the project for deployment...${RESET}"
  ls .scripts/
  bash $ROOT_DIR/.scripts/build.sh -l

  if [ 0 != $? ]; then
    echo -e "${RED}There was an error building the project.${RESET}"
    exit 4
  fi

  # DEPLOY THE PROJECT
  # ==================

  echo -e "${YELLOW}Cloning the project for deploying...${RESET}"

  git clone --recursive "$DEPLOY_REPO" "$DIST_DIR"
  if [ 0 != $? ]; then
    echo -e "${RED}There was an error cloning the repository.${RESET}"
    exit 5
  fi

  cd "$DIST_DIR"

  for remote in `git branch -r | grep deploy`; do git branch --track $remote; done

  # Attempt to switch to the deployment branch
  git checkout "deploy/${ENVIRONMENT}"
  if [ 0 != $? ]; then
    # Create a new orphan branch to track deployments
    git checkout --orphan "deploy/${ENVIRONMENT}"

    # Everything is being tracked, so remove it
    git rm --cached -r ./
  fi

  rsync -a --delete --exclude-from=.wpignore --exclude=.git --exclude=.gitignore "${BUILD_DIR}/" "${DIST_DIR}/"

  mv .wpignore .gitignore

  DEPLOY_DATE=`date`

  git add --all .
  git commit -m "Deployment on ${DEPLOY_DATE} [skip ci]"
  git push -u origin "deploy/${ENVIRONMENT}"

  # CLEANUP
  # =======

  echo -e "${YELLOW}Cleaning up...${RESET}"

  rm -rf "$BUILD_DIR"
  rm -rf "$DIST_DIR"

  echo -e "${GREEN}All done.${RESET}"
)
