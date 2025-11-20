---
--- Author: mingyyzhang
--- DateTime: 2025-06-13 16:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseInfoSettingsPanelVM = require("Game/House/VM/HouseInfoSettingsPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MathUtil = require("Utils/MathUtil")

---@class HouseInfoSettingsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSave CommBtnLView
---@field Roommate1 HouseInviteFriendsItemView
---@field Roommate2 HouseInviteFriendsItemView
---@field Roommate3 HouseInviteFriendsItemView
---@field TableViewSettingsList UTableView
---@field TextHint UFTextBlock
---@field TextRoommate UFTextBlock
---@field TextSettings1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoSettingsPanelView = LuaClass(UIView, true)
local PrivilegeType = {
	[1] = ProtoCS.HousePrivilgeType.HousePrivilgeType_EditBasic,
	[2] = ProtoCS.HousePrivilgeType.HousePrivilgeType_ManagerVisit,
	[3] = ProtoCS.HousePrivilgeType.HousePrivilgeType_EditCover,
	[4] = ProtoCS.HousePrivilgeType.HousePrivilgeType_BuyLand,
	[5] = ProtoCS.HousePrivilgeType.HousePrivilgeType_EditDecorate,
	[6] = ProtoCS.HousePrivilgeType.HousePrivilgeType_ManagerMusical,
}
function HouseInfoSettingsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSave = nil
	--self.Roommate1 = nil
	--self.Roommate2 = nil
	--self.Roommate3 = nil
	--self.TableViewSettingsList = nil
	--self.TextHint = nil
	--self.TextRoommate = nil
	--self.TextSettings1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoSettingsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.Roommate1)
	self:AddSubView(self.Roommate2)
	self:AddSubView(self.Roommate3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoSettingsPanelView:OnInit()
	self.ViewModel = HouseInfoSettingsPanelVM.New()
	self.SettingsListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSettingsList)
	self.Binders = { { "IsInit", UIBinderValueChangedCallback.New(self, nil, self.OnInitCallback)} }
	self.TextRoommate:SetText(HouseLocalDef.RoommatesSettingInfoStr.RoommateTittle)
	self.TextSettings1:SetText(HouseLocalDef.RoommatesSettingInfoStr.PrivilegeTittle)
	self.TextHint:SetText(HouseLocalDef.RoommatesSettingInfoStr.HintText)
	self.BtnSave:SetBtnName(HouseLocalDef.HouseSaveStr)
	UIUtil.SetIsVisible(self.BtnSave, false)
	self.LastSelect = nil
end

function HouseInfoSettingsPanelView:OnDestroy()

end

function HouseInfoSettingsPanelView:OnShow()
	self.IsNotInit = false
	self.ViewModel.RoommatesList = table.deepcopy(_G.HouseInfoMgr.Roommates)
	if self.ViewModel.RoommatesList and #self.ViewModel.RoommatesList > 0 then       --初始化室友及室友权限
		UIUtil.SetIsVisible(self.TextHint, false)
		self.ViewModel:UpdateRoommates()
		self.SettingsListTableViewAdapter:UpdateAll(self.ViewModel.PrivilegeList[1])
		self:OnRoommateClicked(1)
	else
		self.SettingsListTableViewAdapter:UpdateAll({})
	end
	for i = 1,3 do
		if self.ViewModel.RoommatesList and i <= #self.ViewModel.RoommatesList then
			self["Roommate" .. i]:SetRoommate(i, self.ViewModel.RoommatesList[i].RoleID)
		else
			self["Roommate" .. i]:SetDefaultView(i)
		end
	end
end

function HouseInfoSettingsPanelView:OnHide()
	table.clear(self.ViewModel.PrivilegeList)
end

function HouseInfoSettingsPanelView:OnRegisterUIEvent()
	for i = 1, 3 do
		UIUtil.AddOnClickedEvent(self, self["Roommate" .. i].BtnFrame, self.OnRoommateClicked, i)
	end
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnSavePrivilege)
end

function HouseInfoSettingsPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseChangeRoommatePrivilege, self.OnHouseChangeRoommatePrivilege)
	self:RegisterGameEvent(_G.EventID.HouseRemoveRoommate, self.OnShareHouseBeRemoved) --移除室友
	self:RegisterGameEvent(_G.EventID.HouseBeDissolveRoomNtf, self.OnShareHouseBeRemoved) --室友解除共享
	self:RegisterGameEvent(_G.EventID.HouseRoleInfoUpdate, self.OnShow) --室友同意邀请
	
end

function HouseInfoSettingsPanelView:OnRegisterBinder()

end

function HouseInfoSettingsPanelView:OnRoommateClicked(Index)       --室友页签点击逻辑
	self.ViewModel.CurrentRoommate = Index
	local SelectRoommate = self["Roommate" .. Index]
	if SelectRoommate == self.LastSelect then
		return
	end
	if Index <= #self.ViewModel.PrivilegeList then  
		UIUtil.SetIsVisible(self.BtnSave, true, true)
		UIUtil.SetIsVisible(self.TextHint, false)
	else
		UIUtil.SetIsVisible(self.TextHint, true)
		UIUtil.SetIsVisible(self.BtnSave, false)
	end
	if self.ViewModel.PrivilegeList[Index] and #self.ViewModel.PrivilegeList[Index] > 0 then     
		UIUtil.SetIsVisible(self.SettingsListTableViewAdapter, true)
		self.SettingsListTableViewAdapter:UpdateAll(self.ViewModel.PrivilegeList[Index])
	else
		UIUtil.SetIsVisible(self.SettingsListTableViewAdapter, false)
	end
	if self.LastSelect then
		UIUtil.SetIsVisible(self.LastSelect.ImgSelect, false)
		UIUtil.SetIsVisible(self.LastSelect.IconArrow, false)
	end
	UIUtil.SetIsVisible(SelectRoommate.ImgSelect, true)
	UIUtil.SetIsVisible(SelectRoommate.IconArrow, true)
	self.LastSelect = SelectRoommate
	--if self.IsNotInit == false then
	--	UIUtil.SetIsVisible(self.SettingsListTableViewAdapter, true)
	--	self.IsNotInit = true
	--end

	self:PlayAnimation(self.AnimSelect)
	SelectRoommate:PlayAnimation(SelectRoommate.AnimSelect)
end

function HouseInfoSettingsPanelView:OnSavePrivilege()            --保存权限
	local RemovePrivileges = {}
	local AddPrivileges = {}
	for i = 1, #self.ViewModel.PrivilegeList[self.LastSelect.Index] do    --获取应该被勾选的Item
		if  self.ViewModel.PrivilegeList[self.LastSelect.Index][i].Selected == true then
			if self.ViewModel.OriginPrivilegeList[self.LastSelect.Index][i].Selected == false then
				table.insert(AddPrivileges, PrivilegeType[self.ViewModel.OriginPrivilegeList[self.LastSelect.Index][i].Index])
			end
			self.ViewModel.OriginPrivilegeList[self.LastSelect.Index][i].Selected = true
		else
			if self.ViewModel.OriginPrivilegeList[self.LastSelect.Index][i].Selected == true then
				table.insert(RemovePrivileges, PrivilegeType[self.ViewModel.OriginPrivilegeList[self.LastSelect.Index][i].Index])
			end
			self.ViewModel.OriginPrivilegeList[self.LastSelect.Index][i].Selected = false
		end
	end
	_G.HouseInfoMgr:SendChangeRoommatePrivilege(_G.HouseInfoMgr.MajorHouseID, self.LastSelect.RoleID, RemovePrivileges, AddPrivileges)
end

function HouseInfoSettingsPanelView:OnHouseChangeRoommatePrivilege(MsgBody)
	if MsgBody and MsgBody.HouseID == _G.HouseInfoMgr.MajorHouseID then
		MsgTipsUtil.ShowTips(HouseLocalDef.HouseSaveSuc)
		--for i = 1, #self.ViewModel.PrivilegeList do
		--	if self.ViewModel.RoommatesList[i].RoleID == MsgBody.RoommateID then
		--		local Privileges = MathUtil.DecodeUint(MsgBody.Privileges)
		--		if self.ViewModel.PrivilegeList[i] == Privileges then
		--			MsgTipsUtil.ShowTips(HouseLocalDef.HouseSaveSuc)
		--		end
		--	end
		--end
	end
end

function HouseInfoSettingsPanelView:OnShareHouseBeRemoved(MsgBody)
	if MsgBody and MsgBody.HouseID == _G.HouseInfoMgr.MajorHouseID then
		for i = 1, #self.ViewModel.RoommatesList do
			if self.ViewModel.RoommatesList[i].RoleID == MsgBody.RoommateID	then
				table.remove(self.ViewModel.RoommatesList, i)
				table.remove(self.ViewModel.PrivilegeList, i)
				table.remove(_G.HouseInfoMgr.Roommates, i)
				break
			end
		end
		self:OnShow()
	end
end


return HouseInfoSettingsPanelView