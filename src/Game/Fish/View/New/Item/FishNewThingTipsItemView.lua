---
--- Author: Administrator
--- DateTime: 2024-01-18 20:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")

local FishItemVM = require("Game/Fish/FishItemVM")

local FishCfg = require("TableCfg/FishCfg")
local FishDefine = require("Game/Fish/FishDefine")

---@class FishNewThingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FHorizontalRanking UFHorizontalBox
---@field FTextBlock_42 UFTextBlock
---@field FishNewSlotItem126px_UIBP FishNewSlotItem126pxView
---@field ImgRanking1 UFImage
---@field ImgRanking2 UFImage
---@field TextLevel UFTextBlock
---@field TextNum1 UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextSize UFTextBlock
---@field AnimFishGet1 UWidgetAnimation
---@field AnimFishGet2 UWidgetAnimation
---@field AnimFishGet3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewThingTipsItemView = LuaClass(UIView, true)

function FishNewThingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FHorizontalRanking = nil
	--self.FTextBlock_42 = nil
	--self.FishNewSlotItem126px_UIBP = nil
	--self.ImgRanking1 = nil
	--self.ImgRanking2 = nil
	--self.TextLevel = nil
	--self.TextNum1 = nil
	--self.TextNum2 = nil
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
	self.bFishLift = false
	self.bFishNoteRank = false
	self.FishID = nil
	self.bNew = false
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
	self:RegisterGameEvent(EventID.FishNoteUpdateRank, self.OnUpdateFishRank)
end

function FishNewThingTipsItemView:OnRegisterBinder()
	self:RegisterBinders(self.FishItemVM,self.Binder)
end

function FishNewThingTipsItemView:OnFishLift(FishID,FishCount,FishSize,FishValue,IsNew)
	self.bFishLift = true
	self.FishItemVM:InitFishInfo(FishID, FishCount, FishSize, FishValue)
	self.FishNewSlotItem126px_UIBP:FishReleaseTipInfoInit(FishID,FishCount)
	self.FishID = FishID
	self.bNew = IsNew
	self:PlayFishGetAnim()
end

function FishNewThingTipsItemView:PlayFishGetAnim()
	if self.bFishNoteRank == false or self.bFishLift == false then
		-- 必须等提竿事件和钓鱼排名事件都触发之后才能播放动画显示UI
		return
	end
	local Cfg = FishCfg:FindCfgByKey(self.FishID)
	if Cfg then
		if Cfg.Rarity < 3 then
			self:PlayAnimation(self.AnimFishGet1)
		elseif Cfg.Rarity == 3 then --鱼王
			self:PlayAnimation(self.AnimFishGet2)
		elseif Cfg.Rarity == 4 then --鱼皇
			self:PlayAnimation(self.AnimFishGet3)
		end
	end
	if self.bNew then
		self.FishNewSlotItem126px_UIBP:PlayAnimationNew()
	end
	self.bFishLift = false
	self.bFishNoteRank = false
end

function FishNewThingTipsItemView:SequenceEventFlyStart()
	self.ParentView:DelayOnFishLift()
end

function FishNewThingTipsItemView:OnUpdateFishRank(Params)
	self.bFishNoteRank = true
	if Params.bShowRank == false then
		UIUtil.SetIsVisible(self.FHorizontalRanking, false)
	else
		UIUtil.SetIsVisible(self.FHorizontalRanking, true)
		self.TextNum1:SetText(Params.OldRankText)
		UIUtil.SetColorAndOpacityHex(self.TextNum1, Params.OldRankColor)
		UIUtil.SetColorAndOpacityHex(self.ImgRanking1, Params.OldRankColor)
		self.TextNum2:SetText(Params.CurRankText)
		UIUtil.SetColorAndOpacityHex(self.TextNum2, Params.CurRankColor)
		UIUtil.SetColorAndOpacityHex(self.ImgRanking2, Params.CurRankColor)
	end
	self:PlayFishGetAnim()
end

return FishNewThingTipsItemView