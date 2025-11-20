---
--- Author: Administrator
--- DateTime: 2025-07-10 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OpsReturnMainPanelVM = require("Game/Ops/VM/OpsReturn/OpsReturnMainPanelVM")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local JumpUtil = require("Utils/JumpUtil")

-- lua _G.UIViewMgr:ShowView(_G.UIViewID.OpsReturnMainView)

---@class OpsReturnMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCommunity UFButton
---@field BtnConfidant UFButton
---@field ContentpushPanel OpsReturnContentpushPanelView
---@field OpsActivityTime OpsActivityTimeItemView
---@field OpsReturnTab1 OpsReturnTabItemView
---@field OpsReturnTab2 OpsReturnTabItemView
---@field OpsReturnTab3 OpsReturnTabItemView
---@field TaskPanel OpsReturnTaskPanelView
---@field TextCommunity UFTextBlock
---@field TextConfidant UFTextBlock
---@field TextTitle UFTextBlock
---@field WelfarePanel OpsReturnWelfarePanelView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnMainPanelView = LuaClass(UIView, true)

function OpsReturnMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCommunity = nil
	--self.BtnConfidant = nil
	--self.ContentpushPanel = nil
	--self.OpsActivityTime = nil
	--self.OpsReturnTab1 = nil
	--self.OpsReturnTab2 = nil
	--self.OpsReturnTab3 = nil
	--self.TaskPanel = nil
	--self.TextCommunity = nil
	--self.TextConfidant = nil
	--self.TextTitle = nil
	--self.WelfarePanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ContentpushPanel)
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.OpsReturnTab1)
	self:AddSubView(self.OpsReturnTab2)
	self:AddSubView(self.OpsReturnTab3)
	self:AddSubView(self.TaskPanel)
	self:AddSubView(self.WelfarePanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnMainPanelView:OnInit()
	self.ViewModel = OpsReturnMainPanelVM

	self.Binders = {
		{"Title", UIBinderSetText.New(self, self.TextTitle)},
		{"WelfarePanelVisible", UIBinderSetIsVisible.New(self, self.WelfarePanel)},
		{"ContentpushPanelVisible", UIBinderSetIsVisible.New(self, self.ContentpushPanel)},
		{"TaskPanelVisible", UIBinderSetIsVisible.New(self, self.TaskPanel)},
		{"WelfarePanelVisible", UIBinderSetIsChecked.New(self, self.OpsReturnTab1.ToggleButton)},
		{"ContentpushPanelVisible", UIBinderSetIsChecked.New(self, self.OpsReturnTab2.ToggleButton)},
		{"TaskPanelVisible", UIBinderSetIsChecked.New(self, self.OpsReturnTab3.ToggleButton)},
		{"HelpID", UIBinderValueChangedCallback.New(self, nil, self.OnHelpIDChanged)},
	}
end

function OpsReturnMainPanelView:OnDestroy()

end

function OpsReturnMainPanelView:OnShow()
	local Params = self.Params
	if not(Params and Params.ActivityID) then return end
	self:InitText()
	self.OpsReturnTab1.CommonRedDot:SetRedDotIDByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.PageTypeWelfare])
	self.OpsReturnTab2.CommonRedDot:SetRedDotIDByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.PageTypeContentPush])
	self.OpsReturnTab3.CommonRedDot:SetRedDotIDByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.PageTypeTask])
	self.ViewModel:UpdateBaseData( _G.OpsReturnMgr:GetActivityID())
	self:OnClickedOpsReturnTab1()
	_G.OpsReturnMgr:SetContentStartIndex(1)
end

function OpsReturnMainPanelView:OnHide()
end

function OpsReturnMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfidant, self.OnClickedConfdiantBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnCommunity, self.OnClickedCommunitytBtn)
	UIUtil.AddOnStateChangedEvent(self, self.OpsReturnTab1.ToggleButton, self.OnClickedOpsReturnTab1)
	UIUtil.AddOnStateChangedEvent(self, self.OpsReturnTab2.ToggleButton, self.OnClickedOpsReturnTab2)
	UIUtil.AddOnStateChangedEvent(self, self.OpsReturnTab3.ToggleButton, self.OnClickedOpsReturnTab3)
end

function OpsReturnMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdateInfo, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.UpdateOpsReturn, self.OnUpdateOpsReturn)
end

function OpsReturnMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

-- 更新
function OpsReturnMainPanelView:OnUpdateOpsReturn()
end

function OpsReturnMainPanelView:InitText()
	self.TextCommunity:SetText(_G.LSTR(1680001)) -- 社区
	self.TextConfidant:SetText(_G.LSTR(1680002))  --知己

	self.OpsReturnTab1:SetText(_G.LSTR(1680003)) -- 回归福利
	self.OpsReturnTab2:SetText(_G.LSTR(1680004)) -- 内容推送
	self.OpsReturnTab3:SetText(_G.LSTR(1680005)) -- 回归任务
end

-- 点击知己
function OpsReturnMainPanelView:OnClickedConfdiantBtn()
	JumpUtil.JumpTo(184)
end

-- 点击社区
function OpsReturnMainPanelView:OnClickedCommunitytBtn()
	local HttpUrl = "https://fza.qq.com/mp_jump/?aid=ZmYxNF8yMDI1MDcwNDAx&loginType=%d&id=%d&adtag=ingame_act"
	if _G.LoginMgr:IsQQLogin() then
		-- if not AccountUtil.IsQQInstalled() then
		-- 	MsgTipsUtil.ShowTips(LSTR(1600030)) --"未安装应用"
		-- 	return
		-- end
		local Url = string.format(HttpUrl, 2, 3)
		local ExtraJson = ""
		_G.UE.UAccountMgr.Get():OpenUrl(Url, 1, false, true, ExtraJson, false)

	elseif _G.LoginMgr:IsWeChatLogin() then
		-- if not AccountUtil.IsWeChatInstalled() then
		-- 	MsgTipsUtil.ShowTips(LSTR(1600030)) --"未安装应用"
		-- 	return
		-- end
		local Url = string.format(HttpUrl, 1, 3)
		local ExtraJson = ""
		_G.UE.UAccountMgr.Get():OpenUrl(Url, 1, false, true, ExtraJson, false)
	end
end

-- 点击回归福利
function OpsReturnMainPanelView:OnClickedOpsReturnTab1()
	self.ViewModel:OpenWelfarePanel()
	_G.OpsReturnMgr:SetPageOpenTimeStatus(1, _G.TimeUtil.GetServerLogicTime())
end

-- 点击内容推送
function OpsReturnMainPanelView:OnClickedOpsReturnTab2()
	self.ViewModel:OpenContentPushPanel()
	_G.OpsReturnMgr:SetPageOpenTimeStatus(2, _G.TimeUtil.GetServerLogicTime())
end

-- 点击回归任务
function OpsReturnMainPanelView:OnClickedOpsReturnTab3()
	self.ViewModel:OpenTaskPanel()
	_G.OpsReturnMgr:SetPageOpenTimeStatus(3, _G.TimeUtil.GetServerLogicTime())
end

function OpsReturnMainPanelView:OnHelpIDChanged()
	self.OpsActivityTime.InforBtn.HelpInfoID = self.ViewModel.HelpID
end

function OpsReturnMainPanelView:OpsNodeRewardGet()
end

return OpsReturnMainPanelView