# Simple Inventory System

A lightweight, robust, and modern inventory system built for Roblox using the **Knit** framework. It features a dark-themed UI, dynamic item management, and cross-platform support.

## Features
- **Modern Dark UI:** Centered, styled panel with smooth hover effects and tooltips.
- **Knit Integration:** Uses `InventoryService` (Server) and `InventoryController` (Client) for clean communication.
- **Dynamic Items:** Automatically generates item frames based on player data and an `ItemsEnum`.
- **Cross-Platform:** Supports Keyboard (Tab), Gamepad (ButtonY), and Mobile (Custom Action Button).
- **Persistent Data:** Integrated with `ProfileStore` for reliable data saving.

## Setup & Integration

### 1. Requirements
- **Aftman/Foreman:** For tool management (Rojo, Wally).
- **Knit:** Ensure the Knit package is installed in your project.

### 2. Item Configuration
Add your items to `src/ReplicatedStorage/Enums/ItemsEnum.lua`. Each item needs a Name, Description, and Image asset ID:
```lua
[ID] = { Name = "Item Name", Description = "Item Description", Image = "rbxassetid://..." }
```

### 3. Giving Items (Server-Side)
To give an item to a player, get the `InventoryService` and call `AddItem`:
```lua
local InventoryService = Knit.GetService("InventoryService")
InventoryService:AddItem(player, { ItemID = 1, GUID = HttpService:GenerateGUID() })
```

### 4. Customizing the UI
The GUI is located at `StarterGui.InventoryGui`. The visual style of item frames is controlled dynamically in `src/StarterPlayerScripts/Controllers/InventoryController.lua` within the `updateItemFrames` function.

## Key Bindings
- **PC:** `M`
- **Gamepad:** `ButtonY`
- **Mobile:** Tap the inventory icon.
