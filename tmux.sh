#!/bin/bash

# This script will create a tmux session with multiple windows and panes.
# You have 4 options related to pane layout:
# 1. Single pane window
# 2. Vertical split window with two full height pane, one left and one right
# 3. Vertical split window with one full height pane on left, and two pane on right side split evenly (top and bottom)
# 4. Vertical split window with two pane on left side split evenly, and two pane on right side split evenly
#
# Additionally you can execute specific command on each pane.
#
# You can also define default project which will be selected when you attach to tmux session. This is useful when you have multiple projects and you want to have one project selected by default.
# There is also a debug mode which will print all commands which are executed just in case you want to see what is going on.

# For MacOS users
# If you get error reported for 'declare -A' command, you will need to use Homebrew to install latest version of bash: `brew install bash`
# After installation of bash check if you have latest version with: `bash --version`, latest one is 5.2.15
# Use: `which bash` to get the location of the newly installed bash, for me that is '/opt/homebrew/bin/bash'
# After you got the bash location, update first line to `#!{bash_location}, it should look something like: `#!/opt/homebrew/bin/bash`

enable_debug="true"

# Define session name
session_name=develop

# Define default project name which will be selected by default.
default_project=MyDefaultProject

# This should be used for a project which have single window opened.
declare -A single_pane
single_pane["window_name"]="MyDefaultProject"
single_pane["path"]="~/projects/defaultProject"
single_pane["command"]="ls -a"

# This should be used for a project which has window split in two pane vertically.
declare -A side_project_2_split
side_project_2_split["window_name"]="SideProject"
side_project_2_split["left_pane_path"]="~/projects/sideProjects/project1"
side_project_2_split["right_pane_path"]="~/projects/sideProjects/project1/gitSubmodule"
side_project_2_split["left_pane_path_command"]="git branch"
side_project_2_split["right_pane_path_command"]="git fetch"

# This should be used for a project which has window split in three pane one on left side taking full height, and two on right side split evenly.
declare -A main_project_3_split
main_project_3_split["window_name"]="MainProject"
main_project_3_split["left_pane_path"]="~/projects/mainProject"
main_project_3_split["top_right_pane_path"]="~/projects/mainProject/gitSubmodule1"
main_project_3_split["bottom_right_pane_path"]="~/projects/manProject/gitSubmodule2"
main_project_3_split["left_pane_path_command"]="git status"
main_project_3_split["top_right_pane_path_command"]="git branch"
main_project_3_split["bottom_right_pane_path_command"]="git fetch"

# This should be used for a project which has window split in 4 pane two on left side and two on right side, split evenly.
declare -A kmm_4_split
kmm_4_split["window_name"]="KMM"
kmm_4_split["top_left_pane_path"]="~/projects/kmm"
kmm_4_split["bottom_left_pane_path"]="~/projects/kmm/shared"
kmm_4_split["top_right_pane_path"]="~/projects/kmm/android"
kmm_4_split["bottom_right_pane_path"]="~/projects/kmm/iOS"
kmm_4_split["top_left_pane_path_command"]="git fetch"
kmm_4_split["bottom_left_pane_path_command"]="ls -l"
kmm_4_split["top_right_pane_path_command"]="git status"
kmm_4_split["bottom_right_pane_path_command"]="git branch"

echoInfo() {
	if [[ "$enable_debug" = true ]]; then
    	echo -e "\x1B[01;37m$1\x1B[0m"
  	fi
}

echoTitle() {
	if [[ "$enable_debug" = true ]]; then
    	echo -e "\x1B[01;92m$1\x1B[0m"
  	fi
}

echoCommand() {
	if [[ "$enable_debug" = true ]]; then
    	echo -e "\x1B[01;34m$1\x1B[0m"
  	fi
}

echoCommandNotDefined() {
	if [[ "$enable_debug" = true ]]; then
    	echo -e "\x1B[01;94m$1\x1B[0m"
  	fi
}

# Function will create a single pane
createSinglePaneWindow() {
	local -n p=$1
	echoTitle "Creating a single pane window named: '${p[window_name]}'."
	tmux new-window -n ${p[window_name]} -t $session_name
	echoInfo "${p[window_name]} cd into '${p[path]}' on main pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[path]} && clear" C-m
	if [[ -n "${p[command]}" ]]; then
		echoCommand "${p[window_name]} Running command '${p[command]}' on main pane."
		tmux send-keys -t ${p[window_name]} "${p[command]}" C-m
	else
		echoCommandNotDefined "${p[window_name]} No command to run on main pane."
	fi
}

# Function will create a vertical split window with two full height pane on left and right
create2SplitWindow() {
	local -n p=$1
	echoTitle "Creating a 2 pane window named: '${p[window_name]}'."
	tmux new-window -n ${p[window_name]} -t $session_name
	echoInfo "${p[window_name]} cd into '${p[left_pane_path]}' on left pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[left_pane_path]} && clear" C-m
	echoInfo "${p[window_name]} Splitting window vertically"
	tmux split-window -h -t ${p[window_name]}
	echoInfo "${p[window_name]} cd into '${p[right_pane_path]}' on right pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[right_pane_path]} && clear" C-m
	if [[ -n "${p[left_pane_path_command]}" ]]; then
		tmux select-pane -t 0
		echoCommand "${p[window_name]} Running command '${p[left_pane_path_command]}' on left pane."
		tmux send-keys -t ${p[window_name]} "${p[left_pane_path_command]}" C-m
	else
		echoCommandNotDefined "${p[window_name]} No command to run on left pane."
	fi
	if [[ -n "${p[right_pane_path_command]}" ]]; then
		tmux select-pane -t 1
		echoCommand "${p[window_name]} Running command '${p[right_pane_path_command]}' on right pane."
		tmux send-keys -t ${p[window_name]} "${p[right_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on right pane."
	fi
	echoInfo "${p[window_name]} Selecting pane 0"
	tmux select-pane -t 0
}

# Function will create a 3 split window one full height pane on the left and two half height pane on the right
create3SplitWindow() {
	local -n p=$1
	echoTitle "Creating a 3 pane window named: '${p[window_name]}'."
	tmux new-window -n ${p[window_name]} -t $session_name
	echoInfo "${p[window_name]} cd into '${p[left_pane_path]}' on left pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[left_pane_path]} && clear" C-m
	echoInfo "${p[window_name]} Splitting window vertically"
	tmux split-window -h -t ${p[window_name]}
	echoInfo "${p[window_name]} cd into '${p[top_right_pane_path]}' on top right pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[top_right_pane_path]} && clear" C-m
	echoInfo "${p[window_name]} Splitting window horizontally"
	tmux split-window -v -t ${p[window_name]}
	echoInfo "${p[window_name]} cd into '${p[bottom_right_pane_path]}' on bottom right pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[bottom_right_pane_path]} && clear" C-m
	if [[ -n "${p[left_pane_path_command]}" ]]; then
		tmux select-pane -t 0
		echoCommand "${p[window_name]} Running command '${p[left_pane_path_command]}' on left pane."
		tmux send-keys -t ${p[window_name]} "${p[left_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on left pane."
	fi
	if [[ -n "${p[top_right_pane_path_command]}" ]]; then
		tmux select-pane -t 1
		echoCommand "${p[window_name]} Running command '${p[top_right_pane_path_command]}' on top right pane."
		tmux send-keys -t ${p[window_name]} "${p[top_right_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on top right pane."
	fi
	if [[ -n "${p[bottom_right_pane_path_command]}" ]]; then
		tmux select-pane -t 2
		echoCommand "${p[window_name]} Running command '${p[bottom_right_pane_path_command]}' on bottom right pane."
		tmux send-keys -t ${p[window_name]} "${p[bottom_right_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on bottom right pane."
	fi
	echoInfo "${p[window_name]} Selecting pane 0"
	tmux select-pane -t 0
}

# Function will create a 4 split window split horizontally and vertically
create4SplitWindow() {
	local -n p=$1
	echoTitle "Creating a 4 pane window named: '${p[window_name]}'."
	tmux new-window -n ${p[window_name]} -t $session_name
	echoInfo "${p[window_name]} cd into '${p[top_left_pane_path]}' on top left pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[top_left_pane_path]} && clear" C-m
	echoInfo "${p[window_name]} Splitting window vertically"
	tmux split-window -h -t ${p[window_name]}
	echoInfo "${p[window_name]} cd into '${p[top_right_pane_path]}' on top right pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[top_right_pane_path]} && clear" C-m
	echoInfo "${p[window_name]} Splitting window horizontally"
	tmux split-window -v -t ${p[window_name]}
	echoInfo "${p[window_name]} cd into '${p[bottom_right_pane_path]}' on bottom right pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[bottom_right_pane_path]} && clear" C-m
	echoInfo "${p[window_name]} Selecting pane 0"
	tmux select-pane -t 0
	echoInfo "${p[window_name]} Splitting window horizontally"
	tmux split-window -v -t ${p[window_name]}
	echoInfo "${p[window_name]} cd into '${p[bottom_left_pane_path]}' on bottom left pane."
	tmux send-keys -t ${p[window_name]} "cd ${p[bottom_left_pane_path]} && clear" C-m
	if [[ -n "${p[top_left_pane_path_command]}" ]]; then
		tmux select-pane -t 0
		echoCommand "${p[window_name]} Running command '${p[top_left_pane_path_command]}' on top left pane."
		tmux send-keys -t ${p[window_name]} "${p[top_left_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on top left pane."
	fi
	if [[ -n "${p[top_right_pane_path_command]}" ]]; then
		tmux select-pane -t 2
		echoCommand "${p[window_name]} Running command '${p[top_right_pane_path_command]}' on top right pane."
		tmux send-keys -t ${p[window_name]} "${p[top_right_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on top right pane."
	fi
	if [[ -n "${p[bottom_right_pane_path_command]}" ]]; then
		tmux select-pane -t 3
		echoCommand "${p[window_name]} Running command '${p[bottom_right_pane_path_command]}' on bottom right pane."
		tmux send-keys -t ${p[window_name]} "${p[bottom_right_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on bottom right pane."
	fi
	if [[ -n "${p[bottom_left_pane_path_command]}" ]]; then
		tmux select-pane -t 1
		echoCommand "${p[window_name]} Running command '${p[bottom_left_pane_path_command]}' on bottom left pane."
		tmux send-keys -t ${p[window_name]} "${p[bottom_left_pane_path_command]}" C-m
	else 
		echoCommandNotDefined "${p[window_name]} No command to run on bottom left pane."
	fi
	echoInfo "${p[window_name]} Selecting pane 0"
	tmux select-pane -t 0
}

tmux has-session -t $sesion_name

if tmux has-session -t $session_name 2>/dev/null; then
  	# If the session is already running, attach to it
  	echoInfo "Session $session_name already exists, attaching to session $session_name."
  	tmux attach -t $session_name
else
  	# If the session is not running, create it and attach to it
  	echoInfo "Session $session_name does not exist, creating the session $session_name."
  	tmux new-session -s $session_name -d
	
	createSinglePaneWindow single_pane
	create2SplitWindow side_project_2_split
	create3SplitWindow main_project_3_split
	create4SplitWindow kmm_4_split

	# We need to kill default window created which is empty and not needed
	tmux kill-window -t 0
fi


if [[ -z "$default_project" ]]; then
	echoTitle "No default project defined. Not switching to any project."
else
	echoTitle "Switching to default defined project $default_project"
	tmux select-window -t $default_project
fi

echoTitle "Attaching to session $session_name"
tmux attach -t $session_name
