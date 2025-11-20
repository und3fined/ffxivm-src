---
--- Author: muyanli
--- DateTime: 2025-06-06 11:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseInfoMgr = require("Game/House/HouseInfoMgr")
local EventID = require("Define/EventID")

---@class HouseMineMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field HouseMineBG_UIBP HouseMineBGView
---@field InfoPanel HouseInfoPanelView
---@field InvitePanel HouseInfoInvitePanelView
---@field RoomAllPanel HouseInfoRoomAllPanelView
---@field SettingsPanel HouseInfoSettingsPanelView
---@field SharingpermissionsPanel HouseSharingpermissionsPanelView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseMineMainPanelView = LuaClass(UIView, true)

function HouseMineMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.HouseMineBG_UIBP = nil
	--self.InfoPanel = nil
	--self.InvitePanel = nil
	--self.RoomAllPanel = nil
	--self.SettingsPanel = nil
	--self.SharingpermissionsPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseMineMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.HouseMineBG_UIBP)
	self:AddSubView(self.InfoPanel)
	self:AddSubView(self.InvitePanel)
	self:AddSubView(self.RoomAllPanel)
	self:AddSubView(self.SettingsPanel)
	self:AddSubView(self.SharingpermissionsPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseMineMainPanelView:OnInit()
	self.ViewModel = _G.HouseMineMainPanelVM
	self.Binders = {
		{"HouseMineBG_UIBPVisibility", UIBinderSetIsVisible.New(self, self.HouseMineBG_UIBP)},
		{"InfoPanelVisibility", UIBinderSetIsVisible.New(self, self.InfoPanel)},
		{"InvitePanelVisibility", UIBinderSetIsVisible.New(self, self.InvitePanel)},
		{"RoomAllPanelVisibility", UIBinderSetIsVisible.New(self, self.RoomAllPanel)},
		{"SettingsPanelVisibility", UIBinderSetIsVisible.New(self, self.SettingsPanel)},
		{"SharingpermissionsPanelVisibility", UIBinderSetIsVisible.New(self, self.SharingpermissionsPanel)},
		{"CommEmptyVisibility", UIBinderSetIsVisible.New(self, self.CommEmpty)},
		{ "CommEmptyVisibility", UIBinderValueChangedCallback.New(self, nil, self.OnEmptyPanelChangedCallback)}
	}
	UIUtil.SetIsVisible(self.HouseMineBG_UIBP.CommTab, false)
	UIUtil.SetIsVisible(self.HouseMineBG_UIBP.PanelServerTag, false)
	self.HouseMineBG_UIBP:SetTitleInfo(HouseLocalDef.MajorHouseInfoTitle)
end

function HouseMineMainPanelView:OnDestroy()

end

function HouseMineMainPanelView:OnShow()
	self:UpdateView()
	self:UpdateTabList()
end

function HouseMineMainPanelView:OnHide()
	self.ViewModel.PageNum = 0
	self.ViewModel.Key = nil
	self.ViewModel.SubIndex = 1
	self.ViewModel.LastPageNum = nil
	self.ViewModel.IsMajorHouse = 0
	self.ViewModel.CurrentView = nil
	self.ViewModel.IsHasRoommate = false
	self.ViewModel.HouseMineBG_UIBPVisibility = true
	self.ViewModel.InfoPanelVisibility = false
	self.ViewModel.InvitePanelVisibility = false
	self.ViewModel.RoomAllPanelVisibility = false
	self.ViewModel.SettingsPanelVisibility = false
end

function HouseMineMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.HouseMineBG_UIBP.HouseTab, self.OnSelectionChangedHouseTab)
	UIUtil.AddOnClickedEvent(self, self.CommEmpty.Btn, self.OnClickEmptyBtn)
end

function HouseMineMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseShareUpdate, self.OnShareHouseBeRemoved) --被房主解除室友关系
	self:RegisterGameEvent(_G.EventID.HouseDissolveRoom, self.OnShareHouseBeRemoved)   --与房主解除共享
	self:RegisterGameEvent(_G.EventID.HouseInviteReplyRsp, self.OnShareHouseBeRemoved) 
	self:RegisterGameEvent(_G.EventID.ArmyLevelUpdate, self.OnArmyLevelUp)   --部队等级提升
	self:RegisterGameEvent(_G.EventID.HouseDestroyNotify, self.OnDestroyHouse)
	self:RegisterGameEvent(_G.EventID.HouseAbandonLand, self.OnAbandonLand)
	self:RegisterGameEvent(_G.EventID.HousePullMajorMemberRoom, self.OnHouseMajorMemberInfoUpdate)
	self:RegisterGameEvent(_G.EventID.HousePullArmyMemberRoom, self.OnPullArmyMemberRoom)
	self:RegisterGameEvent(_G.EventID.ArmyExit, self.OnExitArmy)
end

function HouseMineMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseMineMainPanelView:UpdateView()
	self.ViewModel:ChangePage()
end

function HouseMineMainPanelView:OnSelectionChangedHouseTab(Index, ItemData, ItemView, MainKey, SubKey)
	self:RefreshMineBgLocation(MainKey)
	local Key = ItemData.Key
	if ItemData.Key <= 3 then
		return
	end
	local NewPage = self.ViewModel:GetPageNumBySubItemKey(Key)
	if NewPage == -1 then
		return
	end
	self.ViewModel.LastPageNum = self.ViewModel.PageNum
	if self.ViewModel.LastPageNum == NewPage then
		return 
	end
	self.ViewModel.PageNum = NewPage
	self.ViewModel:ChangePage()
	if HouseInfoMgr.SharedHouseID > 0 then
		if NewPage == 0 or NewPage == 2 or NewPage == 3 or NewPage == 5 then
			if self.ViewModel.LastPageNum == 0 or self.ViewModel.LastPageNum == 2 or self.ViewModel.LastPageNum == 3 or self.ViewModel.LastPageNum == 5 then
				self.InfoPanel:OnShow()   --刷新Info界面
			end
		end
	else
		if NewPage == 0 or NewPage == 2 or NewPage == 3 then
			if self.ViewModel.LastPageNum == 0 or self.ViewModel.LastPageNum == 2 or self.ViewModel.LastPageNum == 3 then
				self.InfoPanel:OnShow()   --刷新Info界面
			end
		end
	end
end

function HouseMineMainPanelView:RefreshMineBgLocation(MainKey)
	if not MainKey then return end
	if MainKey == 1 and HouseInfoMgr.MajorHouseID ~= 0 and next(HouseInfoMgr.MajorHouseInfo)  then --- 我的房屋
		local HouseDetail = HouseInfoMgr.MajorHouseInfo.PersonalHouse
		local Basic = HouseDetail.Basic
		_G.EventMgr:SendEvent(EventID.HouseMineBGLocationAni, Basic.Addr)
	elseif MainKey == 2 and HouseInfoMgr.ArmyHouseID ~= 0 and next(HouseInfoMgr.MajorArmyHouseInfo) then
		local HouseDetail = HouseInfoMgr.MajorArmyHouseInfo.HouseDetail
		local Basic = HouseDetail.Basic
		_G.EventMgr:SendEvent(EventID.HouseMineBGLocationAni, Basic.Addr)
	elseif MainKey == 3 and HouseInfoMgr.SharedHouseID ~= 0 then
		HouseInfoMgr:QueryHouseDetail(HouseInfoMgr.SharedHouseID, function(Basic, Roommates)
			_G.EventMgr:SendEvent(EventID.HouseMineBGLocationAni, Basic.Addr)
        end)
	end
end

--刷新侧边页签结构
function HouseMineMainPanelView:UpdateTabList()
	local UpdateList = {}
	local Key = 1
	if self.ViewModel.SelectKey > 0 then
		Key = self.ViewModel.SelectKey
	else
		if HouseInfoMgr.SharedHouseID ~= 0 then
			table.insert(UpdateList, self.ViewModel.SharedHouseList)
			table.insert(UpdateList, self.ViewModel.SharedPrivilegeList)
		else
			table.insert(UpdateList, self.ViewModel.SharedHouseInviteList)
		end
		Key = self.ViewModel:GetKeyByPageNum()
	end

	local Num = #self.ViewModel.TabList
	if Num > 0 then
		self.ViewModel.TabList[Num].Children = UpdateList
		self.HouseMineBG_UIBP:SetTabView(self.ViewModel.TabList, Key)
	end
end

--当被房主解除共享时，刷新房屋信息界面并默认显示共享房屋界面
function HouseMineMainPanelView:OnShareHouseBeRemoved(MsgBody)
	self.ViewModel.PageNum = 5
	self:OnShow()
end

function HouseMineMainPanelView:OnArmyLevelUp()
	self.ViewModel:UpdateTabList()
	self:OnShow()
end

function HouseMineMainPanelView:OnExitArmy()
	HouseInfoMgr:FreshCanVisitPanel()
	if self.ViewModel.TabList and self.ViewModel.TabList[1] and self.ViewModel.TabList[1].Children then
		local ChildrenData = self.ViewModel.TabList[1].Children
		self.ViewModel.PageNum = ChildrenData[1].Key
		self:OnShow()
	else
		self:Hide()
	end
end

---- 更新部队个人房间信息
function HouseMineMainPanelView:OnHouseMajorMemberInfoUpdate(MsgBody)
	if self.ViewModel.PageNum == 3 then
		if MsgBody and MsgBody.RoomDetail then
			local Detail = MsgBody.RoomDetail
			local Basic = Detail.Basic
			self.ViewModel.CommEmptyVisibility = false
			self.ViewModel.InfoPanelVisibility = true
		else
			self.ViewModel.CommEmptyVisibility = true
			self.ViewModel.InfoPanelVisibility = false
		end
	end
end

function HouseMineMainPanelView:OnPullArmyMemberRoom(MsgBody)
	if self.ViewModel.PageNum == 4 then
		if MsgBody and MsgBody.Rooms and next(MsgBody.Rooms) and MsgBody.GroupID == _G.ArmyMgr:GetArmyID() then
			_G.HouseMineMainPanelVM.CommEmptyVisibility = false
			_G.HouseMineMainPanelVM.RoomAllPanelVisibility = true
		else
			_G.HouseMineMainPanelVM.CommEmptyVisibility = true
			_G.HouseMineMainPanelVM.RoomAllPanelVisibility = false
		end
	end
end

function HouseMineMainPanelView:OnDestroyHouse(HouseID)
	if HouseID == HouseInfoMgr.ArmyHouseID or HouseID == HouseInfoMgr.MajorHouseID then
		self:Hide()
	end
end

function HouseMineMainPanelView:OnAbandonLand()
	self:Hide()
end

function HouseMineMainPanelView:OnEmptyPanelChangedCallback()
	if self.ViewModel.CommEmptyVisibility == true then
		if self.ViewModel.PageNum == 0 then
			self.CommEmpty:SetTipsContent(HouseLocalDef.HouseNoHouse)
			self.CommEmpty.IsBtn = false                            -- 调用时机在CommEmpty的Onshow之前 需要改bool
			--self.CommEmpty.IsBtn = true                        -- 不确定是否需要跳转获取房屋 有的话就去掉 并加上功能
			--self.CommEmpty:SetBtnText(HouseLocalDef.HouseGetHouse)       
		elseif self.ViewModel.PageNum == 2 then
			self.CommEmpty:SetTipsContent(HouseLocalDef.HouseNoArmy)
			self.CommEmpty.IsBtn = false
		elseif self.ViewModel.PageNum == 4 or self.ViewModel.PageNum == 3 then
			local ArmyLevel = _G.ArmyMgr:GetArmyLevel() or 0
			if ArmyLevel < 10 then
				self.CommEmpty:SetTipsContent(HouseLocalDef.HouseArmyRoom.ArmyUnlock)
				self.CommEmpty.IsBtn = false
			else
				if self.ViewModel.PageNum == 4 then
					self.CommEmpty:SetTipsContent(HouseLocalDef.HouseArmyRoom.ArmyNoHouse)
				else
					self.CommEmpty:SetTipsContent(HouseLocalDef.HouseArmyRoom.MajorNoHouse)
				end

				self.CommEmpty.IsBtn = true
				self.CommEmpty:SetBtnText(HouseLocalDef.HouseArmyRoom.ArmyCreateHouse)
			end
		end
	end
end

function HouseMineMainPanelView:OnClickEmptyBtn()
	if self.ViewModel.PageNum == 3 or self.ViewModel.PageNum == 4 then
		HouseInfoMgr:CreatGroupMemberRoomPopup()
	end
end

return HouseMineMainPanelView