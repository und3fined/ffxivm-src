---
--- Author: zerodeng
--- DateTime: 2025-06-03 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMainPanelAwardThingItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelAwardThingItemView")

---@class WorldExploraAwardListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field IconCollect UFImage
---@field ImgSelect UFImage
---@field TextCategory UFTextBlock
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraAwardListItemView = LuaClass(GoldSauserMainPanelAwardThingItemView, true)

function WorldExploraAwardListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.IconCollect = nil
	--self.ImgSelect = nil
	--self.TextCategory = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraAwardListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

return WorldExploraAwardListItemView