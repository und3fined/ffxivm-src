---
--- Author: anypkvcai
--- DateTime: 2023-04-04 17:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewModel = require("UI/UIViewModel")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")

local SelectShowTypeDefine = {
	RepleaceIconBySelect = 0,
	ShowSelectFrameIconBySelect = 1,
}

local LockStateIcon = {
	Normal = "Texture2D'/Game/UI/Texture/CommPic/UI_Comm_SideTab_Img_Icon_Lock_Normal.UI_Comm_SideTab_Img_Icon_Lock_Normal'",
	Selected = "Texture2D'/Game/UI/Texture/CommPic/UI_Comm_SideTab_Img_Icon_Lock_Select.UI_Comm_SideTab_Img_Icon_Lock_Select'"
}

---@class CommVerIconTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field ImgIcon UFImage
---@field ImgIconSelect UFImage
---@field ImgMask UFImage
---@field ImgPattern UFImage
---@field ImgPatternFrameSelect UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field PanelPattern UFCanvasPanel
---@field PanelUnlock UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field TextPercent UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimPointLoop UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommVerIconTabItemView = LuaClass(UIView, true)

function CommVerIconTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.ImgIcon = nil
	--self.ImgIconSelect = nil
	--self.ImgMask = nil
	--self.ImgPattern = nil
	--self.ImgPatternFrameSelect = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.PanelPattern = nil
	--self.PanelUnlock = nil
	--self.RedDot2 = nil
	--self.TextPercent = nil
	--self.AnimCheck = nil
	--self.AnimLoop = nil
	--self.AnimPointLoop = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommVerIconTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommVerIconTabItemView:OnInit()
	self.SelectShowType = SelectShowTypeDefine.ShowSelectFrameIconBySelect
	self.IsUnLock = false
end

function CommVerIconTabItemView:OnDestroy()

end

function CommVerIconTabItemView:OnShow()
	UIUtil.ImageSetBrushFromAssetPath(self.ImgUnlock, LockStateIcon.Normal)
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil ~= Adapter then
		self:InitTab(Adapter.Params)
	end

	self:UpdateItem(Params.Data)
end

function CommVerIconTabItemView:OnHide()

end

function CommVerIconTabItemView:OnRegisterUIEvent()

end

function CommVerIconTabItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateTabRedDot, self.UpdateRedDot)
end

function CommVerIconTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel or not CommonUtil.IsA(self.ViewModel, UIViewModel) then
		return
	end

	local Binders = {
		{ "IsPlayPointAni", UIBinderValueChangedCallback.New(self, nil, self.OnIsPlayPointAniChanged) },
		{ "IsModuleOpen", UIBinderSetIsVisible.New(self, self.PanelUnlock) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "PatternIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPattern) },
		{ "SelectIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconSelect)},
		{ "TextPercentVisible", UIBinderSetIsVisible.New(self, self.TextPercent) },
		{ "Percent", UIBinderSetText.New(self, self.TextPercent) },
		{ "bShowlock", UIBinderSetIsVisible.New(self, self.ImgUnlock) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function CommVerIconTabItemView:OnSelectChanged(IsSelected)
	if not self.IsUnLock then
		return
	end
	
	UIUtil.SetIsVisible(self.PanelIcon, false)
	UIUtil.SetIsVisible(self.PanelPattern, false)
	if self.SelectShowType == SelectShowTypeDefine.RepleaceIconBySelect then
		UIUtil.SetIsVisible(self.PanelIcon, true)
		UIUtil.SetIsVisible(self.ImgIcon, not IsSelected)
		UIUtil.SetIsVisible(self.ImgIconSelect, IsSelected)
	elseif self.SelectShowType == SelectShowTypeDefine.ShowSelectFrameIconBySelect then
		UIUtil.SetIsVisible(self.PanelPattern, true)
	else
		FLOG_ERROR("UnDeinfe SelectShowTypeDefine Type")
	end
	
	local SelectedBGWidget = self.SelectShowType == SelectShowTypeDefine.RepleaceIconBySelect and self.ImgSelect or self.ImgPatternFrameSelect
	UIUtil.SetIsVisible(SelectedBGWidget, IsSelected)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgUnlock, IsSelected and LockStateIcon.Selected or LockStateIcon.Normal)
	
	-- if IsSelected then
	-- 	self:PlayAnimation(self.AnimCheck)
	-- else
	-- 	self:PlayAnimation(self.AnimUncheck)
	-- end
end

function CommVerIconTabItemView:InitTab(Params)
	if nil == Params then
		return
	end

	self.SelectShowType = Params.SelectShowType or self.SelectShowType
end

function CommVerIconTabItemView:UpdateItem(Data)
	if nil == Data then
		return
	end

	-- --系统解锁
	self.IsUnLock = _G.ModuleOpenMgr:CheckOpenState(Data.ModuleID) 

	---红点更新
	if Data.RedDotType ~= nil or Data.RedDotData ~= nil then
		self:UpdateRedDot(Data)
	end
end

function CommVerIconTabItemView:UpdateRedDot(Data)
	if Data == nil then
		Data = self.Params.Data
	end	
	local RedDotName = nil
	local IsStrongReminder = false
	if Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_PRODUCTION then
		RedDotName = _G.CraftingLogMgr:GetRedDotName(Data.ID)
		IsStrongReminder = _G.CraftingLogMgr:GetRedDotIsStrongReminder(RedDotName)
	elseif Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_COLLECTION then
		RedDotName = _G.GatheringLogMgr:GetRedDotName(Data.ID)
		IsStrongReminder = _G.GatheringLogMgr:GetRedDotIsStrongReminder(RedDotName)
	elseif Data.RedDotType == ProtoCS.NoteType.NOTE_TYPE_FISH then
		local Faction = _G.FishNotesMgr:GetFactionInfo(Data.ID)
		RedDotName = _G.FishNotesMgr:GetFishingholeRedDotName(Faction)
		IsStrongReminder = _G.GatheringLogMgr:GetRedDotIsStrongReminder(RedDotName)
	end
	
	local RedDotData = Data.RedDotData
	if RedDotData ~= nil then
		RedDotName = RedDotData.RedDotName or ""
		IsStrongReminder = RedDotData.IsStrongReminder == true
	end

	self.CommonRedDot:SetRedDotNameByString("")
	self.RedDot2:SetRedDotNameByString("")
	if RedDotName then
		if IsStrongReminder then --如果是强提醒
			self.CommonRedDot:SetRedDotNameByString(RedDotName)
		else
			self.RedDot2:SetRedDotNameByString(RedDotName)
		end	
	end
end

function CommVerIconTabItemView:OnIsPlayPointAniChanged()
	if nil == self.ViewModel then
		return
	end

	if self.ViewModel.IsPlayPointAni then
		self:PlayAnimation(self.AnimPointLoop, 0, 0)

	else
		self:StopAnimation(self.AnimPointLoop)
	end
end

return CommVerIconTabItemView