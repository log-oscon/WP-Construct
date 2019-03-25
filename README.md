# WP-Construct

We use this as the foundation for new WordPress projects at log.

## Introduction

This guide assumes some basic familiarity with the command line, the Git version control system and Docker or Vagrant.

We recommend using a OS X machine but a PC with Windows 10 **Pro or Enterprise 64 bit** Operating System should work just fine. Refer to [Windows troubleshooting ](#windows-troubleshooting) section for detailed information on system requirements and problem solving. 

There are many graphical tools allowing you to achieve the same results as the ones described here, but a step-by-step guide for those is outside the scope of this document.

## Dependencies 

Altough it is possible to run it with other versions, this guide assumes that `php 7.2`, `composer`,`node v8.12.0` and `gulp 3.9.0` are used.  


## Setting up development environment

Currently at log we use and recommend a *simple Docker based development environment for WordPress*, [WP-Docker-Construct](https://github.com/log-oscon/WP-Docker-Construct). 

Varying Vagrant Vagrants (VVV) configuration files are included in this project but as this is a legacy setup, its no longer tested. If you like to use it follow [WP-Construct VVV Setup](https://github.com/Varying-Vagrant-Vagrants/VVV/blob/develop/README.md#installation) instructions.


## Themes 

This setup bundles a genesis child theme. If you intend to use it, you must have Genesis main theme (the Genesis Framework) in order for the child-theme to work. You can get it at [http://my.studiopress.com/themes/genesis/](http://my.studiopress.com/themes/genesis/). 
It is also possible to install themes through composer or by running the build script. 


## Build themes and plugins

A build script is included to help you setup wordpress. 
You can find this script in `$ .scripts/build.sh`.

This script operates in two modes, local and live mode. 

### Local mode 

This mode allows you to install and build themes and plugins. 

```
$ sh .scripts/build.sh
Would you like to install a THEME? y
Please select the theme to install:
1) git repository URL
2) genesis-starter
#?
```

#### Git repository url 

If you choose option 1) *git repository URL* you're allowed to fetch a git remote theme as a submodule or clone and build it: 


```
#? 1
Theme git repository URL: git@bitbucket.org:devteam/dev-theme.git
Would you like to clone or install as submodule (c/s)? s
Cloning into '/Users/dev/WP-Construct/wp-content/themes/dev-theme'...
(...)
Would you like to build 'dev-theme' (y/n)? y
```


#### Genesis theme

If you choose *genesis-starter*, it is already on disk, so you get option of building the theme right away: 

```
#? 2
Would you like to build 'genesis-starter' (y/n)? y
```

#### Build commands 
The following commands are run in `/wordpress` and in each build selected:

* `$ composer update `;
* `$ npm install`;
* `$ npm run build --if-present`;


### Live mode 
*Live mode * is intended to be used in a continuous integration(CI) scenário. It automatically builds `/wordpress` configurations and includes a commented section to build all the installed submodules automatically. 

### Plugins 

Plugins instalation can be done directly via composer on the `/wordpress/composer.json` or installed via submodules via build script as a clone or submodule. 


## Continuous Integration 

A few scripts are bundled to automate continuous integration in different scenarios. For example, *deploy-codeship-wpengine.sh* allows to automate testing and publishing between a git repository and wp-engine. 
Check .scripts folder for available scripts. 


## Windows troubleshooting<a name="windows-troubleshooting">&nbsp;</a>

###Required windows version 

**Windows 10 Pro or Enterprise 64 bit** Operating System are the supported versions, Hyper-V is required. [Check this article](https://techcommunity.microsoft.com/t5/ITOps-Talk-Blog/Step-By-Step-Enabling-Hyper-V-for-use-on-Windows-10/ba-p/267945) if you need to enable Hyper-V. 

###Dependencies

* [Gitbash](https://gitforwindows.org/)
* [php 7.2](https://windows.php.net/download#php-7.2)
* [composer](https://getcomposer.org/download/)
* [node-v8.12.0](https://nodejs.org/es/blog/release/v8.12.0/)
* [python 2.7](https://www.python.org/downloads/release/python-2716/)


###MSBUILD : error MSB4132: The tools version "2.0" is unrecognized. Available tools versions are "4.0

If you face this error when building do as following: 

* open up a new *gitbash* **as administrator** and run:
`$ npm install --global --production windows-build-tools`
* then run 
`$ npm config set msvs_version 2017`; 
* close all instances of *gitbash*, reopen a *gitbash* (regular this time, non-administrator) return to the project directory and run build again. 




