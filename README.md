# WP-Construct

We use this as the foundation for new WordPress projects using the Genesis Framework at log.

## Dependencies (Must Have Genesis)

This setup requires you to have Genesis main theme (the Genesis Framework) in order for the child-theme to work. You can get it here: http://my.studiopress.com/themes/genesis/

Note: Without this theme you can still take some things from the VVV configurations and Gulp setup in the child theme.

## Introduction

This guide assumes some basic familiarity with the command line, the Git version control system and Vagrant.

There are many graphical tools allowing you to achieve the same results as the ones described here, but a step-by-step guide for those is outside the scope of this document.

## Before you begin

This setup requires recent versions of both Vagrant and VirtualBox to be installed.

[Vagrant](http://www.vagrantup.com) is a "tool for building and distributing development environments". It works with [virtualization](http://en.wikipedia.org/wiki/X86_virtualization) software such as [VirtualBox](https://www.virtualbox.org/) to provide a virtual machine sandboxed from your local environment.

## Setting up Varying Vagrant Vagrants (VVV)

Having Varying Vagrant Vagrants allows you to automatically build a virtualized Ubuntu server on your computer containing everything needed to develop a WordPress site, theme or plugin.

Multiple projects can be developed at once in the same environment.

VVV's `config`, `database`, `log` and `www` directories are shared with the virtualized server.

These shared directories allow you to work, for example, in `vagrant-local/www/wordpress-default` in your local file system and have those changes immediately reflected in the virtualized server's file system and http://local.wordpress.dev/. Likewise, if you `vagrant ssh` and make modifications to the files in `/srv/www/`, you'll immediately see those changes in your local file system.

If this is your first time working with VVV, you should definitely [read and follow the step-by-step installation guide](https://github.com/Varying-Vagrant-Vagrants/VVV/blob/develop/README.md#installation).

## Adding the Project to Your VVV Environment

This project should be added to the `www` directory in your VVV setup.  If you've followed the guide to installing VVV, the directory may be reached by typing `cd vagrant-local/www` in the command line interface.

Now clone the project into the `www` folder:

```
$ git clone git@github.com:log-oscon/wp-genesis-boilerplate.git wp-genesis-boilerplate
```

This should create a new directory called `wp-genesis-boilerplate` containing all the project files.

We're not done yet: VVV needs to setup and incorporate the project into its configuration. That is achieved by running:

```
$ vagrant provision
```

Take a break while VVV updates itself and builds the project for you. When done, a new site will become available at http://genesis.wordpress.dev/ and you may get to work.
