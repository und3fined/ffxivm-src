---
--- Author: HugoWong
--- DateTime: 2023-11-06 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")

local CompanionCallingSettingVM = require("Game/Companion/VM/CompanionCallingSettingVM")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local CompanionMgr = _G.CompanionMgr
local EToggleButtonState = _G.UE.EToggleButtonState
local EventID = _G.EventID
local MsgTipsUtil = _G.MsgTipsUtil
local LSTR = _G.LSTR
local COMPANION_AUTO = ProtoCS.CompanionAuto

---@class CompanionCallingSettingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewSetting UTableView
---@field TextTitle UFTextBlock
---@field ToggleButtonOnlineAutoCalling UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionCallingSettingPanelView = LuaClass(UIView, true)

function CompanionCallingSettingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewSetting = nil
	--self.TextTitle = nil
	--self.ToggleButtonOnlineAutoCalling = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionCallingSettingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionCallingSettingPanelView:OnInit()
	self.ViewModel = CompanionCallingSettingVM.New()

	self.SettingAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSetting, self.OnSettingTableViewSelectChange, false)
	
	self.Binders = {
		{
			ViewModel = self.ViewModel,
			Binders = {
				{ "SettingItemVM", UIBinderUpdateBindableList.New(self, self.SettingAdapterTableView) },
			}
		},
		{
			ViewModel = CompanionVM,
			Binders = {
				{ "OnlineAutoCalling", UIBinderSetIsChecked.New(self, self.ToggleButtonOnlineAutoCalling) },
				{ "OnlineAutoCallingType", UIBinderValueChangedCallback.New(self, nil, self.OnOnlineAutoCallingTypeChange)},
			}
		},
	}
end

function CompanionCallingSettingPanelView:OnDestroy()

end

function CompanionCallingSettingPanelView:OnShow()
	self:SetFixText()
end

function CompanionCallingSettingPanelView:OnHide()
	self.ViewModel.SettingItemVM = nil
	self.SettingAdapterTableView:ClearSelectedItem()
end

function CompanionCallingSettingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonOnlineAutoCalling, self.OnToggleOnlineAutoCallingClicked)
end

function CompanionCallingSettingPanelView:OnRegisterGameEvent()
	
end

function CompanionCallingSettingPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.Binders)
end

-- 手动选择选项刷新UI
function CompanionCallingSettingPanelView:OnSettingTableViewSelectChange(Index, ItemData, ItemView)
	if ItemData == nil then return end

	local OldType = CompanionVM:GetOnlineAutoCallingType()
	local NewType = ItemData.Index
	local CanSendMsg = NewType ~= OldType

	-- 设置选项
	self.ViewModel:SelectCallingType(NewType)

	-- 如果玩家没有设置偏好宠物，则把选项还原
	if NewType == COMPANION_AUTO.CompanionAutoLike then
		if CompanionVM:HasCompanionFavourite() == false then
			self.SettingAdapterTableView:SetSelectedIndex(OldType)
			MsgTipsUtil.ShowTips(LSTR(120012))
			CanSendMsg = false
		end
	end

	if CanSendMsg then
		CompanionMgr:SetOnlineAutoCallingType(NewType)
	end
end

function CompanionCallingSettingPanelView:OnOnlineAutoCallingTypeChange(NewValue, OldValue)
	if OldValue == nil and NewValue == nil then return end

	-- Type为None时SetSelectedIndex会失败，所以在这刷新一下UI
	local CallingType = CompanionVM:GetOnlineAutoCallingType()
	self.ViewModel:SelectCallingType(CallingType)

	if CompanionVM:GetOnlineAutoCalling() == true then
		self.SettingAdapterTableView:SetSelectedIndex(CallingType)
	else
		-- 取消自动召唤时锁定选项不让点击
		self.ViewModel:SetItemsClickable(false)
		self.SettingAdapterTableView:ClearSelectedItem()
	end
end

function CompanionCallingSettingPanelView:OnToggleOnlineAutoCallingClicked(ToggleButton, ButtonState)
	local OldState = CompanionVM:GetOnlineAutoCalling()
	local NewState = ButtonState == EToggleButtonState.Checked

	-- 设置数据
	CompanionVM:SetOnlineAutoCalling(NewState)

	-- 发送协议
	if NewState == false then
		CompanionMgr:SetOnlineAutoCallingType(COMPANION_AUTO.CompanionAutoNone)
	else
		CompanionMgr:SetOnlineAutoCallingType(COMPANION_AUTO.CompanionAutoLast)
	end

	-- 设回原本数据，等协议回包再实际更新数据和UI，以防数据和UI不一致
	CompanionVM:SetOnlineAutoCalling(OldState)
end

function CompanionCallingSettingPanelView:SetFixText()
	self.TextTitle:SetText(LSTR(120023))
end

return CompanionCallingSettingPanelView