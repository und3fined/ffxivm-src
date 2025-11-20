--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-26 20:26:17
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-26 20:31:46
FilePath: \Script\Game\House\View\HouseVisitingTroopsPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HouseVisitingTroopsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field HouseMineBG_UIBP HouseMineBGView
---@field RoomAllPanel HouseInfoRoomAllPanelView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseVisitingTroopsPanelView = LuaClass(UIView, true)

function HouseVisitingTroopsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.HouseMineBG_UIBP = nil
	--self.RoomAllPanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseVisitingTroopsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.HouseMineBG_UIBP)
	self:AddSubView(self.RoomAllPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseVisitingTroopsPanelView:OnInit()

end

function HouseVisitingTroopsPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HousePullArmyMemberRoom, self.OnPullArmyMemberRoom)
end

function HouseVisitingTroopsPanelView:OnShow()
	UIUtil.SetIsVisible(self.RoomAllPanel, false)
	UIUtil.SetIsVisible(self.CommEmpty, true)
	self.CommEmpty:SetTipsContent(HouseLocalDef.HouseArmyRoom.ArmyNoHouse)
	self.CommEmpty:ShowPanelBtn(false)
	if _G.HouseInfoMgr.VisitInDoorGroupID == 0 then return end
	UIUtil.SetIsVisible(self.HouseMineBG_UIBP.CommTab, false)
	UIUtil.SetIsVisible(self.HouseMineBG_UIBP.PanelServerTag, false)
	self.HouseMineBG_UIBP:SetTitleInfo(HouseLocalDef.HouseArmyRoom.GroupRoom)
    local ArmyHouseInfoList = {
		[1] = {
			Key = 1,
			Name =  "部队房屋",
			Children =  {
				{
					Key = 2,
					Name = "全部房间",
				}
			}
		}
    }

	self.HouseMineBG_UIBP:SetTabView(ArmyHouseInfoList, 1)
	_G.ArmyMgr:QueryArmySimple(_G.HouseInfoMgr.VisitInDoorGroupID, function(VM)
		local ArmyLevel = VM.ArmyLevel
		local ArmyHouseTitle = string.format(HouseLocalDef.HouseArmyRoom.VisArmyRoomTitle, VM.Name) 
		self.HouseMineBG_UIBP:SetTextHint(ArmyHouseTitle)
		if ArmyLevel >= 10 then
			self.RoomAllPanel:SetCurVisitArmyID(_G.HouseInfoMgr.VisitInDoorGroupID)
			UIUtil.SetIsVisible(self.RoomAllPanel, true)
		end
	end)

	if _G.HousingMgr.IndoorHouseID > 0 then
		_G.HouseInfoMgr:QueryHouseDetail(_G.HousingMgr.IndoorHouseID, function(Basic, Roommates)
			_G.EventMgr:SendEvent(_G.EventID.HouseMineBGLocationAni, Basic.Addr)
		end)
	end
end

function HouseVisitingTroopsPanelView:OnPullArmyMemberRoom(MsgBody)
	if MsgBody and MsgBody.GroupID == _G.HouseInfoMgr.VisitInDoorGroupID then
		if next(MsgBody.Rooms) then
			UIUtil.SetIsVisible(self.CommEmpty, false)
		end
	end
end

return HouseVisitingTroopsPanelView