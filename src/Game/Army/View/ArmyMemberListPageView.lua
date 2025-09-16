---
--- Author: Administrator
--- DateTime: 2024-10-23 11:27
--- Description:
---

local UIView = require("UI/UIView")
local GroupMgr = require("Game/Group/GroupMgr")
local LoginMgr = require("Game/Login/LoginMgr")
local LuaClass = require("Core/LuaClass")
local MSDKDefine = require("Define/MSDKDefine")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil

local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")

---@class ArmyMemberListPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCreat UFButton
---@field BtnExit CommBtnLView
---@field BtnInvite CommBtnLView
---@field BtnSwitch UFButton
---@field BtnSwitch02 UFButton
---@field ImgBtnIcon UFImage
---@field PanelCreatBtn UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field RichTextOnlineNum1 URichTextBox
---@field TableViewList UTableView
---@field TextCreat UFTextBlock
---@field TextGrade UFTextBlock
---@field TextTitleClass UFTextBlock
---@field TextTitleName UFTextBlock
---@field TextTitlePlace UFTextBlock
---@field AnimShowPanel UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberListPageView = LuaClass(UIView, true)

function ArmyMemberListPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCreat = nil
	--self.BtnExit = nil
	--self.BtnInvite = nil
	--self.BtnSwitch = nil
	--self.BtnSwitch02 = nil
	--self.ImgBtnIcon = nil
	--self.PanelCreatBtn = nil
	--self.PanelList = nil
	--self.RichTextOnlineNum1 = nil
	--self.TableViewList = nil
	--self.TextCreat = nil
	--self.TextGrade = nil
	--self.TextTitleClass = nil
	--self.TextTitleName = nil
	--self.TextTitlePlace = nil
	--self.AnimShowPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberListPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnExit)
	self:AddSubView(self.BtnInvite)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberListPageView:OnInit()
	ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
	self.TableViewMemberAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
    self.TableViewMemberAdapter:SetOnClickedCallback(self.OnClickedSelectMemberItem)
	self.Binders = {
        {"MemberOnLinenNum", UIBinderSetText.New(self, self.RichTextOnlineNum1)},
        {"ExitBtnText", UIBinderSetText.New(self, self.BtnExit.TextContent)},
        {"CategoryPmssTitle", UIBinderSetText.New(self, self.TextName)},
        {"MemberList", UIBinderUpdateBindableList.New(self, self.TableViewMemberAdapter)},
		{ "IsShowInviteBtn", UIBinderSetIsVisible.New(self, self.BtnInvite, false, true) },
		{ "GroupIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBtnIcon) },
		{ "GroupBtnText", UIBinderSetText.New(self, self.TextCreat)},
    }
end

function ArmyMemberListPageView:OnDestroy()

end

function ArmyMemberListPageView:OnShow()
	-- LSTR string:名字
	self.TextTitleName:SetText(LSTR(910315))
	-- LSTR string:分组
	self.TextTitleClass:SetText(LSTR(910316))
	-- LSTR string:等级
	self.TextGrade:SetText(LSTR(910296))
	-- LSTR string:地点/记录
	self.TextTitlePlace:SetText(LSTR(910317))
	-- LSTR string:邀请好友
	self.BtnInvite:SetText(LSTR(910405))

	-- 一键建群
	if _G.CommonUtil.IsIOSPlatform() or _G.CommonUtil.IsAndroidPlatform() then
		GroupMgr:ShowGroupBtn()
		UIUtil.SetIsVisible(self.PanelCreatBtn, true)
	else
		UIUtil.SetIsVisible(self.PanelCreatBtn, false)
	end
end

function ArmyMemberListPageView:OnHide()
	self.TableViewMemberAdapter:ClearSelectedItem()
end

function ArmyMemberListPageView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickedQuitArmy)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickedSwitchCategorySort)
    UIUtil.AddOnClickedEvent(self, self.BtnSwitch02, self.OnClickedSwitchLevelSort)
    UIUtil.AddOnClickedEvent(self, self.BtnInvite, self.OnClickedInvite)
    UIUtil.AddOnClickedEvent(self, self.BtnCreat, self.OnClickedCreate)
end

function ArmyMemberListPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ApplicationWillDeactivate, self.OnApplicationWillDeactivate)
	self:RegisterGameEvent(_G.EventID.ApplicationHasReactivated, self.OnApplicationHasReactivated)
end

function ArmyMemberListPageView:OnRegisterBinder()
    self:RegisterBinders(ArmyMemberPageVM, self.Binders)
end

function ArmyMemberListPageView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if self.SelectMemberCallBack then
		local Owner = self.SelectMemberCallBackOwner or self.Owner
		self.SelectMemberCallBack(Owner, Index, ItemData, ItemView)
	end
end

function ArmyMemberListPageView:OnClickedQuitArmy()
	if self.ExitCallBack then
		local Owner = self.ExitCallBackOwner or self.Owner
		self.ExitCallBack(Owner)
	end
end

function ArmyMemberListPageView:SetOwner(Owner)
	self.Owner = Owner
end

function ArmyMemberListPageView:SetExitCallBack(ExitCallBack, ExitCallBackOwner)
	self.ExitCallBack = ExitCallBack
	self.ExitCallBackOwner = ExitCallBackOwner
end

function ArmyMemberListPageView:SetSelectMemberCallBack(SelectMemberCallBack, SelectMemberCallBackOwner)
	self.SelectMemberCallBack = SelectMemberCallBack
	self.SelectMemberCallBackOwner = SelectMemberCallBackOwner
end

--- 分组排序
function ArmyMemberListPageView:OnClickedSwitchCategorySort()
    ArmyMemberPageVM:MembersCategorySort()
end

--- 等级排序
function ArmyMemberListPageView:OnClickedSwitchLevelSort()
    ArmyMemberPageVM:MembersLevelSort()
end

function ArmyMemberListPageView:OnClickedInvite()
    _G.ArmyMgr:OpenInviteWinByItemType(InviteSignSideDefine.InviteItemType.ArmyInvite)
end

function ArmyMemberListPageView:OnClickedCreate()
    GroupMgr:HandleGroupBtnClick()
end

function ArmyMemberListPageView:OnApplicationWillDeactivate()
	_G.FLOG_INFO("[ArmyMemberListPageView:OnApplicationWillDeactivate] ")
end

function ArmyMemberListPageView:OnApplicationHasReactivated()
	_G.FLOG_INFO("[ArmyMemberListPageView:OnApplicationHasReactivated] ")
	GroupMgr:GetGroupState()
end

return ArmyMemberListPageView