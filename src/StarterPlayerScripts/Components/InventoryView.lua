local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsEnum = require(ReplicatedStorage.Source.Enums.ItemsEnum)

local InventoryView = {}
InventoryView.__index = InventoryView

function InventoryView.new(gui: ScreenGui)
	local self = setmetatable({}, InventoryView)
	self.Gui = gui
	self.ScrollingFrame = gui.CanvasGroup.ScrollingFrame
	self.ExistingItems = {}
	return self
end

function InventoryView:CreateHoverLabel(itemFrame, description)
	local hoverLabel = Instance.new("TextLabel")
	hoverLabel.Size = UDim2.fromScale(1, 0.3)
	hoverLabel.Position = UDim2.fromScale(0, 0.7)
	hoverLabel.Text = description
	hoverLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	hoverLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	hoverLabel.BackgroundTransparency = 0.2
	hoverLabel.TextScaled = true
	hoverLabel.Font = Enum.Font.GothamMedium
	hoverLabel.Visible = false
	hoverLabel.Parent = itemFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = hoverLabel

	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0.1, 0)
	padding.PaddingLeft = UDim.new(0.1, 0)
	padding.PaddingRight = UDim.new(0.1, 0)
	padding.PaddingTop = UDim.new(0.1, 0)
	padding.Parent = hoverLabel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 120)
	stroke.Thickness = 1
	stroke.Parent = hoverLabel

	itemFrame.MouseEnter:Connect(function()
		hoverLabel.Visible = true
		itemFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	end)

	itemFrame.MouseLeave:Connect(function()
		hoverLabel.Visible = false
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	end)
end

function InventoryView:Update(inventoryItems: table, onRemoveRequest: (item: table) -> ())
	-- Mark all existing items as not updated
	for itemID, _ in pairs(self.ExistingItems) do
		self.ExistingItems[itemID] = false
		local itemFrame = self.ScrollingFrame:FindFirstChild("Item_" .. itemID)
		if itemFrame then
			itemFrame:SetAttribute("ToRemove", true)
		end
	end

	for _, item: table in inventoryItems do
		local frameName = "Item_" .. item.ItemID
		local itemFrame = self.ScrollingFrame:FindFirstChild(frameName)
		
		if not itemFrame then
			-- Create new item frame
			itemFrame = Instance.new("Frame")
			itemFrame.Name = frameName
			itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			itemFrame.BackgroundTransparency = 0
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = self.ScrollingFrame

			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 8)
			itemCorner.Parent = itemFrame

			local itemStroke = Instance.new("UIStroke")
			itemStroke.Color = Color3.fromRGB(70, 70, 85)
			itemStroke.Thickness = 2
			itemStroke.Parent = itemFrame

			local itemImage = Instance.new("ImageLabel")
			itemImage.Size = UDim2.fromScale(0.7, 0.7)
			itemImage.Position = UDim2.fromScale(0.15, 0.1)
			itemImage.BackgroundTransparency = 1
			itemImage.Image = ItemsEnum[item.ItemID].Image
			itemImage.ScaleType = Enum.ScaleType.Fit
			itemImage.Parent = itemFrame

			local itemNameLabel = Instance.new("TextLabel")
			itemNameLabel.Size = UDim2.fromScale(0.9, 0.2)
			itemNameLabel.Position = UDim2.fromScale(0.05, 0.75)
			itemNameLabel.BackgroundTransparency = 1
			itemNameLabel.Text = ItemsEnum[item.ItemID].Name
			itemNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemNameLabel.Font = Enum.Font.GothamMedium
			itemNameLabel.TextScaled = true
			itemNameLabel.Parent = itemFrame

			-- Quantity Badge
			local quantityLabel = Instance.new("TextLabel")
			quantityLabel.Name = "QuantityLabel"
			quantityLabel.Size = UDim2.fromOffset(25, 20)
			quantityLabel.Position = UDim2.new(0, 5, 0, 5)
			quantityLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			quantityLabel.Font = Enum.Font.GothamBold
			quantityLabel.TextSize = 14
			quantityLabel.Parent = itemFrame

			local qtyCorner = Instance.new("UICorner")
			qtyCorner.CornerRadius = UDim.new(0, 4)
			qtyCorner.Parent = quantityLabel

			-- Create x button to remove item from inventory
			local removeButton = Instance.new("TextButton")
			removeButton.Parent = itemFrame
			removeButton.Size = UDim2.fromOffset(20, 20)
			removeButton.Position = UDim2.new(1, -5, 0, 5)
			removeButton.AnchorPoint = Vector2.new(1, 0)
			removeButton.Text = "×"
			removeButton.TextSize = 18
			removeButton.Font = Enum.Font.GothamBold
			removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			removeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(1, 0)
			btnCorner.Parent = removeButton

			removeButton.Activated:Connect(function()
				if onRemoveRequest then
					onRemoveRequest(item)
				end
			end)

			self:CreateHoverLabel(itemFrame, ItemsEnum[item.ItemID].Description)
		end

		-- Update Quantity
		local qLabel = itemFrame:FindFirstChild("QuantityLabel")
		if qLabel then
			local qty = item.Quantity or 1
			qLabel.Text = "x" .. tostring(qty)
			qLabel.Visible = qty > 1
		end

		-- Mark the item as updated
		self.ExistingItems[item.ItemID] = true
		itemFrame:SetAttribute("ToRemove", false)
	end

	-- Remove frames that are no longer in the inventory
	for _, itemFrame in ipairs(self.ScrollingFrame:GetChildren()) do
		if itemFrame:IsA("Frame") and itemFrame:GetAttribute("ToRemove") then
			itemFrame:Destroy()
		end
	end
end

function InventoryView:SetVisible(visible: boolean)
	self.Gui.Enabled = visible
end

function InventoryView:Toggle()
	self.Gui.Enabled = not self.Gui.Enabled
end

return InventoryView
