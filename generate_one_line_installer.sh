#!/usr/bin/env bash

# Written by Shishkin Sergey <shishkin.sergey.d@gmail.com>

# Current version of version_manager.sh.
INSTALLER_GENERATOR_VERSION='0.1.0'

OFFICIAL_REPO='Greewil/one-line-installer'
OFFICIAL_REPO_FULL="https://github.com/$OFFICIAL_REPO"

# Output style: titles and colors
APP_NAME='installer-generator'
NEUTRAL_COLOR='\e[0m' # neutral color
RED='\e[1;31m'        # color for errors
YELLOW='\e[1;33m'     # color for warnings
BROWN='\e[0;33m'      # color for inputs
LIGHT_CYAN='\e[1;36m' # color for changes

# input variables (Please don't modify!)
PROJECT_NAME=''                   # f.e. project name
DOWNLOAD_REPO_URL=''              # f.e. https://github.com/Greewil/one-line-installer/archive/refs/heads/branch_installation.zip
UNPACK_COMMAND=''                 # f.e. unzip one-line-installer-branch_installation.zip
INSTALL_COMMAND=''                # f.e. cd one-line-installer-branch_installation; ls -la
SHOW_GENERATOR_LINK='true'        # f.e. true/false


function _show_error_message() {
  message=$1
  echo -en "$RED($APP_NAME : ERROR) $message$NEUTRAL_COLOR\n"
}

function _show_warning_message() {
  message=$1
  echo -en "$YELLOW($APP_NAME : WARNING) $message$NEUTRAL_COLOR\n"
}

function _show_updated_message() {
  message=$1
  echo -en "$LIGHT_CYAN($APP_NAME : CHANGED) $message$NEUTRAL_COLOR\n"
}

function _yes_no_question() {
  question_text=$1
  command_on_yes=$2
  command_on_no=$3
  asking_question='true'
  while [ "$asking_question" = 'true' ]; do
    read -p "$(echo -e "$BROWN($APP_NAME : INPUT) $question_text (Y/N): $NEUTRAL_COLOR")" -r answer
    case "$answer" in
    y|Y|Yes|yes)
      eval "$command_on_yes"
      asking_question='false'
      ;;
    n|N|No|no)
      eval "$command_on_no"
      asking_question='false'
      ;;
    esac
  done
}

function _get_input() {
  ask_input_message=$1
  output_variable_name=$2
  read -p "$(echo -e "$BROWN($APP_NAME : INPUT) $ask_input_message: $NEUTRAL_COLOR")" -r "$output_variable_name"
}

# Ask user to write input string and checks it.
# Asks input until check_function ($3) returns true.
#
# $1 - Message that asks an input from user
# $2 - Output variable name in which function should leave the result
# $3 - Function that returns 1 if input was incorrect and user should write it again.
# $4 - Message that will be shown if check_function ($3) will return 1
#
# Returns nothing.
function _get_input_with_check() {
  ask_input_message=$1
  output_variable=$2
  check_function=$3
  check_failed_message=$4
  waiting_for_input='true'
  while [ "$waiting_for_input" = 'true' ]; do
    _get_input "$ask_input_message" "$output_variable"
    waiting_for_input='false'
    eval "$check_function ${!output_variable}" || {
      waiting_for_input='true'
      _show_warning_message "'${!output_variable}': $check_failed_message"
    }
  done
}

function _get_message_command() {
  message_text=$1
  echo "printf '\n$message_text\n\n'"
}

function _get_download_src_command() {
  date_time='$(date +%s%N)'
  tmp_dir_var_command="tmp_dir=/tmp/installation-$date_time"
  start_dir_var_command="start_dir=\$(pwd)"
  mkdir_command="mkdir -p \$tmp_dir"
  go_tmp_dir_command="cd \$tmp_dir"
  download_command="curl $DOWNLOAD_REPO_URL -O -J -L"
  output_command="$(_get_message_command "downloading $PROJECT_NAME packages ..."); $tmp_dir_var_command"
  output_command="$output_command; $start_dir_var_command; $mkdir_command; $go_tmp_dir_command; $download_command;"
  echo "$output_command"
}

function _unpack_command() {
  if [ "$UNPACK_COMMAND" = '' ]; then
    output_command=''
  else
    output_command="$(_get_message_command "unpacking ..."); $UNPACK_COMMAND;"
  fi
  echo "$output_command"
}

function _get_install_command() {
  if [ "$INSTALL_COMMAND" = '' ]; then
    output_command=''
  else
    output_command="$(_get_message_command "installing $PROJECT_NAME ..."); $INSTALL_COMMAND;"
  fi
  echo "$output_command"
}

function _get_remove_src_command() {
  date_time='$(date +%s%N)'
  go_to_start_dir="cd \$start_dir"
  remove_tmp_dir_command="rm -r \$tmp_dir"
  output_command="$(_get_message_command "clearing tmp files ..."); $go_to_start_dir; $remove_tmp_dir_command;"
  echo "$output_command"
}

function get_final_command() {
  download_command="$(_get_download_src_command)"
  unpack_command="$(_unpack_command)"
  install_command="$(_get_install_command)"
  clean_command="$(_get_remove_src_command)"
  completed_message="$(_get_message_command "Installation successfully completed!");"
  if [ "$SHOW_GENERATOR_LINK" = 'true' ]; then
    advertisement_text="This installation command was generated with $OFFICIAL_REPO_FULL"
    advertisement_message="$(_get_message_command "$advertisement_text")"
  else
    advertisement_message=''
  fi
  output_command="$download_command $unpack_command $install_command $clean_command $completed_message"
  output_command="$output_command $advertisement_message"
  printf '\nYour command for your installation: \n\n'
  echo "$output_command"
  printf "\n"
  _show_warning_message "Make sure that after copying and pasting, there will be no line breaking characters in command!"
}

function _ask_project_name() {
  ask_project_name='Enter your project name'
  _get_input "$ask_project_name" "PROJECT_NAME"
  [ "$PROJECT_NAME" = '' ] && PROJECT_NAME='project'
}

function _check_link() {
  link=$1
  echo "checking your URL ..."
  [ "$link" = '' ] && return 1
  test_output=$(curl -s --head "$link" | head -n 1 | grep "HTTP/.* [23]..")
  if [ "$test_output" = '' ]; then
    return 1
  fi
  echo "URL exists and can be reached"
}

function _ask_package_link() {
  ask_package_link='Enter link for downloading your project' # TODO test if exists
  output_variable_name='DOWNLOAD_REPO_URL'
  check_function="_check_link"
  check_failed_message="URL doesn't exist or it's unreachable!"
  _get_input_with_check "$ask_package_link" "$output_variable_name" "$check_function" "$check_failed_message"
}

function _ask_unpack_command() {
  ask_unpack_command='Enter command which unpacks downloaded archive' # TODO test command works properly without errors
  _get_input "$ask_unpack_command" "UNPACK_COMMAND"
}

function _ask_installation_command() {
  ask_installation_command='Enter command which installs your project'
  _get_input "$ask_installation_command" "INSTALL_COMMAND"
}

function _ask_leave_generator_link() {
  echo "It would be great if other people will know about this project."
  ask_leave_generator_link='Do you want to show the link to this project after each installation?'
  _yes_no_question "$ask_leave_generator_link" 'SHOW_GENERATOR_LINK=true' 'SHOW_GENERATOR_LINK=false'
}

function ask_parameters() {
  _ask_project_name
  _ask_package_link
  _ask_unpack_command
  _ask_installation_command
  _ask_leave_generator_link
}


ask_parameters || exit 1

get_final_command || {
  _show_error_message "Failed to generate installation command! Something went wrong."
  exit 1
}
