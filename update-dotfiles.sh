#!/bin/bash

exclude_list="README.MD update-dotfiles.sh backup"

echo "Exclude the following files: $exclude_list"

dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "dotfiles directory $dotfiles_dir"

old_dotfiles_backupdir=$dotfiles_dir/backup

# Initialisation

mkdir -p $old_dotfiles_backupdir

setup_dotfile(){
	local new_dot_file=$1
	local old_dot_file=$2

	local setup_script=$old_dot_file/setup.sh

	echo "Creating symlink from $old_dot_file->$new_dot_file"
	ln -s $new_dot_file $old_dot_file
	if [[ -f $setup_script ]]; then
		chmod u+x $setup_script
        echo "Executing setup script $setup_script"
		$setup_script
	fi
}

# Setup symlinks

files=$(ls $dotfiles_dir)

filtered_files=$(comm -23 <(printf "%s\n" $files) <(printf "%s\n" $exclude_list | sort))

echo "Filtered files: $filtered_files"

for dotfile in $filtered_files; do
	old_dot_file=$HOME/.$dotfile
	new_dot_file=$dotfiles_dir/$dotfile
	echo "Processing $old_dot_file"
	if [[ -f $old_dot_file ]] || [[ -d $old_dot_file ]] && [[ ! -L $old_dot_file ]]; then
		echo "Old dotfile: $old_dot_file"
		echo "New dotfile: $new_dot_file"
		read -p "Move old dotfile $old_dot_file to backup directory in $old_dotfiles_backupdir and replace with symlink (Y/n):" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Y]$ ]]; then
			backup_dotfile=$old_dotfiles_backupdir/$dotfile
			echo "file $old_dot_file"
			mv $old_dot_file $backup_dotfile
			setup_dotfile $new_dot_file $old_dot_file
		else
			echo "Not replacing $old_dot_file"
		fi
	else
		setup_dotfile $new_dot_file $old_dot_file
	fi
done

