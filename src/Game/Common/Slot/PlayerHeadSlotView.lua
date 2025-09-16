---
--- Author: chunfengluo
--- DateTime: 2021-08-23 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PlayerHeadSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_Head UImage
---@field Img_Leader UImage
---@field LevelNum UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayerHeadSlotView = LuaClass(UIView, true)

function PlayerHeadSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Img_Head = nil
	self.Img_Leader = nil
	self.LevelNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayerHeadSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayerHeadSlotView:OnInit()

end

function PlayerHeadSlotView:OnDestroy()

end

function PlayerHeadSlotView:OnShow()

end

function PlayerHeadSlotView:OnHide()

end

function PlayerHeadSlotView:OnRegisterUIEvent()

end

function PlayerHeadSlotView:OnRegisterGameEvent()

end

function PlayerHeadSlotView:OnRegisterTimer()

end

function PlayerHeadSlotView:OnRegisterBinder()

end

return PlayerHeadSlotView