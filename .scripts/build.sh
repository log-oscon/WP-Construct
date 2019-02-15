#!/bin/bash

set -e

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)
THEMES="${ROOT}/wp-content/themes/*/"
LIVE=0
OPT_COMPOSER=""

RED='\033[1;31m'
GREEN='\033[1;32m'
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
    while true; do
      read -p "Would you like to clone or install as submodule (c/s)? " yn
      case $yn in
          [Cc]* )
            mkdir $TARGETDIR
            git clone $REPOSITORY $TARGETDIR
            sleep 3
            break;;
          [Ss]* )
            printf "#Excluding submodule '%s'\n%s" "$NAME" "!$TARGETSUB$NAME" >> .gitignore
            git submodule add $REPOSITORY ".${TARGETSUB}${NAME}"
            sleep 3
            break;;
          * ) echo "Please answer c or s.";;
      esac
    done
  else
    echo "${RED}Trying to fetch an invalid git url. exiting...${NC}"
    exit
  fi
}

fetch_theme(){
  while true; do
    read -p "Would you like to install a THEME? " yn
    case $yn in
      [Yy]* )
        shopt -s nullglob
        WPTHEMES=('git repository URL');
        WPTHEMES+=($(ls -d $THEMES | xargs -n1 basename))
        echo "Please select the theme to install:"
        select opt in "${WPTHEMES[@]}"
        do
          if [[ $opt = 'git repository URL' ]]; then
            read -p "Theme git repository URL: " REPOSITORY
            THEMENAME=$(basename "$REPOSITORY")
            THEMENAME="${THEMENAME%.*}" #removing extension
            fetch_git $REPOSITORY $THEMENAME '/wp-content/themes/'
            build_theme $THEMENAME
          else
            build_theme $opt
          fi
        done;;
      [Nn]* ) break;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

build_theme(){
  THEMENAME=$1
  while true; do
    read -p "Would you like to build '${THEMENAME}' (y/n)? " yn
    case $yn in
      [Yy]* )
        THEMEDIR="$ROOT/wp-content/themes/$THEMENAME"
        echo  "${GREEN}Building $1 theme…${NC}"
        cd "${THEMEDIR}"
        composer install --no-interaction $OPT_COMPOSER
        npm install
        npm run build --if-present
        cd "${ROOT}"
        continue 3;;
      [Nn]* ) continue 3;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

fetch_plugins(){
  while true; do
    read -p "Would you like to install a PLUGIN (y/n)? " yn
    case $yn in
      [Yy]* )
        read -p "Plugin git repository URL: " REPOSITORY
        PLUGINNAME=$(basename "$REPOSITORY")
        PLUGINNAME="${PLUGINNAME%.*}" #removing extension
        fetch_git $REPOSITORY $PLUGINNAME '/wp-content/plugins/'
        while true; do
          read -p "Would you like to build '${PLUGINNAME}'? " yn
          case $yn in
            [Yy]* )
              cd "${TARGETDIR}"
              composer install --no-interaction $OPT_COMPOSER
              npm install
              npm run build --if-present
              cd "${ROOT}"
              break;;
            [Nn]* ) break;;
            * ) echo "Please answer y or n.";;
          esac
        done;;
      [Nn]* ) break;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

clean_git(){
  while true; do
    read -p "Would you like to clean the root .git folder (y/n)? " yn
    case $yn in
      [Yy]* )
        cd $ROOT
        rm -rf .git
       break;;
      [Nn]* ) break;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

# =======================
if [ $LIVE -eq 0 ]; then

  # SELECT THEME TO BUILD
  # =======================
  fetch_theme

  # SELECT PLUGINS TO BUILD
  # =======================
  fetch_plugins

  # CLEAN GIT INFO
  # =======================
  clean_git
fi

# BASE COMPOSER + NPM
# =======================
echo  "${GREEN}Installing Composer dependencies…${NC}"
composer install --no-interaction $OPT_COMPOSER

echo  "${GREEN}Installing NPM dependencies…${NC}"
npm install

# CUSTOM BUILDS HERE
# =======================

# =======================
echo  "${GREEN}Build finished.${NC}"
exit
