---
--- Author: xingcaicao
--- DateTime: 2023-04-21 15:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")

local LSTR = _G.LSTR
local UnitedArmyTabs = ArmyDefine.UnitedArmyTabs
local GroupRecruitStatus = ProtoCS.GroupRecruitStatus

---@class PersonInfoArmyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadge ArmyBadgeItemView
---@field BtnCancel CommBtnLView
---@field BtnCopy UFButton
---@field BtnPreserve CommBtnLView
---@field FrameM Comm2FrameMView
---@field ImgArmyBg UFImage
---@field TextArmyID UFTextBlock
---@field TextArmyName UFTextBlock
---@field TextLeaderName UFTextBlock
---@field TextMemberNum UFTextBlock
---@field TextRecruitState UFTextBlock
---@field TextSlogan UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoArmyPanelView = LuaClass(UIView, true)

function PersonInfoArmyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadge = nil
	--self.BtnCancel = nil
	--self.BtnCopy = nil
	--self.BtnPreserve = nil
	--self.FrameM = nil
	--self.ImgArmyBg = nil
	--self.TextArmyID = nil
	--self.TextArmyName = nil
	--self.TextLeaderName = nil
	--self.TextMemberNum = nil
	--self.TextRecruitState = nil
	--self.TextSlogan = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoArmyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadge)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnPreserve)
	self:AddSubView(self.FrameM)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoArmyPanelView:OnInit()
	self.Binders = {
		{ "ArmySimpleInfo", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedArmySimpleInfo) },
	}

	self.FrameM.FText_Title:SetText(LSTR(620103))

	self.Text1:SetText(LSTR(620109))
	self.Text2:SetText(LSTR(620110))
	self.Text3:SetText(LSTR(620111))
	self.Text4:SetText(LSTR(620112))
	self.Text5:SetText(LSTR(620113))

end

function PersonInfoArmyPanelView:OnDestroy()

end

function PersonInfoArmyPanelView:OnShow()
	---策划要求先隐藏
	UIUtil.SetIsVisible(self.BtnPreserve, false)
	UIUtil.SetIsVisible(self.BtnCancel, false)
end

function PersonInfoArmyPanelView:OnHide()

end

function PersonInfoArmyPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickButtonCopy)
	UIUtil.AddOnClickedEvent(self, self.BtnPreserve, self.OnClickButtonPreserve)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
end

function PersonInfoArmyPanelView:OnRegisterGameEvent()

end

function PersonInfoArmyPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonInfoVM, self.Binders)
end

function PersonInfoArmyPanelView:OnValueChangedArmySimpleInfo( Info )
	Info = Info or {}
	local ArmyID = Info.ID 
	self.ArmyID = ArmyID
	if nil == ArmyID or ArmyID <= 0 then
		return
	end

	--部队名称
	self.TextArmyName:SetText(Info.Name or "")

	--会长名字
	local LeaderRoleID = PersonInfoVM.ArmyLeaderRoleID
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(LeaderRoleID) or {}
	self.TextLeaderName:SetText(RoleVM.Name or "")

	--部队编号
	self.TextArmyID:SetText(tostring(ArmyID))

	--部队成员数量
	local MemTotal = _G.ArmyMgr:GetArmyMemberMaxCount(Info.Level) or 0
    local MemberDesc = string.format("%d/%d", Info.MemberCount or 0, MemTotal)
	self.TextMemberNum:SetText(MemberDesc)

	--招募状态
	self.TextRecruitState:SetText(Info.RecruitStatus == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open and LSTR(620007) or LSTR(620006))


	--部队标语
	self.TextSlogan:SetText(Info.RecruitSlogan or "")

	--国防联军背景
	local ArmyType = Info.GrandCompanyType or 1
    local BGIcon = UnitedArmyTabs[ArmyType].BGIcon
    UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyBg, BGIcon)
	
	--部队徽章
	self.ArmyBadge:SetBadgeData(Info.Emblem)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoArmyPanelView:OnClickButtonCopy()
	if nil == self.ArmyID then
		return
	end

    CommonUtil.ClipboardCopy(self.ArmyID)
    MsgTipsUtil.ShowTips(LSTR(620016))
end

function PersonInfoArmyPanelView:OnClickButtonPreserve()
	-- if _G.ArmyMgr:IsInArmy() then
	-- 	MsgTipsUtil.ShowTips(LSTR(620004))
	-- 	return
	-- end
	
	if self.ArmyID ~= nil then
		_G.ArmyMgr:OpenArmyQueryListByID(self.ArmyID)
	end

	_G.UIViewMgr:HideView(_G.UIViewID.PersonInfoSimplePanel)
	self:Hide()
end

function PersonInfoArmyPanelView:OnClickButtonCancel()
	self:Hide()
end

return PersonInfoArmyPanelView