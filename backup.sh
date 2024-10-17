#!/bin/bash

backup_dir="/path/to/backup"

mkdir -p $backup_dir

for volume in $(docker volume ls -q); do
    echo "Backing up volume: $volume"
    docker run --rm -v ${volume}:/volume -v $backup_dir:/backup alpine tar -czf /backup/${volume}.tar.gz -C /volume .
done

echo "Backup completed!"