#!/bin/bash

# Intended to deploy a Composer controlled repo to WP Engine.
#
# Usage: ./deploy-wpengine.sh -m <commit message> -s <site> [--live]

# TODO: Handle Git submodules

(
    # URESETomment these lines to profile the script
    # set -x
    # PS4='$(date "+%s.%N ($LINENO) + ")'

    WHOAMI=`whoami`

    ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)
    CLONE_DIR="$ROOT_DIR/.deploy_clone"
    DEPLOY_DIR="$ROOT_DIR/.deploy_wpengine"

    DEPLOY_ENV="staging"

    RED='\e[0;31m'
    GREEN='\e[0;32m'
    YELLOW='\e[0;33m'
    RESET='\e[0m' # No Color

    # SETUP AND SANITY CHECKS
    # =======================
    while getopts m:s:l OPTION 2>/dev/null; do
        case $OPTION
        in
            m) COMMIT_MSG=${OPTARG};;
            s) SITENAME=${OPTARG};;
            l) DEPLOY_ENV="production";;
        esac
    done

    echo -e "${YELLOW}Cleaning up...${RESET}"

    rm -rf "$CLONE_DIR"
    rm -rf "$DEPLOY_DIR"

    # VALIDATIONS

    echo -e "Checking you have a Git user setup..."
    if [[ $(git config --list) != *user.email* || $(git config --list) != *user.name* ]]; then
        git config --global user.name "log.OSCON"
        git config --global user.email "engenharia@log.pt"
    fi

    if [ -z "$COMMIT_MSG" ]; then
        echo -e "${RED}Please provide a commit message, e.g. 'sh .deploy-wpengine.sh -m \"Phase 2 beta\"'${RESET}"
        exit 1
    fi

    if [ -z "$SITENAME" ]; then
        echo -e "${RED}Please provide a site name within WP Engine, this will control the Git repo we clone and commit to, e.g. 'sh .deploy-wpengine.sh -s \"sitename\"'${RESET}"
        exit 2
    fi

    echo -e "${YELLOW}Testing authentication with $SITENAME on WPEngine...${RESET}"
    # The quickest command I can find is `help`, but it still takes approx 2 seconds
    # (The command is executed on Gitolite at the WPEngine end, AFAICT)
    ssh -o "BatchMode yes" git@git.wpengine.com help 2>/dev/null 1>&2
    if [ 0 != $? ]; then
        echo -e "${RED}You need to add some SSH keys to allow the '$WHOAMI' user to deploy to $SITENAME on WPEngine${RESET}"
        exit 3
    fi

    # DEPLOY THE PROJECT
    # ==================

    echo -e "${YELLOW}Cloning the project for deployment...${RESET}"

    # Get around Codeship's shallow clones:
    git pull --unshallow

    git clone --recursive "$ROOT_DIR" "$CLONE_DIR"

    if [ 0 != $? ]; then
        echo -e "${RED}There was an error cloning the repository.${RESET}"
        exit 4
    fi

    cd "$CLONE_DIR"

    echo -e "${YELLOW}Fetching and merging source files...${RESET}"

    git clone "git@git.wpengine.com:${DEPLOY_ENV}/${SITENAME}.git" "$DEPLOY_DIR"

    if [ 0 != $? ]; then
        echo -e "${RED}There was an error fetching the repository.${RESET}"
        exit 5
    fi

    rsync -av --delete --exclude-from "${CLONE_DIR}/.wpignore" --exclude ".git/" "${CLONE_DIR}/" "${DEPLOY_DIR}/"

    cp "$DEPLOY_DIR/.wpignore" "$DEPLOY_DIR/.gitignore"

    echo -e "${YELLOW}Building the project for deployment...${RESET}"

    cd "$DEPLOY_DIR"

    bash build.sh -l

    if [ 0 != $? ]; then
        echo -e "${RED}There was an error building the project.${RESET}"
        exit 6
    fi

    find vendor/ -type d -name ".git" -exec rm -rf {} \;
    find wp-content/ -type d -name ".git" -exec rm -rf {} \;

    echo -e "${YELLOW}Creating a Git commit for the changes...${RESET}"

    git add -A . # Add all the things! Even the deleted things!
    git commit -am "$COMMIT_MSG"

    echo -e "${YELLOW}Deploying the build...${RESET}"

    git push origin HEAD:master

    if [ 0 != $? ]; then
        echo -e "${RED}There was an error deploying the project.${RESET}"
        exit 6
    fi

    # CLEANUP
    # =======

    echo -e "${YELLOW}Cleaning up...${RESET}"

    rm -rf "$CLONE_DIR"
    rm -rf "$DEPLOY_DIR"

    echo -e "${GREEN}All done.${RESET}"
)
