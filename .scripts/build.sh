#!/bin/bash

set -e

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)
THEMES="${ROOT}/wp-content/themes/*/"
LIVE=0
OPT_COMPOSER=""

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# SETUP AND SANITY CHECKS
# =======================
while getopts l OPTION 2>/dev/null; do
    case $OPTION
        in
        l) LIVE=1;;
    esac
done

if [ $LIVE -eq 1 ]; then
    OPT_COMPOSER="--no-dev --optimize-autoloader"
fi

# FUNCTIONS DECLARATIONS
# =======================
fetch_git(){
  REPOSITORY=$1
  THEMENAME=$(basename "$REPOSITORY")
  THEMENAME="${THEMENAME%.*}" #removing extension
  TARGETDIR="${ROOT}/wp-content/themes/${THEMENAME}"

  mkdir $TARGETDIR

  if [ ! -z "${REPOSITORY}" ]; then
    echo "Local repository found. Downloading..."
    git clone $REPOSITORY $TARGETDIR
    build_theme $THEMENAME
  else
    echo "${RED}Trying to fetch an invalid git url. exiting..."
    exit
  fi
}

build_theme(){
  THEMEDIR="$ROOT/wp-content/themes/$1"
  echo  "${GREEN}Building $1 theme…${NC}"
  cd "${THEMEDIR}"
  composer install --no-interaction $OPT_COMPOSER
  npm install
  npm run build --if-present
  remove_other_themes $1;
}

remove_other_themes(){
  while true; do
    read -p "Would you like to remove the unused themes?" yn
    case $yn in
        [Yy]* )
          CURRENT=$1
          WPTHEMES=($THEMES)
          for THEME in "${WPTHEMES[@]}"; do
            if [ $(basename $THEME) != $CURRENT ]; then
              rm -rf $THEME
            fi
          done
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

# BASE COMPOSER + NPM
# =======================
echo  "${GREEN}Installing Composer dependencies…${NC}"
composer install --no-interaction $OPT_COMPOSER

echo  "${GREEN}Installing NPM dependencies…${NC}"
npm install

# SELECT THEME TO BUILD
# =======================
shopt -s nullglob
WPTHEMES=('git repository URL');
WPTHEMES+=($(ls -d $THEMES | xargs -n1 basename))

echo "\nPlease select the theme to install:\n"
select opt in "${WPTHEMES[@]}"
do
  if [[ $opt = 'git repository URL' ]]; then
    read -p "Write your theme repository URL: " REPOSITORY
    fetch_git $REPOSITORY
  else
    build_theme $opt
  fi
  break
done
echo  "${GREEN}Build finished.${NC}"
exit
