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
  NAME=$2
  TARGETSUB=$3
  TARGETDIR="${ROOT}${TARGETSUB}${NAME}"
  if [ ! -z "${REPOSITORY}" ]; then
    read -p "Would you like to clone or install as submodule (c/s)? " yn
    case $yn in
        [Cc]* )
          mkdir $TARGETDIR
          git clone $REPOSITORY $TARGETDIR
          break;;
        [Ss]* )
          echo "#Excluding submodule '${NAME}'\n!$TARGETSUB${NAME}" >> .gitignore
          git submodule add $REPOSITORY ".${TARGETSUB}${NAME}"
          break;;
        * ) echo "Please answer c or s.";;
    esac
  else
    echo "${RED}Trying to fetch an invalid git url. exiting..."
    exit
  fi
}

fetch_theme(){
  while true; do
    read -p "Would you like to install a(nother) theme? " yn
    case $yn in
      [Yy]* )
        shopt -s nullglob
        WPTHEMES=('git repository URL');
        WPTHEMES+=($(ls -d $THEMES | xargs -n1 basename))
        echo "Please select the theme to install:"
        select opt in "${WPTHEMES[@]}"
        do
          if [[ $opt = 'git repository URL' ]]; then
            read -p "Theme repository URL: " REPOSITORY
            THEMENAME=$(basename "$REPOSITORY")
            THEMENAME="${THEMENAME%.*}" #removing extension
            fetch_git $REPOSITORY $THEMENAME '/wp-content/themes/'
            build_theme $THEMENAME
          else
            build_theme $opt
          fi
        done
        break;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

build_theme(){
  THEMENAME=$1
  read -p "Would you like to build '${PLUGINNAME}'? " yn
  case $yn in
    [Yy]* )
      THEMEDIR="$ROOT/wp-content/themes/$THEMENAME"
      echo  "${GREEN}Building $1 theme…${NC}"
      cd "${THEMEDIR}"
      composer install --no-interaction $OPT_COMPOSER
      npm install
      npm run build --if-present
      break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
  remove_other_themes $1;
}

remove_other_themes(){
  while true; do
    read -p "Would you like to remove the unused themes? " yn
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
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

fetch_plugins(){
  while true; do
    read -p "Would you like to install a(nother) plugin? " yn
    case $yn in
        [Yy]* )
          read -p "Plugin repository URL: " REPOSITORY
          PLUGINNAME=$(basename "$REPOSITORY")
          PLUGINNAME="${PLUGINNAME%.*}" #removing extension
          fetch_git $REPOSITORY $PLUGINNAME '/wp-content/plugins/'
          read -p "Would you like to build '${PLUGINNAME}'?" yn
          case $yn in
            [Yy]* )
              cd "${TARGETDIR}"
              composer install --no-interaction $OPT_COMPOSER
              npm install
              npm run build --if-present
              cd "${ROOT}"
              break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
          esac
          break;;
        [Nn]* ) break;;
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
fetch_theme

# SELECT PLUGINS TO BUILD
# =======================
fetch_plugins

echo  "${GREEN}Build finished.${NC}"
exit
