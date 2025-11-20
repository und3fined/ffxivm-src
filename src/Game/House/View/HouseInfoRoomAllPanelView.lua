---
--- Author: mingyyzhang
--- DateTime: 2025-06-13 16:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local ArmyMgr = require("Game/Army/ArmyMgr")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local RoomAllPanelVM = require("Game/House/VM/HouseInfoRoomAllPanelVM")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class HouseInfoRoomAllPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRoom CommBtnLView
---@field TableViewRoom UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoRoomAllPanelView = LuaClass(UIView, true)

function HouseInfoRoomAllPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRoom = nil
	--self.TableViewRoom = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoRoomAllPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRoom)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoRoomAllPanelView:OnInit()
	self.ViewModel = RoomAllPanelVM.New()
	self.RoomListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRoom)
	self.RoomListTableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.Binders = {
		{"BtnRoomVisibility", UIBinderSetIsVisible.New(self, self.BtnRoom) },
		{"RoomList", UIBinderUpdateBindableList.New(self, self.RoomListTableViewAdapter)},
		{"TextButton", UIBinderSetText.New(self, self.BtnRoom.TextContent) },
	}
end

function HouseInfoRoomAllPanelView:OnDestroy()

end

function HouseInfoRoomAllPanelView:SetCurVisitArmyID(ArmyID)
	self.ArmyID = ArmyID
end

function HouseInfoRoomAllPanelView:OnShow()
	if self.ArmyID then
		_G.HouseInfoMgr:SendPullArmyMemberRoom(self.ArmyID)
	else
		if ArmyMgr:GetArmyLevel() and ArmyMgr:GetArmyLevel() < 10 then
			_G.HouseMineMainPanelVM.CommEmptyVisibility = true
			_G.HouseMineMainPanelVM.RoomAllPanelVisibility = false
		else
			_G.HouseInfoMgr:SendPullArmyMemberRoom(ArmyMgr:GetArmyID())
		end
	end
end

function HouseInfoRoomAllPanelView:OnHide()
	self.ArmyID = nil
end

function HouseInfoRoomAllPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRoom, self.OnClickBack)
end

function HouseInfoRoomAllPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HousePullArmyMemberRoom, self.OnPullArmyMemberRoom)
end

function HouseInfoRoomAllPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

-- 回房间或创建个人房屋
function HouseInfoRoomAllPanelView:OnClickBack()
	if self.ViewModel.HasRoom == true then
		_G.EventMgr:SendEvent(_G.EventID.HouseInfoOpenPage, 7)
	else
		_G.HouseInfoMgr:CreatGroupMemberRoomPopup()
	end
end

function HouseInfoRoomAllPanelView:OnPullArmyMemberRoom(MsgBody)
	if MsgBody and MsgBody.Rooms and next(MsgBody.Rooms) and  (MsgBody.GroupID == ArmyMgr:GetArmyID() or MsgBody.GroupID == self.ArmyID) then
		self.ViewModel:UpdateVM(MsgBody.Rooms)
		if self.ArmyID then
			self.ViewModel.BtnRoomVisibility = false
		end
	end
end

--TableView回调 点击个人房间Item
function HouseInfoRoomAllPanelView:OnItemClicked(Index, ItemData, ItemView)
	if self.ViewModel.MemberRoomList[Index].HouseID then
		if self.ViewModel.MemberRoomList[Index].HouseID == _G.HouseInfoMgr.MajorMemberHouseID then
			_G.EventMgr:SendEvent(_G.EventID.HouseInfoOpenPage, 7)
		else
			local CanVisit = _G.HouseLandMgr.GetVisitPrivile(self.ViewModel.MemberRoomList[Index].OwnerID, self.ViewModel.MemberRoomList[Index].VisitSetting, {},  
			ProtoCS.HouseVisitSettingType.HouseVisitSettingType_Browser, HouseLocalDef.BuyHouseBelongType.Army)
			if CanVisit == true then
				_G.HouseInfoMgr:OpenOthersHouseInfoPanel(self.ViewModel.MemberRoomList[Index].HouseID)
			else
				MsgTipsUtil.ShowTips(HouseLocalDef.HouseArmyRoom.CannotVisit)
			end
		end
	else
		MsgTipsUtil.ShowTips(HouseLocalDef.HouseArmyRoom.IsEmptyRoom)
	end
end

return HouseInfoRoomAllPanelView