#!/bin/bash

# Intended to deploy a Composer controlled repo to Kinsta.
#
# Usage: ./deploy-kinsta.sh -s sitename -l

# TODO: Handle Git submodules

(
  # Uncomment these lines to profile the script
  # set -x
  # PS4='$(date "+%s.%N ($LINENO) + ")'

  WHOAMI=`whoami`

  ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)
  BUILD_DIR="$ROOT_DIR/.deploy_build"
  DIST_DIR="$ROOT_DIR/.deploy_kinsta"

  DEPLOY_REPO=`git config --get remote.origin.url`

  DEPLOY_ENV="staging"
  DEPLOY_PATH="staging"

  RED='\e[0;31m'
  GREEN='\e[0;32m'
  YELLOW='\e[0;33m'
  RESET='\e[0m' # No Color

  # SETUP AND SANITY CHECKS
  # =======================
  while getopts s:l OPTION 2>/dev/null; do
    case $OPTION
    in
      s) SITENAME=${OPTARG};;
      l) DEPLOY_ENV="production";;
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

  if [ -z "$SITENAME" ]; then
    echo -e "${RED}Please provide a site name within Kinsta, this will control the Git repo we clone and commit to, e.g. 'sh .deploy-kinsta.sh -s \"sitename\"'${RESET}"
    exit 2
  fi

  if [[ "$DEPLOY_ENV" = "production" ]]; then
    DEPLOY_PATH="public"
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

  bash $ROOT_DIR/build.sh -l

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
  git checkout "deploy/${DEPLOY_ENV}"
  if [ 0 != $? ]; then
    # Create a new orphan branch to track deployments
    git checkout --orphan "deploy/${DEPLOY_ENV}"

    # Everything is being tracked, so remove it
    git rm --cached -r ./
  fi

  rsync -a --delete --exclude-from=.wpignore --exclude=.git --exclude=.gitignore "${BUILD_DIR}/" "${DIST_DIR}/"

  cp .wpignore .gitignore

  DEPLOY_DATE=`date`

  git add --all .
  git commit -m "Deployment on ${DEPLOY_DATE} [skip ci]"
  git push -u origin "deploy/${DEPLOY_ENV}"

  echo -e "${YELLOW}Deploying the build with Dandelion...${RESET}"

  gem install dandelion net-sftp

  cat > dandelion.yml <<- EOM
adapter: sftp
host: ${SITENAME}.kinsta.com
port: 22
username: ${SITENAME}
path: ${DEPLOY_PATH}
local_path: .
EOM

  dandelion deploy

  if [ 0 != $? ]; then
    echo -e "${RED}There was an error deploying the project.${RESET}"
    exit 6
  fi

  # CLEANUP
  # =======

  echo -e "${YELLOW}Cleaning up...${RESET}"

  rm -rf "$BUILD_DIR"
  rm -rf "$DIST_DIR"

  echo -e "${GREEN}All done.${RESET}"
)
