#! /bin/bash

<< readme
This is a script for backup with 5-day rotation

Usage:
./backup_and_rotation.sh <path to your source> <path to backup folder>
readme

function display_usage {
    echo "Usage: ./backup_and_rotation.sh <path to your source> <path to backup folder>"
}

if [ $# -eq 0 ]; then
    display_usage
    exit 1
fi

source_dir=$1
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
backup_dir=$2

function create_backup() {
    zip -r "${backup_dir}/backup_${timestamp}.zip" "${source_dir}" > /dev/null

    if [ $? -eq 0 ]; then
        echo "Backup generated successfully for ${timestamp}"
    else
        echo "Backup failed!" >&2
    fi
}

function perform_rotation() {
    # Using glob instead of `ls` to avoid errors if no backups exist
    backups=("${backup_dir}"/backup_*.zip)
    backups=($(ls -t "${backups[@]}" 2>/dev/null))  # Sort backups by timestamp
    
    echo "Existing backups: ${backups[@]}"

    if [ "${#backups[@]}" -gt 5 ]; then
        echo "Performing rotation for 5 days"

        backups_to_remove=("${backups[@]:5}")  # Keep latest 5 backups
        echo "Removing backups: ${backups_to_remove[@]}"

        for backup in "${backups_to_remove[@]}"; do
            rm -f "${backup}"
        done
    fi
}

create_backup
perform_rotation
