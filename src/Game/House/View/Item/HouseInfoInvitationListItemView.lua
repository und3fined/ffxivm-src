---
--- Author: muyanli
--- DateTime: 2025-06-06 11:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")

---@class HouseInfoInvitationListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnHook UFButton
---@field BtnHouse UFButton
---@field CommHead CommHeadView
---@field IconJob UFImage
---@field IconName UFImage
---@field IconSever UFImage
---@field SizeBoxServer UFHorizontalBox
---@field TextHousingLocation UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLocation UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoInvitationListItemView = LuaClass(UIView, true)

function HouseInfoInvitationListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnHook = nil
	--self.BtnHouse = nil
	--self.CommHead = nil
	--self.IconJob = nil
	--self.IconName = nil
	--self.IconSever = nil
	--self.SizeBoxServer = nil
	--self.TextHousingLocation = nil
	--self.TextLevel = nil
	--self.TextLocation = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoInvitationListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoInvitationListItemView:OnInit()
	self.RoleID = nil
	self.RVM = nil
	self.HouseID = nil
	self.RoleVMBinders = {
		{ "Prof", 	UIBinderSetProfIcon.New(self, 	self.IconJob) },
		{ "Level", 	UIBinderValueChangedCallback.New(self, nil, self.UpdateLevel) },
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "MapResName", 		UIBinderValueChangedCallback.New(self, nil, self.UpdateTextLocation) },
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.IconSever)},
		{ "OnlineStatusIcon", 	UIBinderSetImageBrush.New(self, self.IconName) },
	}
end

function HouseInfoInvitationListItemView:OnDestroy()

end

--- Params
---    uint64  HouseID         = 1;    // 房屋ID
--    uint64  InvitorID       = 2;
--    int64   Time            = 3;
--    int32   ResID           = 4;    // 房屋资源ID
--    HouseAddr Addr          = 5;
---

function HouseInfoInvitationListItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local Data = Params.Data
	if Data == nil then
		return
	end
	self.CommHead:SetInfo(Data.InvitorID)
	local EstateInfoCfg = require("TableCfg/EstateInfoCfg")
	local EstateName = ""
	if EstateInfoCfg ~= nil then
		local EstateInfo = EstateInfoCfg:FindCfgByKey(Data.Addr.EstateID) or {}
		EstateName = EstateInfo.EstateName
	end

	local LandCondCfg =  require("TableCfg/LandCondCfg")
	local LandSearchCondition = string.format("EstateID=%d and BlockID=%d ", Data.Addr.EstateID, Data.Addr.Number)
	local LandCfg = LandCondCfg:FindCfg(LandSearchCondition)
	local HouseSize = ""
	if LandCfg then
		HouseSize = HouseLocalDef.HouseInfoSizeStr[LandCfg.Size]
	end
	self.TextHousingLocation:SetText(string.format(HouseLocalDef.LocationInfoStr.HouseAddr, EstateName, Data.Addr.Area, Data.Addr.Number, HouseSize))   --等待网络接入
end

function HouseInfoInvitationListItemView:OnHide()

end

function HouseInfoInvitationListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnHook, self.OnAcceptButtonClick)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnRefuseButtonClick)
	UIUtil.AddOnClickedEvent(self, self.BtnHouse, self.OnHouseInfoButtonClick)
end

function HouseInfoInvitationListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseInviteReplyRsp, self.OnHouseInviteReplyRsp)
end

function HouseInfoInvitationListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local Data = Params.Data
	if Data == nil then
		return
	end
	self.HouseID = Data.HouseID
	self.RoleID = Data.InvitorID
	if self.RoleID then
		self.RVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID, true)
		if self.RVM then
			self:RegisterBinders(self.RVM, self.RoleVMBinders)
		end
	end
end

function HouseInfoInvitationListItemView:OnAcceptButtonClick()
	if self.HouseID > 0 then
		_G.HouseInfoMgr:SendInviteReply(self.HouseID, true)
	end
end

function HouseInfoInvitationListItemView:OnRefuseButtonClick()
	if self.HouseID > 0 then
		_G.HouseInfoMgr:SendInviteReply(self.HouseID, false)
	end
end

function HouseInfoInvitationListItemView:OnHouseInfoButtonClick()
	if self.HouseID > 0 then
		_G.HouseInfoMgr:OpenOthersHouseInfoPanel(self.HouseID)
	end
end

function HouseInfoInvitationListItemView:OnHouseInviteReplyRsp(MsgBody)
	-- if MsgBody and MsgBody.Reply == true then
	-- 	MsgTipsUtil.ShowTips(string.format(HouseLocalDef.RoommatesInviteWinViewStr.InviteRspTips[1], self.RVM.Name))
	-- elseif MsgBody and MsgBody.Reply == false then
	-- 	MsgTipsUtil.ShowTips(string.format(HouseLocalDef.RoommatesInviteWinViewStr.InviteRspTips[2], self.RVM.Name))
	-- end
end


function HouseInfoInvitationListItemView:UpdateTextLocation()
	if self.RVM.IsOnline then
		self.TextLocation:SetText(self.RVM.MapResName)
	else
		local OfflineTime =  TimeUtil.GetServerTime() - self.RVM.LogoutTime
		self.TextLocation:SetText(LocalizationUtil.GetTimerForLowPrecision(OfflineTime))
	end
end

function HouseInfoInvitationListItemView:UpdateLevel()
	local LevelDesc  = tostring(self.RVM.Level) or ""
	self.TextLevel:SetText(LevelDesc)
end

return HouseInfoInvitationListItemView