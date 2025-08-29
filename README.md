# Roblox Police AI System

A comprehensive police AI system for Roblox games featuring intelligent officers with pathfinding, combat, and damage systems.

## Features

### Core AI Behavior
- **Patrol System**: Officers automatically patrol the map using PathfindingService
- **Enemy Detection**: Officers detect players within configurable detection radius
- **Combat System**: Officers engage in combat with damage falloff based on distance
- **Health Management**: Officers take damage, show injury effects, and respawn when killed

### Officer Types
- **Regular Officer**: Balanced stats, blue uniform, pistol weapon
- **SWAT**: High health and damage, black uniform, rifle weapon  
- **FBI**: High detection range, gray uniform, SMG weapon

### Technical Features
- **Modular Design**: Easy to extend with new officer types and behaviors
- **Configurable Stats**: All officer stats configurable via Config.luau
- **Pathfinding**: Obstacle avoidance and intelligent movement
- **Damage System**: Distance-based damage falloff and visual feedback
- **Health Bars**: Real-time health display for all officers
- **Asset System**: Easy integration with custom models, sounds, and effects

## File Structure

```
src/
├── shared/
│   ├── Config.luau          # Configuration for officer types and system settings
│   ├── Utilities.luau       # Utility functions for common operations
│   └── DamageSystem.luau    # Damage calculation and effects system
├── server/
│   ├── PoliceOfficer.luau   # Individual officer AI behavior
│   ├── PoliceManager.luau   # Manages spawning and respawning of officers
│   └── init.server.luau     # Main server initialization
└── client/
    └── init.client.luau     # Client UI and damage feedback
```

## Roblox Service Structure

The scripts are organized under the proper Roblox services:

- **ServerScriptService** → **Server** → **init.server.luau**
- **ServerScriptService** → **Server** → **PoliceOfficer.luau**
- **ServerScriptService** → **Server** → **PoliceManager.luau**
- **StarterPlayer** → **StarterPlayerScripts** → **Client** → **init.client.luau**
- **ReplicatedStorage** → **Shared** → **Config.luau**
- **ReplicatedStorage** → **Shared** → **Utilities.luau**
- **ReplicatedStorage** → **Shared** → **DamageSystem.luau**

## Asset System

The system supports custom assets through ReplicatedStorage. Create the following structure:

```
ReplicatedStorage/
└── Assets/
    ├── Officers/           # Officer models
    │   ├── PoliceOfficer   # Regular officer model
    │   ├── SWATOfficer     # SWAT officer model
    │   └── FBIOfficer      # FBI officer model
    ├── Weapons/            # Weapon models
    │   ├── Pistol          # Pistol weapon model
    │   ├── Rifle           # Rifle weapon model
    │   └── SMG             # SMG weapon model
    ├── Sounds/             # Sound effects
    │   ├── PistolShot      # Pistol firing sound
    │   ├── RifleShot       # Rifle firing sound
    │   ├── SMGShot         # SMG firing sound
    │   ├── OfficerDeath    # Officer death sound
    │   ├── OfficerInjured  # Officer injured sound
    │   └── Footsteps       # Footstep sounds
    └── Effects/            # Visual effects
        ├── BulletImpact    # Bullet impact effect
        ├── BloodSplatter   # Blood effect
        └── MuzzleFlash     # Muzzle flash effect
```

### Adding Custom Assets

1. **Officer Models**: Create models with Humanoid and HumanoidRootPart
2. **Weapon Models**: Create weapon models that can be welded to characters
3. **Sounds**: Add Sound objects with appropriate audio files
4. **Effects**: Create visual effects using particles or models

The system will automatically detect and use your custom assets, or fall back to basic models if assets are missing.

## Installation

1. **Setup Rojo**: Ensure you have Rojo installed and configured
2. **Sync Files**: Use Rojo to sync the project to Roblox Studio
3. **Add Assets**: Create the Assets folder structure in ReplicatedStorage
4. **Test**: The system will automatically start when you run the game

## Configuration

### Officer Types
Edit `src/shared/Config.luau` to modify officer stats:

```lua
Config.OfficerTypes = {
    Officer = {
        health = 100,
        damage = 25,
        detectionRadius = 50,
        attackRange = 30,
        patrolSpeed = 8,
        chaseSpeed = 12,
        weapon = "Pistol",
        uniform = "PoliceUniform",
        spawnRate = 0.8, -- 80% chance to spawn
        respawnTime = 10,
        -- Asset references
        modelName = "PoliceOfficer",
        weaponModelName = "Pistol",
        sounds = {
            attack = "PistolShot",
            death = "OfficerDeath",
            injured = "OfficerInjured",
            patrol = "Footsteps"
        }
    },
    -- Add more officer types here
}
```

### System Settings
Configure overall system behavior:

```lua
Config.System = {
    maxOfficers = 10,
    spawnInterval = 5, -- seconds between spawn attempts
    damageFalloff = {
        maxDistance = 50,
        minDamageMultiplier = 0.3,
    },
    -- Asset paths
    assets = {
        officers = "Assets.Officers",
        weapons = "Assets.Weapons",
        sounds = "Assets.Sounds",
        effects = "Assets.Effects"
    }
}
```

## Usage

### In-Game Commands
Players can use these chat commands for testing:

- `/policestats` - Show current police system statistics
- `/spawnofficer` - Force spawn a regular officer
- `/spawnswat` - Force spawn a SWAT officer  
- `/spawnfbi` - Force spawn an FBI officer
- `/removeall` - Remove all officers
- `/stop` - Stop the police system
- `/start` - Start the police system
- `/checkassets` - Check if all assets are available
- `/help` - Show help message

### Client UI
- Press **F1** to toggle the police system UI
- UI shows real-time statistics about active officers
- Damage notifications appear when players take damage

## Testing Criteria

✅ **Police spawn and move**: Officers spawn automatically and patrol the map
✅ **Detect & attack criminals**: Officers detect players and engage in combat
✅ **Different officer types behave differently**: Each type has unique stats and behavior
✅ **Police take damage and die properly**: Officers show damage effects and respawn
✅ **Custom assets integration**: System uses custom models and sounds when available

## Core Loop

1. **Spawn**: Officers spawn at random locations around the map
2. **Patrol**: Officers move between patrol points using pathfinding
3. **Detect**: Officers scan for players within their detection radius
4. **Engage**: When players are detected, officers chase and attack
5. **Combat**: Officers deal damage with distance-based falloff
6. **Damage**: Officers take damage from player attacks
7. **Death**: When health reaches 0, officers die and respawn after a delay

## Extending the System

### Adding New Officer Types
1. Add configuration to `Config.OfficerTypes`
2. Create corresponding model in `ReplicatedStorage/Assets/Officers/`
3. Add weapon model in `ReplicatedStorage/Assets/Weapons/`
4. Add sounds in `ReplicatedStorage/Assets/Sounds/`

### Adding New Weapons
1. Update weapon stats in `DamageSystem.luau`
2. Add weapon model to `ReplicatedStorage/Assets/Weapons/`
3. Update officer configurations to use the new weapon

### Adding New Behaviors
1. Extend the `PoliceOfficer` class with new methods
2. Update the AI state machine in `UpdateAI()`

## Performance Considerations

- **Officer Limit**: Configurable maximum number of officers
- **Pathfinding**: Uses efficient PathfindingService with waypoint spacing
- **Damage Calculation**: Optimized distance calculations
- **Memory Management**: Proper cleanup of destroyed officers
- **Asset Loading**: Efficient asset loading with fallback system

## Troubleshooting

### Officers Not Spawning
- Check console for error messages
- Verify spawn points are accessible
- Ensure maximum officer limit isn't reached
- Use `/checkassets` to verify assets are available

### Officers Not Moving
- Check if PathfindingService is enabled
- Verify spawn points are on walkable surfaces
- Check for obstacles blocking movement

### Officers Not Attacking
- Verify detection radius is appropriate
- Check if players are within attack range
- Ensure damage system is working correctly

### Custom Assets Not Loading
- Verify Assets folder structure in ReplicatedStorage
- Check model names match configuration
- Ensure models have proper Humanoid setup
- Use `/checkassets` command to diagnose issues

## Future Enhancements

- **Squad Formations**: Officers working together in groups
- **Voice Lines**: Audio feedback for different situations
- **Advanced Tactics**: Cover system, grenades, hostage scenarios
- **Weapon Variety**: More weapon types and effects
- **AI Improvements**: More sophisticated decision making
- **Animation System**: Custom animations for different actions

## License

This project is open source and available under the MIT License.

## Support

For issues or questions, please check the troubleshooting section or create an issue in the project repository.