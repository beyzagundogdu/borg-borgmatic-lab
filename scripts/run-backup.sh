#!/bin/bash

# Backup script for Borgmatic

echo "Backup started..."

sudo borgmatic --verbosity 1

if [ $? -eq 0 ]; then
  echo "Backup completed successfully"
else
  echo "Backup failed"
fi