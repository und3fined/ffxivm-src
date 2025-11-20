---
--- Author: Administrator
--- DateTime: 2025-07-10 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath =require("Binder/UIBinderSetBrushFromAssetPath")
local OpsReturnWelfarePanelVM = require("Game/Ops/VM/OpsReturn/OpsReturnWelfarePanelVM")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ArmyMgr = require("Game/Army/ArmyMgr")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatChannel = ChatDefine.ChatChannel

---@class OpsReturnWelfarePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn1 UFButton
---@field Btn2 UFButton
---@field Btn3 UFButton
---@field Btn4 UFButton
---@field BtnArmy UFButton
---@field BtnAward UFButton
---@field BtnDisabled UFImage
---@field BtnFriends UFButton
---@field BtnNormal UFImage
---@field CommInforBtn_UIBP CommInforBtnView
---@field IconArmy UFImage
---@field IconArrow UFImage
---@field IconFriends UFImage
---@field TableViewSlot UTableView
---@field TextArmy UFTextBlock
---@field TextArmyTitle UFTextBlock
---@field TextAward UFTextBlock
---@field TextBubble UFTextBlock
---@field TextBubbleTitle UFTextBlock
---@field TextChannel UFTextBlock
---@field TextExperience UFTextBlock
---@field TextFriends UFTextBlock
---@field TextFriendsTitle UFTextBlock
---@field TextNewcomersTitle UFTextBlock
---@field TextNewcomersTitle_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnWelfarePanelView = LuaClass(UIView, true)

local NodeID = 2507030101
function OpsReturnWelfarePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.Btn3 = nil
	--self.Btn4 = nil
	--self.BtnArmy = nil
	--self.BtnAward = nil
	--self.BtnDisabled = nil
	--self.BtnFriends = nil
	--self.BtnNormal = nil
	--self.CommInforBtn_UIBP = nil
	--self.IconArmy = nil
	--self.IconArrow = nil
	--self.IconFriends = nil
	--self.TableViewSlot = nil
	--self.TextArmy = nil
	--self.TextArmyTitle = nil
	--self.TextAward = nil
	--self.TextBubble = nil
	--self.TextBubbleTitle = nil
	--self.TextChannel = nil
	--self.TextExperience = nil
	--self.TextFriends = nil
	--self.TextFriendsTitle = nil
	--self.TextNewcomersTitle = nil
	--self.TextNewcomersTitle_1 = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnWelfarePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnWelfarePanelView:OnInit()
	self.ViewModel = OpsReturnWelfarePanelVM.New()

	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedRewardItem, true)

	self.Binders = {
		{"Title", UIBinderSetText.New(self, self.TextBubbleTitle)},
		{"Content", UIBinderSetText.New(self, self.TextBubble)},
		{"AwardText", UIBinderSetText.New(self, self.TextAward)},
		{"NewbeeBenfitContent", UIBinderSetText.New(self, self.TextNewcomersTitle_1)},
		{"NewbeeBenfitPromoteText", UIBinderSetText.New(self, self.TextExperience)},
		{"FriendsContent", UIBinderSetText.New(self, self.TextFriends)},
		{"ArmyContent", UIBinderSetText.New(self, self.TextArmy)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		-- {"NewbeeIcon", UIBinderSetBrushFromAssetPath.New(self, self.RewardListAdapter)},
	}
end

function OpsReturnWelfarePanelView:OnDestroy()
end

function OpsReturnWelfarePanelView:OnShow()

	self:InitText()
	-- self.CommInforBtn_UIBP:SetHelpInfoID(11117)
	self.CommInforBtn_UIBP:SetButtonStyle(4)
	self.CommInforBtn_UIBP:SetCallback(self, self.OnClickedBenifit)
	self.ViewModel:UpdateWelfareData()
	local Cfg = ActivityNodeCfg:FindCfgByKey(OpsReturnDefine.ActivityNodeID[OpsReturnDefine.ActivityNodeType.MailNodeID] )
	if Cfg ~= nil then
		self.ViewModel:UpdateRewardList(Cfg.Rewards)
	end
end

function OpsReturnWelfarePanelView:OnHide()
end

function OpsReturnWelfarePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAward, self.OnClickedAward)
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnClickedBenifit)
	UIUtil.AddOnClickedEvent(self, self.Btn2, self.OnClickedFriend)
	UIUtil.AddOnClickedEvent(self, self.Btn3, self.OnClickedArmy)
	UIUtil.AddOnClickedEvent(self, self.Btn4, self.OnClickedChannel)
	UIUtil.AddOnClickedEvent(self, self.BtnFriends, self.OnClickedFriend)
	UIUtil.AddOnClickedEvent(self, self.BtnArmy, self.OnClickedArmy)

end

function OpsReturnWelfarePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.UpdateOpsReturn, self.OnUpdateOpsReturn)
end

function OpsReturnWelfarePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsReturnWelfarePanelView:InitText()
	self.TextNewcomersTitle:SetText(_G.LSTR(1680017)) --新人权益
	self.TextFriendsTitle:SetText(_G.LSTR(1680018)) --查看好友
	self.TextArmyTitle:SetText(_G.LSTR(1680019)) --查看部队
	self.TextChannel:SetText(_G.LSTR(1680020)) --新人频道
end


function OpsReturnWelfarePanelView:OnUpdateOpsReturn()
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(_G.OpsReturnMgr:GetActivityID())
	if NodeData and NodeData.NodeList then
		local NodeList = NodeData.NodeList or {}
		for i = 1, #NodeList do
			if NodeList[i].Head and  NodeList[i].Head.NodeID  then
				if NodeList[i].Head.NodeID == NodeID then
					-- 更新状态
					-- self.ViewModel:UpdateRewardList(NodeList[i].Head.Rewards)
					break
				end
			end
		end
	end
end

function OpsReturnWelfarePanelView:OnClickedRewardItem(Index, ItemData, ItemView)
	if ItemData and ItemData.ResID then
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end

-- 去邮箱
function OpsReturnWelfarePanelView:OnClickedAward()
	_G.MailMgr:OpenMailMainView()
end

-- 点击新手权益
function OpsReturnWelfarePanelView:OnClickedBenifit()
	HelpInfoUtil.ShowHelpInfoByID(11226)
end

-- 点击好友
function OpsReturnWelfarePanelView:OnClickedFriend()
	_G.UIViewMgr:ShowView(_G.UIViewID.SocialMainPanel)
end

-- 点击部队
function OpsReturnWelfarePanelView:OnClickedArmy()
	ArmyMgr:OpenArmyMainPanel()
end

-- 点击新手频道
function OpsReturnWelfarePanelView:OnClickedChannel()
	_G.ChatMgr:ShowChatView(ChatChannel.Newbie)
end


return OpsReturnWelfarePanelView