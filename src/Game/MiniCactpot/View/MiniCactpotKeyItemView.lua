---
--- Author: chriswang
--- DateTime: 2022-09-23 14:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local MiniCactpotMainVM = require("Game/MiniCactpot/MiniCactpotMainVM")
local MiniCactpotDefine = require("Game/MiniCactpot/MiniCactpotDefine")

---@class MiniCactpotKeyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Default UFCanvasPanel
---@field EFF UFCanvasPanel
---@field FButton_Open UFButton
---@field FCanvasPanel_DX UFCanvasPanel
---@field FImg_Check UFImage
---@field FImg_KeySelected UFImage
---@field Icon_NumbBanned UFImage
---@field Icon_NumbDefault UFImage
---@field Icon_NumbSelected UFImage
---@field Selected UFCanvasPanel
---@field Toggle_Button_Check UToggleButton
---@field AnimCheckIn UWidgetAnimation
---@field AnimCheckOut UWidgetAnimation
---@field AnimDefaultToGray UWidgetAnimation
---@field AnimDefaultToNormal UWidgetAnimation
---@field AnimOpen UWidgetAnimation
---@field AnimSelectedIn UWidgetAnimation
---@field AnimSelectedLoop UWidgetAnimation
---@field AnimSelectedOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiniCactpotKeyItemView = LuaClass(UIView, true)

function MiniCactpotKeyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Default = nil
	--self.EFF = nil
	--self.FButton_Open = nil
	--self.FCanvasPanel_DX = nil
	--self.FImg_Check = nil
	--self.FImg_KeySelected = nil
	--self.Icon_NumbBanned = nil
	--self.Icon_NumbDefault = nil
	--self.Icon_NumbSelected = nil
	--self.Selected = nil
	--self.Toggle_Button_Check = nil
	--self.AnimCheckIn = nil
	--self.AnimCheckOut = nil
	--self.AnimDefaultToGray = nil
	--self.AnimDefaultToNormal = nil
	--self.AnimOpen = nil
	--self.AnimSelectedIn = nil
	--self.AnimSelectedLoop = nil
	--self.AnimSelectedOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiniCactpotKeyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiniCactpotKeyItemView:OnInit()

end

function MiniCactpotKeyItemView:OnDestroy()

end

function MiniCactpotKeyItemView:OnShow()
	if nil == self.Params then return end

	local Data = self.Params.Data
	if nil == Data then return end
end

function MiniCactpotKeyItemView:OnHide()
	self:PlayAnimation(self.AnimSelectedOut)
end

function MiniCactpotKeyItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_Open, self.OnOpenBtnClick, nil)
	
end

function MiniCactpotKeyItemView:OnRegisterGameEvent()

end


function MiniCactpotKeyItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "SetCellState", UIBinderValueChangedCallback.New(self, nil, self.OnSetCellState) },
		{ "CellIsChecked", UIBinderValueChangedCallback.New(self, nil, self.OnSetCheckState) },

		-- { "Text", UIBinderSetText.New(self, self.RichText_Filter) },
		{ "NumberIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon_NumbBanned) },
		{ "NumberIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon_NumbDefault) },
		{ "NumberIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon_NumbSelected) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function MiniCactpotKeyItemView:OnSetCellState(CellState)
	-- FLOG_INFO("Cell idx:%d State:%d", self.ViewModel.Index, CellState)
	local Path = MiniCactpotDefine.Path
	if MiniCactpotMainVM.CellState.Masked == CellState then
		self:PlayAnimation(self.AnimOpen, 0.6, 1, _G.UE.EUMGSequencePlayMode.Reverse, 99)
		self.FCanvasPanel_DX:SetRenderOpacity(1)
		UIUtil.SetIsVisible(self.Toggle_Button_Check, false)
		self:StopAnimation(self.AnimSelectedLoop)
		UIUtil.SetIsVisible(self.Selected, false)
		UIUtil.SetIsVisible(self.EFF, false)
		print("MiniCactpotMainVM.CellState.Masked")
	elseif MiniCactpotMainVM.CellState.Opend == CellState then
		self:PlayAnimation(self.AnimOpen, 0)
		UIUtil.SetIsVisible(self.Selected, false)
		UIUtil.SetIsVisible(self.EFF, false)
		print("MiniCactpotMainVM.CellState.Opend")
	elseif MiniCactpotMainVM.CellState.UnSelect == CellState then
		self:StopAnimation(self.AnimSelectedIn)
		self:StopAnimation(self.AnimSelectedLoop)

		self:PlayAnimation(self.AnimSelectedOut)

		UIUtil.SetIsVisible(self.EFF, false)
		UIUtil.SetIsVisible(self.Selected, false)
	elseif MiniCactpotMainVM.CellState.Select.MiddleAward == CellState then
		self:EnterSelectState()
		UIUtil.ImageSetBrushFromAssetPath(self.FImg_KeySelected, Path.MiddleAward)
	elseif MiniCactpotMainVM.CellState.Select.MaxAward == CellState then
		self:EnterSelectState()
		UIUtil.ImageSetBrushFromAssetPath(self.FImg_KeySelected, Path.MaxAward)
	elseif MiniCactpotMainVM.CellState.Select.OtherAward == CellState then
		self:EnterSelectState()
		UIUtil.ImageSetBrushFromAssetPath(self.FImg_KeySelected, Path.OtherAward)
	end
end

function MiniCactpotKeyItemView:EnterSelectState()
	UIUtil.SetIsVisible(self.Selected, true)
	UIUtil.SetIsVisible(self.EFF, true)
	self:PlayAnimation(self.AnimSelectedIn)
	self:PlayAnimation(self.AnimSelectedLoop, 0, 0)
end

function MiniCactpotKeyItemView:OnSetCheckState(IsChecked)
	if IsChecked then
		UIUtil.SetIsVisible(self.Toggle_Button_Check, true)
		self:PlayAnimation(self.AnimCheckIn)
	else
		UIUtil.SetIsVisible(self.Toggle_Button_Check, false)
		-- self:PlayAnimation(self.AnimCheckOut)
	end
end

function MiniCactpotKeyItemView:OnOpenBtnClick()
	if self.ParentView.ParentView.bInAnimIn then
		return
	end

	_G.MiniCactpotMgr:SendClickCellReq(self.ViewModel.Index)
end

return MiniCactpotKeyItemView