# ⚔️ Roblox Combat System

> A modular combat system for Roblox with dashing, sword mechanics, hitbox detection, VFX, and animations

[![Roblox](https://img.shields.io/badge/Roblox-Studio-blue.svg)](https://create.roblox.com/)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [System Architecture](#-system-architecture)
- [Folder Structure](#-folder-structure)
- [Core Components](#-core-components)
- [Sword System](#-sword-system)
- [Combat Mechanics](#-combat-mechanics)
- [Dash System](#-dash-system)
- [VFX & Audio](#-vfx--audio)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 📖 About

**Roblox Combat System** is a complete, production-ready combat framework for Roblox games. It features modular sword mechanics, responsive dashing, hitbox detection, VFX, sound effects, and animation synchronization. Built with performance and extensibility in mind using Luau scripting.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| ⚔️ **Sword Combat** | Multiple attack animations with combo system |
| 🏃 **Dashing** | Directional dash with speed boost |
| 🎯 **Hitbox Detection** | Accurate cylinder-based hitbox with enemy tracking |
| 🎬 **Animations** | Synchronized client-server animations using markers |
| 💥 **VFX System** | Particle effects on attack and hit events |
| 🔊 **Sound System** | Optimized sound playback with pooling |
| 🧠 **AI Integration** | Enemy death animations with limb detachment |
| 📦 **Modular Design** | Easy to add new weapons and abilities |

---
## 📁 Folder Structure
```
CombatSystem/
├── ReplicatedStorage/
│ ├── CombatAnimations/ # Animation assets
│ │ └── KatanaAnims/
│ │ ├── 1 (Animation)
│ │ ├── 2 (Animation)
│ │ └── 3 (Animation)
│ ├── Events/
│ │ ├── SwordEvents/
│ │ │ └── SwordStartup (RemoteEvent)
│ │ └── DashEvents/
│ │ └── DashAnimate (RemoteEvent)
│ ├── Modules/
│ │ └── SwordsUniversal.luau # Sword registry
│ ├── Swords/ # Tool assets
│ │ └── Purple Katana (Tool)
│ └── VFX/ # Particle effects
│ ├── purple-slash-id-01xde1e (Attachment)
│ └── purple-burst-id-01xde1e (Attachment)
├── ServerScriptService/
│ └── Attack.server.luau # Server-side combat logic
├── StarterPlayerScripts/
│ ├── Attack.client.luau # Client-side attack handling
│ ├── Dash.client.luau # Dash mechanics
│ └── PlayerController.client.luau # Weapon equipping
└── StarterGui/
└── (UI elements)
```
---
## 🎯 Core Components

### SwordsUniversal Module

Central registry for all sword configurations.

```lua
local swordsInfo = {
    ["Purple Katana"] = {
        Name = "Purple Katana",
        AnimationPack = "KatanaAnims",
        StartAnimationCount = 1,
        Sounds = {
            SwingSound = "rbxassetid://608537390",
            HitSound = "rbxassetid://566593606",
        },
        VFX = {
            [1] = "purple-slash-id-01xde1e",
            [2] = "purple-burst-id-01xde1e",
        },
    },
}
```
### Attack System
- Client-side: Detects input, plays animations, triggers remote events
- Server-side: Creates hitboxes, detects enemies, applies damage
### Dash System
- Directional dashing (WASD + Q)
- Speed boost and movement
- Synchronized animation playback
### ⚔️ Sword System
#### **Adding a New Sword**
1. Create the tool in ReplicatedStorage/Swords/
2. Add configuration to SwordsUniversal.luau:
```lua
["Your Sword Name"] = {
    Name = "Your Sword Name",
    AnimationPack = "YourAnimPack",
    StartAnimationCount = 1,
    Sounds = {
        SwingSound = "rbxassetid://123456",
        HitSound = "rbxassetid://789012",
    },
    VFX = {
        [1] = "your-slash-id",
        [2] = "your-burst-id",
    },
}
```
3. Create animations in ReplicatedStorage/CombatAnimations/YourAnimPack/
- Name animations: 1, 2, 3, etc.
- Add markers: Slowdown, Acceleration, Attack
### Animation Markers
| Marker | Effect |
|-----|-----|
| Slowdown | Reduces movement speed during attack |
| Acceleration | Restores movement speed |
| Attack | Triggers hitbox detection |
### ⚔️ Combat Mechanics
#### **Hitbox Detection**
#### The system uses a cylinder-based hitbox:
```lua
Attack(player, radius, angle, height, damage)
```
| Parameter | Description | Default |
|-----------|-------------|---------|
| radius | Width of the attack arc | 12 |
| angle | Swing angle (degrees) | 140 |
| height | Vertical range | 5 |
| damage | Damage per hit | 25 |
#### Damage Flow
1. Player attacks
2. Hitbox created (cylinder part)
3. Detects all valid targets
4. Applies damage to each target
5. Triggers VFX on hit
6. Handles enemy death (limb detachment)
#### Enemy Death Effects
- Neck joints destroyed
- Head physics simulation (ragdoll)
- Bleeding particle effects
- Body remains with VFX
### 🏃 Dash System
#### **Mechanics**
| property | value |
|----------|-------|
| Dash Key | Q |
| Dash Duration	| 3 seconds |
| BodyVelocity Lifetime	| 0.3 seconds |
| Dash Speed | 60 studs/sec |
| Max Force | 1e6 on X and Z axes |
#### **Directional Dash**
| Key | Direction | Animation
|-----|-----------|---------|
| W	| Forward | Front |
| A	| Left | Left |
| S	| Backward | Back |
| D	| Right | Right |
##### **Dash Flow**
1. Player presses Q
2. Checks held direction key (WASD)
3. Creates BodyVelocity in that direction
4. Plays corresponding animation
5. Auto-destroys velocity after 0.3s
6. Cooldown: 3 seconds
### **🎨 VFX & Audio**
#### **VFX System**
##### **Efficient VFX Management:**
- Caches VFX templates
- Clones and reuses instances
- Auto-cleanup with Debris
##### **VFX Types:**
- Attack VFX: Slash effects (purple-slash-id)
- Hit VFX: Burst effects on impact (purple-burst-id)
- Death VFX: Bleeding effects on enemies
#### **Audio System**
##### **Optimized Sound Playback:**
- Caches Sound instances
- Prevents overlapping sounds
- Auto-cleanup after playback
##### **Sound Types:**
- Swing Sound: Played on attack initiation
- Hit Sound: Played on successful hit
## **🚀 Installation**
#### **Prerequisites**
- Roblox Studio
- Basic understanding of Roblox Lua
#### **Steps**
#### **1. Setup Services**
```lua
-- In ReplicatedStorage
local events = Instance.new("Folder")
events.Name = "Events"

local modules = Instance.new("Folder")
modules.Name = "Modules"

local swords = Instance.new("Folder")
swords.Name = "Swords"

local vfx = Instance.new("Folder")
vfx.Name = "VFX"

local combatAnimations = Instance.new("Folder")
combatAnimations.Name = "CombatAnimations"
```
#### **2. Create Events**
```lua
-- In Events/SwordEvents/
local swordStartup = Instance.new("RemoteEvent")
swordStartup.Name = "SwordStartup"

-- In Events/DashEvents/
local dashAnimate = Instance.new("RemoteEvent")
dashAnimate.Name = "DashAnimate"
```
#### **3. Add SwordsUniversal Module**
```lua
-- In Modules/SwordsUniversal.luau
-- Paste the SwordsUniversal code
```
#### **4. Place Scripts**
- Server scripts → ServerScriptService
- Client scripts → StarterPlayerScripts
#### **5. Create Sword Tools**
- Add tools to ReplicatedStorage/Swords/
#### **6. Add VFX**
- Create Attachments with ParticleEmitters
- Add to ReplicatedStorage/VFX/
## 📝 Usage
### **Basic Combat Flow**
```lua
-- Client: Attack.client.luau
-- Equips sword and fires server event
swordStartup:FireServer(attackTool)

-- Server: Attack.server.luau
-- Creates hitbox, detects enemies, applies damage
local targets = Attack(player, 12, 140, 5, 25)
```
### **Adding Custom Sword**
```lua
-- In SwordsUniversal.luau
["Legendary Blade"] = {
    Name = "Legendary Blade",
    AnimationPack = "LegendaryAnims",
    StartAnimationCount = 1,
    Sounds = {
        SwingSound = "rbxassetid://111111",
        HitSound = "rbxassetid://222222",
    },
    VFX = {
        [1] = "legendary-slash-id",
        [2] = "legendary-burst-id",
    },
}
```
### **Custom Dash Settings**
```lua
-- In Dash.client.luau
const dashTime = 3              -- Cooldown (seconds)
const deleteBvTime = 0.3        -- BodyVelocity lifetime
const dashSpeed = 60            -- Movement speed
const maxDashForce = Vector3.new(1e6, 0, 1e6)
```
### **⚙️ Configuration**
#### **Attack Settings**
| Variable | Description | Default
|----------|-------------|-------|
| radius | Attack range | 12 |
| angle | Swing arc (degrees) | 140 |
| height | Vertical range | 5 |
| damage | Damage per hit | 25 |
| debounceTime | Attack cooldown | 0.9s |
#### **Dash Settings**
| Variable | Description | Default |
|----------|-------------|---------|
| dashTime | Dash cooldown | 3s |
| deleteBvTime | Velocity lifetime | 0.3s |
| dashSpeed	| Dash speed | 60 |
| maxDashForce | Max applied force | 1e6 |
## 🔜 Roadmap
#### □ Add blocking/parrying system
#### □ Implement combo counter system
#### □ Add dash invincibility frames
#### □ Support for ranged weapons
#### □ Add critical hit system
#### □ Implement stamina system
#### □ Add more sword types
#### □ Create UI for health/damage numbers
### 🐛 Error Handling
| Error Type | Handling |
|------------|----------|
| Sword Not Found	| Log error, return nil |
| Invalid Sword Name | Print warning, skip |
| Animation Missing	| Skip, continue execution |
| Network Issues | Retry with logging |
### 🤝 Contributing
1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add some amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request
## 📄 License
### Distributed under the MIT License. See LICENSE file for details.
## 📞 Contact
- Author: Your: Ats_Profi_Prog
- Project Link: [GitHub Repository](https://github.com/Y90G7IYO0987/CombatSystem)
## 🙏 Acknowledgments
- Roblox Studio for the platform
- Roblox Developer Hub for documentation
- Open source contributors
### ⭐ If you found this project helpful, please give it a star!

## Made with ❤️ for Roblox developers