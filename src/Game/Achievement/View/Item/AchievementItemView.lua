---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:12
--- Description:
---


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderCanvasSlotSetScale = require("Binder/UIBinderCanvasSlotSetScale")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local AchievementMainPanelVM = require("Game/Achievement/VM/AchievementMainPanelVM")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")

local EToggleButtonState = _G.UE.EToggleButtonState
local AchievementMgr = _G.AchievementMgr

local LSTR =  _G.LSTR

---@class AchievementItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AchievementSlot AchievementSlotItemView
---@field Btn UFButton
---@field BtnGetReward CommBtnSView
---@field BtnRequestDetail UFButton
---@field ImgFinishBg UFImage
---@field ImgLevel UFImage
---@field PanelDone UFCanvasPanel
---@field PanelGet UFCanvasPanel
---@field PanelTracked UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RichTextProcess URichTextBox
---@field TableViewRewards UTableView
---@field TextContent UFTextBlock
---@field TextDate1 UFTextBlock
---@field TextDate2 UFTextBlock
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field TextReach UFTextBlock
---@field ToggleBtnFavor UToggleButton
---@field ToggleBtnMore UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimTracked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AchievementItemView = LuaClass(UIView, true)

function AchievementItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AchievementSlot = nil
	--self.Btn = nil
	--self.BtnGetReward = nil
	--self.BtnRequestDetail = nil
	--self.ImgFinishBg = nil
	--self.ImgLevel = nil
	--self.PanelDone = nil
	--self.PanelGet = nil
	--self.PanelTracked = nil
	--self.RedDot = nil
	--self.RichTextProcess = nil
	--self.TableViewRewards = nil
	--self.TextContent = nil
	--self.TextDate1 = nil
	--self.TextDate2 = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextReach = nil
	--self.ToggleBtnFavor = nil
	--self.ToggleBtnMore = nil
	--self.AnimIn = nil
	--self.AnimTracked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AchievementItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AchievementSlot)
	self:AddSubView(self.BtnGetReward)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AchievementItemView:OnInit()
	UIUtil.SetIsVisible(self.Btn, false)
	self.AdapterTableViewRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewRewards, self.OnSelectChangedTableViewReward, true)
	if self.Binders == nil then
		self.Binders = {
			{ "TableViewRewardsList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewRewards) },
			{ "ViewScale", UIBinderCanvasSlotSetScale.New(self, self ) },
			{ "TextName", UIBinderSetText.New(self, self.TextName) },
			{ "ToggleBtnFavorState", UIBinderSetCheckedState.New(self, self.ToggleBtnFavor) },
			{ "TextContent", UIBinderSetText.New(self, self.TextContent) },
			{ "ID", UIBinderValueChangedCallback.New(self, nil, self.AchievementIDChanged) },
			{ "BtnRequestDetailVisible", UIBinderSetIsVisible.New(self, self.BtnRequestDetail, false , true) },
			{ "BtnRequestDetailVisible", UIBinderSetIsVisible.New(self, self.RedDot ) },
			{ "TrackedVisible", UIBinderValueChangedCallback.New(self, nil, self.OnTrackedVisibleChanged) },
			{ "AchievePoint", UIBinderSetTextFormat.New(self, self.TextLevel, "%d" ) },
			{ "ImgLevelPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgLevel) },
			{ "TableViewRewardsVisible", UIBinderSetIsVisible.New(self, self.TableViewRewards) },
			{ "PanelGetVisible", UIBinderSetIsVisible.New(self, self.PanelGet) },
			{ "RichTextProcessVisible", UIBinderSetIsVisible.New(self, self.RichTextProcess) },
			{ "PanelDoneVisible", UIBinderSetIsVisible.New(self, self.PanelDone) },
			{ "RichTextProcessText", UIBinderSetText.New(self, self.RichTextProcess) },
			{ "TextDate", UIBinderSetText.New(self, self.TextDate1) },
			{ "TextDate", UIBinderSetText.New(self, self.TextDate2) },
		}
	end
end

function AchievementItemView:OnDestroy()

end

function AchievementItemView:OnShow()
	self.TextReach:SetText( LSTR(720023))
	self.BtnGetReward:SetText( LSTR(10021))
end

function AchievementItemView:OnHide()
	self:SetRenderScale(_G.UE.FVector2D(1, 1))
	self.TextContent:SetText("")
	self.AdapterTableViewRewards:ReleaseAllItem()
	self.TableViewRewards:ClearTableItems()
end

function AchievementItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMore, self.OnToggleBtnMoreClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnFavor, self.OnToggleBtnFavorClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGetReward, self.OnBtnGetRewardClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRequestDetail, self.OnBtnRequestDetailClicked)
	UIUtil.AddOnTextBlockClippedEvent(self, self.TextContent, self.OnTextBlockClipped)
end

function AchievementItemView:OnRegisterGameEvent()

end

function AchievementItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function AchievementItemView:OnSelectChangedTableViewReward(Index, ItemData, ItemView)
	if ItemData.RewardType == 2 then 
		local Gender = MajorUtil.GetMajorGender()
		local Content = string.format( _G.LSTR(720013), _G.TitleMgr:GetDecoratedTitleText(ItemData.ResID, Gender ))
		local ItemSize = UIUtil.GetLocalSize(ItemView)
		local View = TipsUtil.ShowInfoTips( Content, ItemView, _G.UE.FVector2D(-(ItemSize.X/2.0)-20, -(ItemSize.Y/2.0)), _G.UE.FVector2D(0.5, 0.5), false)
		AchievementMainPanelVM:SetExendView(View)
	else
		local View = ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0,Y = 0}, nil)
		AchievementMainPanelVM:SetExendView(View)
	end
end

function AchievementItemView:OnToggleBtnMoreClicked()
	if not CommonUtil.IsObjectValid(self) then
		return
	end
	if self.ToggleBtnMore:GetIsChecked() then
		self.ToggleBtnMore:SetCheckedState(EToggleButtonState.Checked)
		local ToggleBtnMore = self.ToggleBtnMore
		local ClickedParams = { View = self, 
		HidePopUpBGCallback =  function() 
			if not CommonUtil.IsObjectValid(self) then 
				return
			end
			self.ToggleBtnMore:SetCheckedState(EToggleButtonState.Unchecked)
		end }
		local ToggleBtnMoreSize = UIUtil.GetWidgetSize(self.ToggleBtnMore)
		local ViewModel = self.ViewModel
		if ViewModel ~= nil then
			TipsUtil.ShowInfoTips(ViewModel.TextContent, self.ToggleBtnMore, _G.UE.FVector2D( - ToggleBtnMoreSize.X, ToggleBtnMoreSize.Y ), _G.UE.FVector2D(1, 1), false,  ClickedParams )
		end
	else
		self.ToggleBtnMore:SetCheckedState(EToggleButtonState.Unchecked)
	end
end

function AchievementItemView:OnBtnRequestDetailClicked()
	local ViewModel = self.ViewModel
	if ViewModel ~= nil then
		if (ViewModel.GroupID or 0) ~= 0 then 
			local Params = { AchievemwntGroupID = ViewModel.GroupID } 
			_G.UIViewMgr:ShowView(UIViewID.AchievementDetailWin, Params)
		end
	end
end

function AchievementItemView:OnToggleBtnFavorClicked()
	local ViewModel = self.ViewModel
	if ViewModel ~= nil then
		local AchieveIDs = { ViewModel.ID }
		self.ToggleBtnFavor:SetCheckedState( ViewModel.ToggleBtnFavorState) 
		if ViewModel.ToggleBtnFavorState == EToggleButtonState.Unchecked then
			AchievementMgr:CollectAchievement(true, AchieveIDs)
		else
			AchievementMgr:CollectAchievement(false, AchieveIDs)
		end
	end
end

function AchievementItemView:OnBtnGetRewardClicked()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	AchievementMgr:GetAchievementReward({ ViewModel.ID })
end


function AchievementItemView:OnTrackedVisibleChanged(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimTracked)
	else
		UIUtil.SetIsVisible(self.PanelTracked, false)
	end
end


function AchievementItemView:AchievementIDChanged(NewValue)
	self.AchievementSlot:SetAchievementID(NewValue)

	local ViewModel = self.ViewModel
	if ViewModel ~= nil then
		self.RedDot:SetRedDotNameByString("")
		if (ViewModel.GroupID or 0) ~= 0 then
			self.RedDot:SetRedDotNameByString(AchievementMgr:GetGroupIDRedDotName(ViewModel.GroupID))
		end
	end
end

function AchievementItemView:OnTextBlockClipped(_, IsClipped)
	UIUtil.SetIsVisible(self.ToggleBtnMore, IsClipped, true)
	if IsClipped then
		self.ToggleBtnMore:SetCheckedState(EToggleButtonState.Unchecked)
	end
end

return AchievementItemView