---
--- Author: Administrator
--- DateTime: 2024-06-04 14:59
--- Description:
--- 生效特效ItemView

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ArmyMgr

---@class ArmySpecialEffectsItem02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field PanelEmpty UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsItem02View = LuaClass(UIView, true)

function ArmySpecialEffectsItem02View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.PanelEmpty = nil
	--self.PanelNormal = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.TextEmpty = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItem02View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItem02View:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
    self.Binders = {
        {"IsEmpty", UIBinderSetIsVisible.New(self, self.PanelEmpty)}, 
		{"IsEmpty", UIBinderSetIsVisible.New(self, self.PanelNormal, true)}, 
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)}, 
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)}, 
		{"Name", UIBinderSetText.New(self, self.Text01)}, 
		{"Desc", UIBinderSetText.New(self, self.Text02)}, 
		{"TimeStr", UIBinderSetText.New(self, self.TextTime)},
		{"Time", UIBinderValueChangedCallback.New(self, nil, self.OnEndTimeChanged)},
    }
end

function ArmySpecialEffectsItem02View:OnDestroy()

end

function ArmySpecialEffectsItem02View:OnShow()
	---LSTR:String: 未启用部队特效
	self.TextEmpty:SetText(string.format("-%s-",LSTR(910278)))
end

function ArmySpecialEffectsItem02View:OnHide()

end

function ArmySpecialEffectsItem02View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClicked)
end

function ArmySpecialEffectsItem02View:OnRegisterGameEvent()

end

function ArmySpecialEffectsItem02View:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end


function ArmySpecialEffectsItem02View:OnClicked()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index, self.ViewModel)
end

function ArmySpecialEffectsItem02View:OnEndTimeChanged(Time)
	if Time and Time < 60 then
		self.EndTimer = self:RegisterTimer(self.TimeDataUpdate, 0, 1, -1)
	end
end

function ArmySpecialEffectsItem02View:TimeDataUpdate(Params)
	local CurTime = TimeUtil.GetServerTime()
	local Time = self.ViewModel.EndTime - CurTime
	if Time > 0 then
		local TimeStr = LocalizationUtil.GetCountdownTimeForSimpleTime(Time, "s")
		self.ViewModel:SetTimeStr(TimeStr)
	else
		if self.EndTimer then
			self:UnRegisterTimer(self.EndTimer)
			self.EndTimer = nil
		end
		ArmyMgr:QueryGroupBonusState()
	end
end

return ArmySpecialEffectsItem02View