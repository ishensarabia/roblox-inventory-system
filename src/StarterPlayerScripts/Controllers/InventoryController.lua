-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Components
local InventoryView = require(script.Parent.Parent.Components.InventoryView)

-- Constants
local INVENTORY_TOGGLE_ACTION_NAME = "ToggleInventory"
local TOGGLE_KEY_PC = Enum.KeyCode.Tab
local TOGGLE_KEY_GAMEPAD = Enum.KeyCode.ButtonY

local InventoryController = Knit.CreateController({
	Name = "InventoryController",
	InventoryChanged = Signal.new(),
})

function InventoryController:KnitStart()
	-- Disable the PlayerList to free up the TAB key
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local inventoryGui = playerGui:WaitForChild("InventoryGui")
	
	-- Ensure GUI is on top and behaves correctly
	inventoryGui.DisplayOrder = 100
	inventoryGui.IgnoreGuiInset = true

	self.View = InventoryView.new(inventoryGui)
	self.View:SetVisible(false)

	local InventoryService = Knit.GetService("InventoryService")

	local function observeInventoryItems(inventoryItems: table)
		self.View:Update(inventoryItems, function(item)
			InventoryService:RemoveItem(item)
		end)
		self.InventoryChanged:Fire(inventoryItems)
	end

	InventoryService:GetPlayerInventory():andThen(observeInventoryItems)
	InventoryService.InventoryChanged:Connect(observeInventoryItems)

	local function toggleInventory()
		self.View:Toggle()
	end

	-- Direct Input handler for PC
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		-- We ignore gameProcessed ONLY for TAB if it's being sunk by core scripts
		if input.KeyCode == TOGGLE_KEY_PC then
			toggleInventory()
		end
	end)

	-- ContextActionService for Mobile and Gamepad support
	ContextActionService:BindAction(
		INVENTORY_TOGGLE_ACTION_NAME,
		function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
			if inputState == Enum.UserInputState.Begin then
				toggleInventory()
			end
		end,
		true,
		TOGGLE_KEY_GAMEPAD
	)

	ContextActionService:SetPosition(INVENTORY_TOGGLE_ACTION_NAME, UDim2.fromScale(0.8, 0.2))
	ContextActionService:SetImage(INVENTORY_TOGGLE_ACTION_NAME, "rbxassetid://87408344164007")
end

function InventoryController:KnitInit() end

return InventoryController
