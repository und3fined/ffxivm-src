---
--- Author: Administrator
--- DateTime: 2025-05-29 20:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsTeamUpDefine = require("Game/Ops/OpsTeamUp/OpsTeamUpDefine")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local OpsTeamUpPanelVM = require("Game/Ops/VM/OpsTeamUp/OpsTeamUpMainPanelVM")

---@class OpsTeamUpMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnGoto CommBtnLView
---@field RichTextBubble URichTextBox
---@field TableViewTeam UTableView
---@field TextSubTitle UFTextBlock
---@field TextTeam UFTextBlock
---@field TextTitle UFTextBlock
---@field TreasureChestBlue OpsTeamUpTreasureChestItemView
---@field TreasureChestYellow OpsTeamUpTreasureChestItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsTeamUpMainPanelView = LuaClass(UIView, true)

function OpsTeamUpMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnGoto = nil
	--self.RichTextBubble = nil
	--self.TableViewTeam = nil
	--self.TextSubTitle = nil
	--self.TextTeam = nil
	--self.TextTitle = nil
	--self.TreasureChestBlue = nil
	--self.TreasureChestYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsTeamUpMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.TreasureChestBlue)
	self:AddSubView(self.TreasureChestYellow)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsTeamUpMainPanelView:OnInit()
	self.TeamMemberList = UIAdapterTableView.CreateAdapter(self, self.TableViewTeam)
	self.TeamMemberList:SetOnClickedCallback(self.OnTeamMemberListItemClicked)
	self.Binders = {
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },
		{ "SubTitle", UIBinderSetText.New(self, self.TextSubTitle) },
		{ "Info", UIBinderSetText.New(self, self.RichTextBubble) },
		{ "TeamTile", UIBinderSetText.New(self, self.TextTeam) },
		{ "TeamMemberItemVMList", UIBinderUpdateBindableList.New(self, self.TeamMemberList) },
	}
end

function OpsTeamUpMainPanelView:OnDestroy()

end

function OpsTeamUpMainPanelView:OnShow()
	_G.OpsTeamUpMgr:SendShareTeamMembersNodeOperate()
	---设置预览奖励item
	self.TreasureChestBlue:SetData(OpsTeamUpDefine.ArgentRewardNodeID)
	self.TreasureChestYellow:SetData(OpsTeamUpDefine.GoldRewardNodeID)
	---设置按钮文本
	---LSTR 前往活动
	self.BtnGoto:SetText(LSTR(1650002))
end

function OpsTeamUpMainPanelView:OnHide()
	if OpsTeamUpPanelVM then
		OpsTeamUpPanelVM:ClearMemberRedDot()
	end
end

function OpsTeamUpMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickedBtnGoto)
end

function OpsTeamUpMainPanelView:OnRegisterGameEvent()

end

function OpsTeamUpMainPanelView:OnRegisterBinder()
	if OpsTeamUpPanelVM then
		self:RegisterBinders(OpsTeamUpPanelVM, self.Binders)
	end
end

function OpsTeamUpMainPanelView:OnClickedBtnGoto()
	_G.OpsTeamUpMgr:NodeJump(OpsTeamUpDefine.MemberNodeID)
end

return OpsTeamUpMainPanelView