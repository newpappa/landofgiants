#!/bin/bash

# Function to safely remove a directory if it exists and is empty
safe_remove_dir() {
    local dir=$1
    if [ -d "$dir" ]; then
        if [ -z "$(ls -A $dir)" ]; then
            echo "Removing empty directory: $dir"
            rm -r "$dir"
        else
            echo "Warning: Directory not empty, skipping: $dir"
            echo "Contents:"
            ls -la "$dir"
        fi
    fi
}

# Wait for user confirmation
echo "This script will remove old directories after reorganization."
echo "Make sure you have:"
echo "1. Run reorg.sh successfully"
echo "2. Tested in Studio and everything works"
echo "3. Verified all files are in their new locations"
echo ""
read -p "Continue with cleanup? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

# Remove old directories
echo "Starting cleanup..."

# Server directories
safe_remove_dir "src/ServerScriptService"

# Client directories
safe_remove_dir "src/StarterPlayer/StarterPlayerScripts"
safe_remove_dir "src/StarterPlayer"

# Shared directories
safe_remove_dir "src/ReplicatedStorage"

echo "Cleanup complete!"
echo "Please verify in Studio that everything still works." 