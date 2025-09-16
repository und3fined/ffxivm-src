---
--- Author: Administrator
--- DateTime: 2024-01-18 20:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")

local FishItemVM = require("Game/Fish/FishItemVM")

local FishCfg = require("TableCfg/FishCfg")
local FishDefine = require("Game/Fish/FishDefine")

---@class FishNewThingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_42 UFTextBlock
---@field FishNewSlotItem126px_UIBP FishNewSlotItem126pxView
---@field TextLevel UFTextBlock
---@field TextSize UFTextBlock
---@field AnimFishGet1 UWidgetAnimation
---@field AnimFishGet2 UWidgetAnimation
---@field AnimFishGet3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewThingTipsItemView = LuaClass(UIView, true)

function FishNewThingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_42 = nil
	--self.FishNewSlotItem126px_UIBP = nil
	--self.TextLevel = nil
	--self.TextSize = nil
	--self.AnimFishGet1 = nil
	--self.AnimFishGet2 = nil
	--self.AnimFishGet3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewThingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishNewSlotItem126px_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewThingTipsItemView:OnInit()
	self.FishItemVM = FishItemVM.New()
	local FishNewItemTipsText = FishDefine.FishNewThingTipsItemText
	self.Binder = {
		{"FishLevel", UIBinderSetTextFormat.New(self, self.TextLevel, FishNewItemTipsText.TextLevel)},
		{"FishSize", UIBinderSetTextFormat.New(self, self.TextSize, FishNewItemTipsText.TextSize)},
		{"FishName", UIBinderSetText.New(self, self.FTextBlock_42)},
	}
end

function FishNewThingTipsItemView:OnDestroy()

end

function FishNewThingTipsItemView:OnShow()

end

function FishNewThingTipsItemView:OnHide()

end

function FishNewThingTipsItemView:OnRegisterUIEvent()

end

function FishNewThingTipsItemView:OnRegisterGameEvent()

end

function FishNewThingTipsItemView:OnRegisterBinder()
	self:RegisterBinders(self.FishItemVM,self.Binder)
end

function FishNewThingTipsItemView:OnFishLift(FishID,FishCount,FishSize,FishValue,IsNew)
	self.FishItemVM:InitFishInfo(FishID, FishCount, FishSize, FishValue)
	self.FishNewSlotItem126px_UIBP:FishReleaseTipInfoInit(FishID,FishCount)
	self:PlayFishGetAnim(FishID,IsNew)
end

function FishNewThingTipsItemView:PlayFishGetAnim(FishID,IsNew)
	local Cfg = FishCfg:FindCfgByKey(FishID)
	if Cfg then
		if Cfg.Rarity < 3 then
			self:PlayAnimation(self.AnimFishGet1)
		elseif Cfg.Rarity == 3 then --鱼王
			self:PlayAnimation(self.AnimFishGet2)
		elseif Cfg.Rarity == 4 then --鱼皇
			self:PlayAnimation(self.AnimFishGet3)
		end
	end
	if IsNew then
		self.FishNewSlotItem126px_UIBP:PlayAnimationNew()
	end
end

function FishNewThingTipsItemView:SequenceEventFlyStart()
	self.ParentView:DelayOnFishLift()
end

return FishNewThingTipsItemView