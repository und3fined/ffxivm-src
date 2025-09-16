---
--- Author: Administrator
--- DateTime: 2023-11-22 14:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyRemoveBadgeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadgeItem ArmyBadgeItemView
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnYes CommBtnLView
---@field HorizontalCurrency UFHorizontalBox
---@field ImgCurrency UFImage
---@field RichTextDiscribe URichTextBox
---@field TextCount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRemoveBadgeWinView = LuaClass(UIView, true)

function ArmyRemoveBadgeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadgeItem = nil
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnYes = nil
	--self.HorizontalCurrency = nil
	--self.ImgCurrency = nil
	--self.RichTextDiscribe = nil
	--self.TextCount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRemoveBadgeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadgeItem)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnYes)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRemoveBadgeWinView:OnInit()

end

function ArmyRemoveBadgeWinView:OnDestroy()

end

function ArmyRemoveBadgeWinView:OnShow()

end

function ArmyRemoveBadgeWinView:OnHide()

end

function ArmyRemoveBadgeWinView:OnRegisterUIEvent()

end

function ArmyRemoveBadgeWinView:OnRegisterGameEvent()

end

function ArmyRemoveBadgeWinView:OnRegisterBinder()

end

return ArmyRemoveBadgeWinView