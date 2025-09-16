---
--- Author: Administrator
--- DateTime: 2024-01-10 16:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class CardsTourneyRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field CommSlot CommBackpackSlotView
---@field ImgSelect UFImage
---@field AnimRollFails UWidgetAnimation
---@field AnimRollUpLoop UWidgetAnimation
---@field AnimRollWait UWidgetAnimation
---@field AnimRollWin UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyRewardItemView = LuaClass(UIView, true)

function CardsTourneyRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.CommSlot = nil
	--self.ImgSelect = nil
	--self.AnimRollFails = nil
	--self.AnimRollUpLoop = nil
	--self.AnimRollWait = nil
	--self.AnimRollWin = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyRewardItemView:OnInit()
	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function CardsTourneyRewardItemView:OnDestroy()

end

function CardsTourneyRewardItemView:OnShow()

end

function CardsTourneyRewardItemView:OnHide()

end

function CardsTourneyRewardItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClicked)
end

function CardsTourneyRewardItemView:OnRegisterGameEvent()

end

function CardsTourneyRewardItemView:OnRegisterBinder()

end

function CardsTourneyRewardItemView:OnSelectPerform()
	UIUtil.SetIsVisible(self.ImgSelect, true)
end

function CardsTourneyRewardItemView:SetRewardText(Text)
	local TextNumWidget = self.CommSlot.RichTextNum
	if TextNumWidget == nil then
		return
	end
	UIUtil.SetIsVisible(TextNumWidget, true)
	TextNumWidget:SetText(Text)		
end

function CardsTourneyRewardItemView:SetIconImg(Path)
	self.CommSlot:SetIconImg(Path)
end

function CardsTourneyRewardItemView:SetNum(Num)
	self.CommSlot:SetNum(Num)
end

function CardsTourneyRewardItemView:SetResID(ResID)
	self.ItemID = ResID
end

function CardsTourneyRewardItemView:OnBtnClicked()
	ItemTipsUtil.ShowTipsByItem({ResID = self.ItemID}, self.CommSlot, {X = -2, Y = -15})
end

return CardsTourneyRewardItemView