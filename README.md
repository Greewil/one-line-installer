# one-line-installer-generator
[![release](https://badgen.net/github/release/Greewil/one-line-installer/stable)](https://github.com/Greewil/one-line-installer/releases)
[![Last updated](https://img.shields.io/github/release-date/Greewil/one-line-installer?label=updated)](https://github.com/Greewil/one-line-installer/releases)
[![issues](https://badgen.net/github/issues/Greewil/one-line-installer)](https://github.com/Greewil/one-line-installer/issues)

Actions: [create fork](https://github.com/Greewil/one-line-installer/fork), [watch repo](https://github.com/Greewil/one-line-installer/subscription), [create issue](https://github.com/Greewil/one-line-installer/issues/new)

## Overview

This project helps you to generate one line installer for your project. 
Generated installer could install your project after just pasting and executing in user's command line!

Such installation could be useful for tools and commands projects without complex pipelines.
Especially it will be useful for git projects written on interpreted languages.

F.e. with this tool you can generate one line installers which will install your latest release from github. 
You can test how it works by [installing this project](#Installation). 

To generate installation command you should specify:
1. link to your project last version
2. unpacking command like 'unzip one-line-installer-main.zip'
3. installation command

You also can specify:
1. pre-downloading command
2. custom downloading command

### How it works

Generated installer will download your package to temporary directory and unpack it there. 
After that it will execute your installation command. 
If your unpack command don't change directory than installation will be started from temporary directory 
where your package was downloaded! 
And after all specified procedures installer will clear all temporary files.

### About generator input parameters

This project has CLI and you can specify your parameters there, 
but sometimes it's easier to store configuration parameters in files.

Examples of configuration files: [config_examples]

If you are using github/gitlab it's easier to install either from head of some branch or from latest release tag. 
See more about configuring latest release installer in [latest release installer example].
If you want to install from head of your git repo branch you can download zip archive of your project current version. 
Ofcourse you can yse just 'git clone <YOUR_REPO_LINK>' if you need it 
but downloading just archive with main head will be faster. 

If you want f.e. zip archive of branch head for github project you can use links like:

    https://github.com/<GITHUB_USER_NAME>/<PROJECT_NAME>/archive/refs/heads/<MAIN_BRANCH_NAME>.zip

If you want f.e. zip archive of branch head for gitlab project you can use links like:

    https://gitlab.com/<GITHUB_USER_NAME>/<PROJECT_NAME>/-/archive/<MAIN_BRANCH_NAME>/<PROJECT_NAME>.zip

See more about configuring installation from branch in [branch installer example].

If you don't need to unpack anything you can skip unpacking command.

It will be cleaner if you will use installer file stored in your repo. 
If so you can just start it due the installation (f.e. './<YOUR_UNPACKED_PROJECT_FOLDER>/installer.sh').

## Requirements

- bash interpreter

## Installation

installation:

    bash -c "tmp_dir=/tmp/installation-\$(date +%s%N); start_dir=\$(pwd); trap 'printf \"%b\" \"\n\e[0;31mInstallation failed\e[0m\n\n\"; cd \$start_dir; rm -r \$tmp_dir;' ERR; set -e; mkdir -p \$tmp_dir; cd \$tmp_dir; latest_release=\$(curl https://api.github.com/repos/Greewil/one-line-installer/releases/latest | grep zipball | cut -d\\\" -f 4); printf '%b' '\ndownloading project packages ...\n\n'; curl \$latest_release -O -J -L; printf '%b' '\nunpacking ...\n\n'; unzip \$(ls | grep .zip); printf '%b' '\ninstalling project ...\n\n'; \$(ls -d ./*/)installer.sh; cd \$start_dir; rm -r \$tmp_dir; printf '%b' '\nThis installation command was generated with \e[1;34mhttps://github.com/Greewil/one-line-installer\e[0m\n\n'"

## Usage

To generate your own one line installer just follow the instructions after starting generator script:

    generate_one_line_installer

Also, you can save your installation properties to configuration according to one of the examples from [config_examples].
If you want to generate installer based on your configuration files use:

    generate_one_line_installer <PATH_TO_YOUR_CONFIG>

## License

one-line-installer is licensed under the terms of the MIT License. See [LICENSE] file.

## Contact

* Web: <https://github.com/Greewil/one-line-installer>
* Mail: <shishkin.sergey.d@gmail.com>

[LICENSE]: https://github.com/Greewil/one-line-installer/blob/master/LICENSE
[config_examples]: https://github.com/Greewil/one-line-installer/blob/generate_from_configs/config_examples
[latest release installer example]: https://github.com/Greewil/one-line-installer/blob/generate_from_configs/config_examples/one-line-installer-latest-release.conf
[branch installer example]: https://github.com/Greewil/one-line-installer/blob/generate_from_configs/config_examples/one-line-installer-from-branch.conf
