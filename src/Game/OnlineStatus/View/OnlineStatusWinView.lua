---
--- Author: loiafeng
--- DateTime: 2023-03-28 09:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GuideGlobalCfg = require("TableCfg/GuideGlobalCfg")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local OnlineStatusDefine = require("Game/OnlineStatus/OnlineStatusDefine")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")

local ProtoRes = require("Protocol/ProtoRes")
local SettingsVM = _G.OnlineStatusSettingsVM
local LSTR = _G.LSTR

---@class OnlineStatusWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnRefresh CommBtnLView
---@field Icon UFImage
---@field ImgStatus UFImage
---@field PanelExpirationTime UFHorizontalBox
---@field TableViewStatusList UTableView
---@field TextCurrent UFTextBlock
---@field TextExpirationTime UFTextBlock
---@field TextStatus UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OnlineStatusWinView = LuaClass(UIView, true)

function OnlineStatusWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnRefresh = nil
	--self.Icon = nil
	--self.ImgStatus = nil
	--self.PanelExpirationTime = nil
	--self.TableViewStatusList = nil
	--self.TextCurrent = nil
	--self.TextExpirationTime = nil
	--self.TextStatus = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OnlineStatusWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnRefresh)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OnlineStatusWinView:OnInit()
	self.AdapterSettingsItemTable = UIAdapterTableView.CreateAdapter(self, self.TableViewStatusList, self.OnSelectSettingsItem)
	self.Binders = {
		{ "SettingsItemList", UIBinderUpdateBindableList.New(self, self.AdapterSettingsItemTable) },
		{ "CurrName", UIBinderSetText.New(self, self.TextStatus) },
		{ "CurrIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgStatus) },
		{ "SelectedItemVM", UIBinderSetSelectedItem.New(self, self.AdapterSettingsItemTable) },
	}
	self.TextTimeLimit = (GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideRedFlowerGuideIdentifyEndTime, "Value") or {})[1] or "0"
end

function OnlineStatusWinView:OnDestroy()

end

function OnlineStatusWinView:OnShow()
	self.TextCurrent:SetText(LSTR(OnlineStatusDefine.NotifyText.CurStatusText))
	self.BtnRefresh:SetText(LSTR(OnlineStatusDefine.NotifyText.Refresh))
	self.TextExpirationTime:SetText( TimeUtil.GetTimeFormat(LSTR(OnlineStatusDefine.NotifyText.DisappearTime) , tonumber(self.TextTimeLimit)))
	self.BG:SetTitleText(LSTR(OnlineStatusDefine.NotifyText.OnlineStatusTitle))
	-- 锁定确认按钮
	self.BtnRefresh:SetIsEnabled(false)
end

function OnlineStatusWinView:OnHide()
end

function OnlineStatusWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnConfirm)
end

function OnlineStatusWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamInTeamChanged, self.OnGameEventTeamInTeamChanged)
end

function OnlineStatusWinView:OnGameEventTeamInTeamChanged(InTeam)
	if InTeam and SettingsVM then
		SettingsVM:Update()
	end
end

function OnlineStatusWinView:OnRegisterBinder()
	self:RegisterBinders(SettingsVM, self.Binders)
	
	if nil == self.RoleVMBinders then
		self.RoleVMBinders = {
			{ "OnlineStatusCustomID", UIBinderValueChangedCallback.New(SettingsVM, nil, SettingsVM.Update) },
			{ "OnlineStatus", UIBinderValueChangedCallback.New(self, nil, self.OnStatusChanged) },
			{ "Identity", UIBinderValueChangedCallback.New(SettingsVM, nil, SettingsVM.Update) },
		}
	end
	local RoleVM = MajorUtil.GetMajorRoleVM()
	self:RegisterBinders(RoleVM, self.RoleVMBinders)

	-- 自动选中一次当前状态
	SettingsVM:SelectedCurrStatusItem()
end

function OnlineStatusWinView:OnConfirm()
	local ItemVM = SettingsVM.SelectedItemVM

	if nil == ItemVM then
		_G.FLOG_ERROR("OnlineStatusWinView.OnConfirm: Do not selected valid ItemVM.")
		return
	end

	-- 对于指导者状态，需要特殊处理
	if OnlineStatusDefine.MentorIdentitys[ItemVM.IdentityID] then
		local TipsUIView = _G.UIViewMgr:ShowView(_G.UIViewID.OnlineStatusSettingsTips)
		TipsUIView:SetParams({StatusID = ItemVM.StatusID})
	else
		_G.OnlineStatusMgr:SetCustomStatus(ItemVM.StatusID, true)
		--_G.MsgTipsUtil.ShowTips(OnlineStatusDefine.NotifyText.StatusChanged)
		--_G.UIViewMgr:HideViewByUILayer(UILayer.Normal | UILayer.AboveNormal)
		-- _G.UIViewMgr:HideView(_G.UIViewID.OnlineStatusSettingsPanel)
	end
end

function OnlineStatusWinView:OnSelectSettingsItem(Index, VM, ItemView)
	-- 滚动到选中的Item
	self.AdapterSettingsItemTable:ScrollIndexIntoView(Index)
	local SelectStatus = ((VM or {}).StatusID) or 0
	UIUtil.SetIsVisible( self.PanelExpirationTime, SelectStatus == ProtoRes.OnlineStatus.OnlineStatusRedFlowerMentor)
	-- 判断是否为VM同步的选中效果
	if SettingsVM.SelectedItemVM == VM then
		return
	end
	-- 解锁确定按钮
	self.BtnRefresh:SetIsEnabled(SettingsVM.CurrStatus ~= SelectStatus)
	-- 模拟Button的音效
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")
	SettingsVM:SetSelectedItemVM(VM)
end

-- 状态发生变化，需要更新选中
function OnlineStatusWinView:OnStatusChanged(NewStatus, OldStatus)
	if OldStatus and OnlineStatusUtil.CheckBit(
	OnlineStatusUtil.GetDiff(NewStatus, OldStatus), ProtoRes.OnlineStatus.OnlineStatusLeave) then
		-- 如果离开状态有变化，需要更新设置按钮
		SettingsVM:Update(false)
		self.BtnRefresh:SetIsEnabled(true)
	end
	SettingsVM:Update()
end

return OnlineStatusWinView