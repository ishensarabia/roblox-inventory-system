-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
-- Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {
		InventoryChanged = Knit.CreateSignal(),
	},
})

--[=[
    Fetches the player's inventory data.
]=]
function InventoryService:GetPlayerInventory(player: Player)
	local playerData = self._DataStoreService:GetData(player)
	return playerData.Items
end

function InventoryService.Client:GetPlayerInventory(player: Player)
	return self.Server:GetPlayerInventory(player)
end

function InventoryService:AddItem(player: Player, item: table)
	local playerData = self._DataStoreService:GetData(player)
	
	-- Stacking Logic: Check if item already exists by ItemID
	local existingItem = nil
	for _, v in ipairs(playerData.Items) do
		if v.ItemID == item.ItemID then
			existingItem = v
			break
		end
	end

	if existingItem then
		existingItem.Quantity = (existingItem.Quantity or 1) + 1
	else
		item.Quantity = 1
		table.insert(playerData.Items, item)
	end

	self._DataStoreService:UpdateProfileKeyValue(player, "Items", playerData.Items)
	self.Client.InventoryChanged:Fire(player, playerData.Items)
end

function InventoryService:RemoveItem(player: Player, item: table)
	local playerData = self._DataStoreService:GetData(player)
	for i, v in ipairs(playerData.Items) do
		-- For removing specific stacks or items
		if v.ItemID == item.ItemID then
			if (v.Quantity or 1) > 1 then
				v.Quantity -= 1
			else
				table.remove(playerData.Items, i)
			end
			break
		end
	end
	self._DataStoreService:UpdateProfileKeyValue(player, "Items", playerData.Items)
	self.Client.InventoryChanged:Fire(player, playerData.Items)
end

function InventoryService.Client:RemoveItem(player: Player, item: table)
	self.Server:RemoveItem(player, item)
end

function InventoryService:KnitStart()
	
end

function InventoryService:KnitInit()
	self._DataStoreService = Knit.GetService("DataService")
end

return InventoryService
