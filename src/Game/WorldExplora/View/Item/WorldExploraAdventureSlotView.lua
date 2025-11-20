---
--- Author: zerodeng
--- DateTime: 2025-05-29 20:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local AdventureItemsItemView = require("Game/Adventure/AdventureItem/AdventureItemsItemView")

---@class WorldExploraAdventureSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPointTips UFButton
---@field CommBackpack96Slot CommBackpack96SlotView
---@field IconReceived UFImage
---@field ImgIcon UFImage
---@field ImgJob UFImage
---@field PanelFunction UFCanvasPanel
---@field PanelGot UFCanvasPanel
---@field PanelProbarPoint UFCanvasPanel
---@field RichTextQuantity URichTextBox
---@field TextDate UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraAdventureSlotView = LuaClass(AdventureItemsItemView, true)

function WorldExploraAdventureSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPointTips = nil
	--self.CommBackpack96Slot = nil
	--self.IconReceived = nil
	--self.ImgIcon = nil
	--self.ImgJob = nil
	--self.PanelFunction = nil
	--self.PanelGot = nil
	--self.PanelProbarPoint = nil
	--self.RichTextQuantity = nil
	--self.TextDate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraAdventureSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end


return WorldExploraAdventureSlotView