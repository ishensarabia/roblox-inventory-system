# AGENT.md - Simple Inventory System Guide

This guide is for AI agents (like Gemini CLI) using MCP to interact with this project. It outlines the architecture, key files, and patterns used in the Simple Inventory System.

## System Architecture

The project uses the **Knit** framework for communication between Client and Server.

### Server Side
- **Location:** `src/ServerStorage/Services/InventoryService.lua`
- **Responsibilities:** Manages player data, adding/removing items, and syncing with `ProfileStore`.
- **Key Methods:**
    - `AddItem(player, item)`: Adds an item (table with `ItemID` and `GUID`) to the player's data.
    - `RemoveItem(player, item)`: Removes an item by its GUID.

### Client Side
- **Controller:** `src/StarterPlayerScripts/Controllers/InventoryController.lua`
    - **Responsibilities:** Acts as the "glue." It instantiates the View, listens to `InventoryService` for data changes, and handles input (Keybinds).
- **View (Component):** `src/StarterPlayerScripts/Components/InventoryView.lua`
    - **Responsibilities:** A standalone, non-Knit ModuleScript that handles all UI rendering, frame creation, and hover effects.
    - **Key Methods:**
        - `update(inventoryItems, onRemoveRequest)`: Refreshes the UI based on data.
        - `toggle()`: Switches UI visibility.

### Shared / Configuration
- **Location:** `src/ReplicatedStorage/Enums/ItemsEnum.lua`
- **Structure:** A dictionary mapping numerical IDs to item metadata (`Name`, `Description`, `Image`).

## GUI Structure (`StarterGui.InventoryGui`)

The GUI is built using standard Roblox instances and styled via code in the Controller.

- **InventoryGui (ScreenGui):** Root object.
    - **CanvasGroup:** The main centered panel.
        - **Header (Frame):** Contains the "INVENTORY" title.
        - **ScrollingFrame:** Holds the item grid.
            - **UIGridLayout:** Controls item frame positioning.

## Coding Patterns to Follow

1.  **Dynamic Styling:** Favor adding visual elements (UICorners, UIStrokes) via code in `InventoryView.lua` rather than manually in Studio to maintain consistency.
2.  **GUIDs:** Every item instance in the data MUST have a unique `GUID` for reliable identification and removal.
3.  **Knit Services:** Always use `Knit.GetService` or `Knit.GetController` to interact with other system modules.
4.  **Enums:** Reference `ItemsEnum` for all item metadata to avoid hardcoding strings or asset IDs.

## Common Agent Tasks

- **Adding a new item:** Update `ItemsEnum.lua` with a new ID and metadata.
- **Changing the theme:** Modify the `BackgroundColor3` and `UIStroke.Color` values in the `InventoryController.lua` and the `InventoryGui` setup script.
- **Adjusting Layout:** Modify the `CellSize` or `CellPadding` of the `UIGridLayout` inside the `InventoryGui`.
