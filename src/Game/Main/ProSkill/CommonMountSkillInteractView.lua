---
--- Author: chunfengluo
--- DateTime: 2023-08-10 14:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MountSkillVM = require("Game/Mount/VM/MountSkillVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local MountMgr = _G.MountMgr
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class CommonMountSkillInteractView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconSkill UFImage
---@field ImgSlot UFImage
---@field NamedSlotChild UNamedSlot
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIF

local CommonMountSkillInteractView = LuaClass(UIView, true)

function CommonMountSkillInteractView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMount = nil
	--self.IconSkill = nil
	--self.ImgCD = nil
	--self.ImgSlot = nil
	--self.Mask = nil
	--self.NamedSlotChild = nil
	--self.TextCD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonMountSkillInteractView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonMountSkillInteractView:OnInit()
	self.ViewModel = MountSkillVM.New()
	self.CDCountDown = UIAdapterCountDown.CreateAdapter(self, self.TextCD, nil, nil, self.OnCDFinished, self.OnCDUpdate)
end

function CommonMountSkillInteractView:OnDestroy()

end

function CommonMountSkillInteractView:OnShow()
	UIUtil.SetIsVisible(self.IconSkill, true)
	UIUtil.SetIsVisible(self.BtnMount, true, true)
	UIUtil.SetIsVisible(self.ImgSlot, true)
	UIUtil.SetIsVisible(self.ImgCD, false)
	UIUtil.SetIsVisible(self.TextCD, false)
end

function CommonMountSkillInteractView:OnHide()

end

function CommonMountSkillInteractView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMount, self.OnClickedButton)
end

function CommonMountSkillInteractView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.StartSwimming, self.OnGameEventStartSwimming)
	self:RegisterGameEvent(EventID.EndSwimming, self.OnGameEventEndSwimming)
	self:RegisterGameEvent(EventID.MountFlyStateChange, self.OnGameEventMountFlyStateChange)
end

function CommonMountSkillInteractView:OnRegisterBinder()
	local Binders = {
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill)},
		{"CDFinishTime", UIBinderValueChangedCallback.New(self, nil, self.OnCDFinishTimeChanged)},
		{"SkillEnable", UIBinderSetIsVisible.New(self, self.Mask, true)}
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function CommonMountSkillInteractView:UpdateVM(ViewModel)
	self.ViewModel:UpdateVM(ViewModel)
end

function CommonMountSkillInteractView:OnClickedButton()
	if self.ViewModel.SkillEnable then
		MountMgr:PlayAction(self.ViewModel.SkillID, self.ViewModel.Index)
	else
		MsgTipsUtil.ShowTips(LSTR("当前状态无法使用"))
	end
end

function CommonMountSkillInteractView:OnCDFinishTimeChanged(Value)
	if Value > TimeUtil:GetServerTimeMS() then
		self.CDCountDown:Start(Value, 0.05, true, true)
		UIUtil.SetIsVisible(self.ImgCD, true)
		UIUtil.SetIsVisible(self.TextCD, true)
	end
end

function CommonMountSkillInteractView:OnCDFinished()
	UIUtil.SetIsVisible(self.ImgCD, false)
	UIUtil.SetIsVisible(self.TextCD, false)
end

function CommonMountSkillInteractView:OnCDUpdate()
	local RemainTime = self.ViewModel.CDFinishTime - TimeUtil:GetServerTimeMS()
	local Percent = RemainTime / self.ViewModel.SkillCD
	self.ImgCD:SetPercent(Percent)
	return string.format("%d", RemainTime // 1000) + 1
end


function CommonMountSkillInteractView:OnGameEventStartSwimming(Params)
    local EntityID = Params.ULongParam1
	if MajorUtil.IsMajor(EntityID) then
		self.ViewModel:UpdateSkillEnable(false)
	end
end

function CommonMountSkillInteractView:OnGameEventEndSwimming(Params)
    local EntityID = Params.ULongParam1
	if MajorUtil.IsMajor(EntityID) then
		self.ViewModel:UpdateSkillEnable(true)
	end
end

function CommonMountSkillInteractView:OnGameEventMountFlyStateChange(Params)
	local EntityID = Params.ULongParam1
	if MajorUtil.IsMajor(EntityID) then
		self.ViewModel:UpdateSkillEnable(not Params.BoolParam1)
	end
end

return CommonMountSkillInteractView