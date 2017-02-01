#!/bin/bash

# Intended to deploy a Composer controlled repo via rsync.
#
# Usage: ./deploy-rsync.sh -t <target>

(
  # URESETomment these lines to profile the script
  # set -x
  # PS4='$(date "+%s.%N ($LINENO) + ")'

  WHOAMI=`whoami`
  ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)

  RED='\e[0;31m'
  GREEN='\e[0;32m'
  YELLOW='\e[0;33m'
  RESET='\e[0m' # No Color

  # SETUP AND SANITY CHECKS
  # =======================
  while getopts t: OPTION 2>/dev/null; do
    case $OPTION
    in
      t) DEPLOY_TARGET=${OPTARG};;
    esac
  done

  # VALIDATIONS
  # ===========

  if [ -z "$DEPLOY_TARGET" ]; then
    echo -e "${RED}Please provide a deploy target, e.g. 'sh _deploy-rsync.sh -t \"deploy-target\"'${RESET}"
    exit 2
  fi

  # DEPLOY THE PROJECT
  # ==================

  echo -e "${YELLOW}Building the project for deployment...${RESET}"

  bash $ROOT_DIR/.scripts/build.sh -l

  if [ 0 != $? ]; then
    echo -e "${RED}There was an error building the project.${RESET}"
    exit 6
  fi

  rsync -av --delete --exclude-from "${ROOT_DIR}/.wpignore" --exclude ".git/" "${ROOT_DIR}/" "${DEPLOY_TARGET}"

  echo -e "${GREEN}All done.${RESET}"
)
