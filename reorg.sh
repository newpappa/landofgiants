#!/bin/bash

# Create new directory structure
mkdir -p src/Server/{Economy,NPC,Progression,Player,Orbs}
mkdir -p src/Client/{Economy,Notifications,HUD,Orbs}
mkdir -p src/Shared/{Core,Progression,UI,Orbs,Audio}

# Function to update require paths in a file
update_requires() {
    local file=$1
    echo "Updating require paths in $file"
    
    # Create a temporary file
    local temp_file="${file}.tmp"
    
    # Update paths for Shared modules
    sed -i '' \
        -e 's/require(ReplicatedStorage:WaitForChild("EventManager"))/require(ReplicatedStorage:WaitForChild("Core"):WaitForChild("EventManager"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("SizeStateMachine"))/require(ReplicatedStorage:WaitForChild("Core"):WaitForChild("SizeStateMachine"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))/require(ReplicatedStorage:WaitForChild("Progression"):WaitForChild("PlayerSizeCalculator"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("ButtonStyler"))/require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("ButtonStyler"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("OrbSpawner"))/require(ReplicatedStorage:WaitForChild("Orbs"):WaitForChild("OrbSpawner"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("OrbVisuals"))/require(ReplicatedStorage:WaitForChild("Orbs"):WaitForChild("OrbVisuals"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("OrbCounter"))/require(ReplicatedStorage:WaitForChild("Orbs"):WaitForChild("OrbCounter"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("OrbFTUCluster"))/require(ReplicatedStorage:WaitForChild("Orbs"):WaitForChild("OrbFTUCluster"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("OrbPositionManager"))/require(ReplicatedStorage:WaitForChild("Orbs"):WaitForChild("OrbPositionManager"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("RandomOrbPositions"))/require(ReplicatedStorage:WaitForChild("Orbs"):WaitForChild("RandomOrbPositions"))/g' \
        -e 's/require(ReplicatedStorage:WaitForChild("SoundRegistry"))/require(ReplicatedStorage:WaitForChild("Audio"):WaitForChild("SoundRegistry"))/g' \
        "$file" > "$temp_file"
    
    # Update paths for Server modules
    sed -i '' \
        -e 's/require(ServerScriptService:WaitForChild("XPManager"))/require(ServerScriptService:WaitForChild("Progression"):WaitForChild("XPManager"))/g' \
        -e 's/require(ServerScriptService:WaitForChild("OrbManager"))/require(ServerScriptService:WaitForChild("Orbs"):WaitForChild("OrbManager"))/g' \
        -e 's/require(ServerScriptService:WaitForChild("OrbPickupManager"))/require(ServerScriptService:WaitForChild("Orbs"):WaitForChild("OrbPickupManager"))/g' \
        -e 's/require(ServerScriptService:WaitForChild("SquashHandler"))/require(ServerScriptService:WaitForChild("Orbs"):WaitForChild("SquashHandler"))/g' \
        -e 's/require(ServerScriptService:WaitForChild("SquashTracker"))/require(ServerScriptService:WaitForChild("Orbs"):WaitForChild("SquashTracker"))/g' \
        "$temp_file"
    
    # Move temp file back
    mv "$temp_file" "$file"
}

# Function to copy a file and update its requires
copy_file() {
    local source=$1
    local dest=$2
    if [ -f "$source" ]; then
        echo "Copying $source to $dest"
        # Create directory if it doesn't exist
        mkdir -p "$(dirname "$dest")"
        # Copy file
        cp "$source" "$dest"
        # Update require paths in the copied file
        update_requires "$dest"
    else
        echo "Warning: Source file $source not found"
    fi
}

# Server files
copy_file "src/ServerScriptService/PurchaseProcessor.server.lua" "src/Server/Economy/PurchaseProcessor.server.lua"
copy_file "src/ServerScriptService/NPCGiantManager.server.lua" "src/Server/NPC/NPCGiantManager.server.lua"
copy_file "src/ServerScriptService/LeaderstatsUpdater.server.lua" "src/Server/Progression/LeaderstatsUpdater.server.lua"
copy_file "src/ServerScriptService/XPManager.lua" "src/Server/Progression/XPManager.lua"
copy_file "src/ServerScriptService/PlayerSpawnHandler.server.lua" "src/Server/Player/PlayerSpawnHandler.server.lua"
copy_file "src/ServerScriptService/GrowthHandler.server.lua" "src/Server/Player/GrowthHandler.server.lua"
copy_file "src/ServerScriptService/GiantTransformationHandler.server.lua" "src/Server/Player/GiantTransformationHandler.server.lua"
copy_file "src/ServerScriptService/SpeedTransformationHandler.server.lua" "src/Server/Player/SpeedTransformationHandler.server.lua"
copy_file "src/ServerScriptService/OrbManager.server.lua" "src/Server/Orbs/OrbManager.server.lua"
copy_file "src/ServerScriptService/OrbPickupManager.server.lua" "src/Server/Orbs/OrbPickupManager.server.lua"
copy_file "src/ServerScriptService/SquashHandler.server.lua" "src/Server/Orbs/SquashHandler.server.lua"
copy_file "src/ServerScriptService/SquashTracker.server.lua" "src/Server/Orbs/SquashTracker.server.lua"

# Client files
copy_file "src/StarterPlayer/StarterPlayerScripts/GiantBuyModal.lua" "src/Client/Economy/GiantBuyModal.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/SpeedBuyModal.lua" "src/Client/Economy/SpeedBuyModal.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/BuyModalsInit.client.lua" "src/Client/Economy/BuyModalsInit.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/NotificationManager.lua" "src/Client/Notifications/NotificationManager.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/BuySuccessNotifications.client.lua" "src/Client/Notifications/BuySuccessNotifications.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/SpawnSizeNotification.client.lua" "src/Client/Notifications/SpawnSizeNotification.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/OnboardingMessageNotification.client.lua" "src/Client/Notifications/OnboardingMessageNotification.client.lua"
copy_file "src/StarterGui/BottomBarManager.client.lua" "src/Client/HUD/BottomBarManager.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/OverheadSizeDisplay.client.lua" "src/Client/HUD/OverheadSizeDisplay.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/SpeedBoostEffects.client.lua" "src/Client/Orbs/SpeedBoostEffects.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/OrbPickupEffects.client.lua" "src/Client/Orbs/OrbPickupEffects.client.lua"
copy_file "src/StarterPlayer/StarterPlayerScripts/SquashEffectHandler.client.lua" "src/Client/Orbs/SquashEffectHandler.client.lua"

# Shared files
copy_file "src/ReplicatedStorage/EventManager.lua" "src/Shared/Core/EventManager.lua"
copy_file "src/ReplicatedStorage/SizeStateMachine.lua" "src/Shared/Core/SizeStateMachine.lua"
copy_file "src/ReplicatedStorage/PlayerSizeCalculator.lua" "src/Shared/Progression/PlayerSizeCalculator.lua"
copy_file "src/ReplicatedStorage/ButtonStyler.lua" "src/Shared/UI/ButtonStyler.lua"
copy_file "src/ReplicatedStorage/OrbSpawner.lua" "src/Shared/Orbs/OrbSpawner.lua"
copy_file "src/ReplicatedStorage/OrbVisuals.lua" "src/Shared/Orbs/OrbVisuals.lua"
copy_file "src/ReplicatedStorage/OrbCounter.lua" "src/Shared/Orbs/OrbCounter.lua"
copy_file "src/ReplicatedStorage/OrbFTUCluster.lua" "src/Shared/Orbs/OrbFTUCluster.lua"
copy_file "src/ReplicatedStorage/OrbPositionManager.lua" "src/Shared/Orbs/OrbPositionManager.lua"
copy_file "src/ReplicatedStorage/RandomOrbPositions.lua" "src/Shared/Orbs/RandomOrbPositions.lua"
copy_file "src/ReplicatedStorage/SoundRegistry.lua" "src/Shared/Audio/SoundRegistry.lua"

echo "Reorganization complete! Check for any warnings above."
echo "Next steps:"
echo "1. Test in Studio"
echo "2. If everything works, run cleanup.sh"
echo "3. If there are issues, we can fix them before cleanup" 