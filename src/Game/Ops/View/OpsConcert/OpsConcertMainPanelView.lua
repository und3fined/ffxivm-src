---
--- Author: usakizhang
--- DateTime: 2025-03-06 15:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsConcertMainPanelVM = require("Game/Ops/VM/OpsConcert/OpsConcertMainPanelVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UIBindableList = require("UI/UIBindableList")
local MailSlotItemViewVM = require("Game/Mail/View/Item/MailSlotItemViewVM")
local UIViewID = require("Define/UIViewID")
local AccountUtil = require("Utils/AccountUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local MSDKDefine = require("Define/MSDKDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local AudioUtil = require("Utils/AudioUtil")
local Json = require("Core/Json")
local NodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
local EventID = _G.EventID
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@class OpsConcertMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnMore UFButton
---@field BtnPerformance UFButton
---@field BtnRecallList CommBtnSView
---@field BtnRecallMore CommBtnSView
---@field CommEmpty CommBackpackEmptyView
---@field Note1 OpsConcertNoteItemView
---@field Note10 OpsConcertNoteItemView
---@field Note2 OpsConcertNoteItemView
---@field Note3 OpsConcertNoteItemView
---@field Note4 OpsConcertNoteItemView
---@field Note5 OpsConcertNoteItemView
---@field Note6 OpsConcertNoteItemView
---@field Note7 OpsConcertNoteItemView
---@field Note8 OpsConcertNoteItemView
---@field Note9 OpsConcertNoteItemView
---@field PanelFriendasList UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelPerformanceFocus UFCanvasPanel
---@field PanelPerformanceNormal UFCanvasPanel
---@field RichTextQuantity URichTextBox
---@field TabBtn1 UToggleButton
---@field TabBtn2 UToggleButton
---@field TableViewFriendsList UTableView
---@field TableViewGetList UTableView
---@field TableViewSlot UTableView
---@field Text1TabNormal UFTextBlock
---@field Text1TabSelect UFTextBlock
---@field Text2TabNormal UFTextBlock
---@field Text2TabSelect UFTextBlock
---@field TextExplain UFTextBlock
---@field TextMore UFTextBlock
---@field TextPerformance UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimComLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPerformanceLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertMainPanelView = LuaClass(UIView, true)
local WeChatMiniAppCfg = {
	AppID = "gh_417667c90c73",
	Link = "pages/index/index?",
	TumbPath = "https://game.gtimg.cn/images/ff14/act/a20250318reflux/share.png"
}
local QQMiniAppCfg = {
	Link = "https://ff14m.qq.com/cp/a20250616reflux/index.html?",
	TumbPath = "https://game.gtimg.cn/images/ff14/cp/a20250616reflux/share.png",
}
local ClickSound = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Play_Activity_Return_click.Play_Activity_Return_click'"
local MusicSound = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Play_Activity_Return_start.Play_Activity_Return_start'"
function OpsConcertMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnMore = nil
	--self.BtnPerformance = nil
	--self.BtnRecallList = nil
	--self.BtnRecallMore = nil
	--self.CommEmpty = nil
	--self.Note1 = nil
	--self.Note10 = nil
	--self.Note2 = nil
	--self.Note3 = nil
	--self.Note4 = nil
	--self.Note5 = nil
	--self.Note6 = nil
	--self.Note7 = nil
	--self.Note8 = nil
	--self.Note9 = nil
	--self.PanelFriendasList = nil
	--self.PanelList = nil
	--self.PanelPerformanceFocus = nil
	--self.PanelPerformanceNormal = nil
	--self.RichTextQuantity = nil
	--self.TabBtn1 = nil
	--self.TabBtn2 = nil
	--self.TableViewFriendsList = nil
	--self.TableViewGetList = nil
	--self.TableViewSlot = nil
	--self.Text1TabNormal = nil
	--self.Text1TabSelect = nil
	--self.Text2TabNormal = nil
	--self.Text2TabSelect = nil
	--self.TextExplain = nil
	--self.TextMore = nil
	--self.TextPerformance = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.AnimComLoop = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimPerformanceLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.BtnRecallList)
	self:AddSubView(self.BtnRecallMore)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.Note1)
	self:AddSubView(self.Note10)
	self:AddSubView(self.Note2)
	self:AddSubView(self.Note3)
	self:AddSubView(self.Note4)
	self:AddSubView(self.Note5)
	self:AddSubView(self.Note6)
	self:AddSubView(self.Note7)
	self:AddSubView(self.Note8)
	self:AddSubView(self.Note9)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsConcertMainPanelView:OnInit()
	self.ViewModel = OpsConcertMainPanelVM.New()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewSlot)
	self.RewardListAdapter:SetOnClickedCallback(self.TableViewRewardClicked)
	self.TaskListAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewGetList)
	self.ChinaSocialFriendListAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewFriendsList)

	self.Binders = {
		--- 奖励部分
		{"NumText", UIBinderSetText.New(self, self.RichTextQuantity)},
		{"RewardVMList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		-- {"IsEnoughForPerform", UIBinderSetIsVisible.New(self, self.PanelPerformanceFocus)},
		{"PerformanceText", UIBinderSetText.New(self, self.TextPerformance)},
		{ "CurrentMusicalNoteNum", UIBinderValueChangedCallback.New(self, nil, self.OnMusicalNoteChanged) },
		---获取乐章页签
		
		{"GetMusicalNoteTabSelected", UIBinderSetIsChecked.New(self, self.TabBtn1)},
		{"GetMusicalNoteTabSelected", UIBinderSetIsVisible.New(self, self.TableViewGetList)},
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskListAdapter)},
		
		---召回好友页签
		{"CallFriendTabSelected", UIBinderSetIsChecked.New(self, self.TabBtn2)},
		{"CallFriendTabSelected", UIBinderSetIsVisible.New(self, self.PanelFriendasList)},
		{"SocialFriendVMList", UIBinderUpdateBindableList.New(self, self.ChinaSocialFriendListAdapter)},
		{"CallFriendListEmpty", UIBinderSetIsVisible.New(self, self.CommEmpty)},
		{"MoreBtnIsVisible", UIBinderSetIsVisible.New(self, self.BtnMore, false, true)},
	}
	self.IsPerforming = false
	self.NoteList = {
		self.Note1, self.Note2, self.Note3, self.Note4, self.Note5, self.Note6, self.Note7, self.Note8, self.Note9, self.Note10
	}
	self.ClickSoundHandle = nil
	self.MusicSoundHandle = nil
	--- 设置演奏Icon
	self:InitNoteList()
end

function OpsConcertMainPanelView:OnDestroy()
	self.ViewModel = nil
end

function OpsConcertMainPanelView:OnShow()

	self.CommEmpty:SetTipsContent(LSTR(1600029))
	self.TextTitle:SetText(LSTR(1600001)) --萌神演奏会
	self.TextSubTitle:SetText(LSTR(1600002)) --召集回归冒险者登陆游戏，赢取库啵好礼！
	self.TextExplain:SetText(LSTR(1600004)) --积攒音符演奏曲谱，随机获得1次演出奖品
	self.Text1TabSelect:SetText(LSTR(1600005)) --获取乐章
	self.Text1TabNormal:SetText(LSTR(1600005)) --获取乐章
	self.Text2TabSelect:SetText(LSTR(1600006)) --召回好友
	self.Text2TabNormal:SetText(LSTR(1600006)) --召回好友
	self.TextMore:SetText(LSTR(1600013)) --加载更多
	self.BtnRecallList:SetText(LSTR(1600007)) --召回好友列表
	self.BtnRecallMore:SetText(LSTR(1600008)) --召回更多
	self.ViewModel:Update(self.Params)
	--- 任务页签默认选中
	self.ViewModel:SetMusicalNoteTabSelected()
	--- 发送拉取绑定玩家列表的请求
	_G.OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.GetInviteListNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypePullBindRole, {})
	self:StopAnimation(self.AnimPerformanceLoop)
	self:PlayAnimation(self.AnimComLoop)
	self.IsPerforming = false
	--- 重置VM的属性
	self.ViewModel:Reset()
	if self.ViewModel.IsEnoughForPerform then
		self:PlayAnimation(self.AnimPerformanceFocus)
		UIUtil.SetIsVisible(self.PanelPerformanceFocus, true)
	else
		UIUtil.SetIsVisible(self.PanelPerformanceFocus, false)
	end
end

function OpsConcertMainPanelView:OnHide()
	---抽奖过程中强制退出，可能导致侧边栏无法正常弹出
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsConcertMainPanel, false)
	if self.ClickSoundHandle then
		AudioUtil.StopAsyncAudioHandle(self.ClickSoundHandle)
	end
	if self.MusicSoundHandle then
		AudioUtil.StopAsyncAudioHandle(self.MusicSoundHandle)
	end
	_G.UE.UBGMMgr.Get():Resume()
	_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 1)
	local ViewModel = self.ViewModel
	if ViewModel then
		ViewModel:Reset()
	end
end

function OpsConcertMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.TabBtn1, self.OnClickMusicalNoteTab)
	UIUtil.AddOnClickedEvent(self,  self.TabBtn2, self.OnClickCallFriendTab)
	UIUtil.AddOnClickedEvent(self,  self.BtnPerformance, self.OnBtnPerformanceClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnRecallList, self.OnBtnRecallListClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnRecallMore, self.OnBtnInviteClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnMore, self.OnBtnMoreClick)
end

function OpsConcertMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnActivityUpdateInfo)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.MSDKDeliverMessageNotify, self.OnGameEventMSDKDeliverMessageNotify)
	self:RegisterGameEvent(EventID.OpcConcertLastLoginRolesUpdate, self.InitSocialFriendList)
	self:RegisterGameEvent(EventID.OpsConcertInvite, self.OnOpsConcertInvite)

end

function OpsConcertMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsConcertMainPanelView:TableViewRewardClicked(_, ItemData, ItemView)
	if ItemData.ItemID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
	end
end

function OpsConcertMainPanelView:OnClickMusicalNoteTab()
	self.ViewModel:SetMusicalNoteTabSelected()
end

function OpsConcertMainPanelView:OnClickCallFriendTab()
	self.ViewModel:SetCallFriendTabSelected()
end

function OpsConcertMainPanelView:OnOpsConcertInvite()
	if self.ViewModel ~= nil then
		_G.FLOG_INFO(" OpsConcertMainPanelView:OnOpsConcertInvite() 点击好友分享上报领取奖励")
		_G.OpsActivityMgr:SendActivityEventReport(NodeType.ActivityNodeTypeShareInviterCode, self.ViewModel.ShareParams)
	end
end

function OpsConcertMainPanelView:OnActivityUpdateInfo(MsgBody)
	if MsgBody == nil or MsgBody.NodeOperate == nil or MsgBody.NodeOperate.Result == nil then
		return
	end
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	--- 检查是否是拉回流活动的节点更新
	local ActivityDetail = MsgBody.NodeOperate.ActivityDetail
	if ViewModel.ActivityID ~= ActivityDetail.Head.ActivityID then
		return
	end
	local OpType = MsgBody.NodeOperate.OpType
	if OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeLotteryDrawNoLayBack then
		self:OnRecieveLotteryResult(MsgBody)
		return
	elseif OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypePullBindRole then
		self:OnRecieveBindRoleInfo(MsgBody)

	end
end

function OpsConcertMainPanelView:UpdateOriginDataShow()
	local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
	end

	self.ViewModel:Update(self.Params)
end

function OpsConcertMainPanelView:OnRecieveBindRoleInfo(MsgBody)
	local Result = MsgBody.NodeOperate.Result or {}
	local ParamsType = Result.Data or "BindAccount"
	local RoleData = Result[ParamsType] and Result[ParamsType].BindRole or {}
	self.ViewModel:SetInviteList(RoleData)
end

function OpsConcertMainPanelView:OnRecieveLotteryResult(MsgBody)
	local ViewModel = self.ViewModel
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsConcertMainPanel, true)
	ViewModel:UpdateLotteryCousume()
	--- 弹出抽奖结果
	local LotteryInfo = MsgBody.NodeOperate.Result
	local RewardItem = {}
	local Reward = LotteryInfo.LotteryDrawGetReward.LotteryDrawReward
	for _, Item in ipairs(Reward) do
		if Item.ItemID ~= self.ViewModel.LotteryPropID then
			table.insert(RewardItem,{ResID = Item.ItemID, Num =Item.ItemNum})
		end
	end
	local function BtnCB()
		_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsConcertMainPanel, false)
		ViewModel:UpdateRewardList(self.Params)
		UIViewMgr:HideView(UIViewID.CommonRewardPanel)
	end
	local VMList = UIBindableList.New(MailSlotItemViewVM)
	for _, V in pairs(RewardItem) do
		VMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
	end
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {Title = LSTR(740015), ItemVMList = VMList, CloseCallback = BtnCB})
end

function OpsConcertMainPanelView:OnBtnPerformanceClick()
	self.ClickSoundHandle = AudioUtil.LoadAndPlay2DSound(ClickSound)
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	local LotteryPropNum = _G.BagMgr:GetItemNum(ViewModel.LotteryPropID)
	if LotteryPropNum == nil  or ViewModel.LotteryConsumeNum == nil then
		return
	end
	if ViewModel.IsPerformComplete then
		MsgTipsUtil.ShowTips(LSTR(1600018)) --"已完成全部演奏"
		return
	end
	if self.IsPerforming then
		MsgTipsUtil.ShowTips(LSTR(1600028)) --"演奏进行中"
		return
	end
	if LotteryPropNum < ViewModel.LotteryConsumeNum then
		MsgTipsUtil.ShowTips(string.format(LSTR(1600014), ViewModel.LotteryConsumeNum)) --"演奏需积攒%d个乐章"
	else
		_G.LootMgr:SetDealyState(true)
		self:StopAnimation(self.AnimComLoop)
		self.IsPerforming = true
		self:PlayAnimation(self.AnimPerformanceLoop)
		--更新音效
		---暂停游戏本地的bgm
		_G.UE.UBGMMgr.Get():Pause()
		_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 0)
		self.MusicSoundHandle = AudioUtil.LoadAndPlay2DSound(MusicSound)
		self.ShowRewardTimer = self:RegisterTimer(function()
			self:StopAnimation(self.AnimPerformanceLoop)
			self:PlayAnimation(self.AnimComLoop)
			self.IsPerforming = false
			local Data = {NodeID = ViewModel.LotteryNodeID}
			_G.OpsActivityMgr:SendActivityNodeOperate(ViewModel.LotteryNodeID,ProtoCS.Game.Activity.NodeOpType.NodeOpTypeLotteryDrawNoLayBack,
			{LotteryDrawGetReward = Data})
			if self.MusicSoundHandle then
				AudioUtil.StopAsyncAudioHandle(self.MusicSoundHandle)
				self.MusicSoundHandle = nil
			end
			_G.UE.UBGMMgr.Get():Resume()
			_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 1)
		end, 6.0)
	end
end

function OpsConcertMainPanelView:OnBtnRecallListClick()
	DataReportUtil.ReportActivityFlowData("ConcertActionTypeClickFlow", tostring(self.Params.ActivityID), "2")
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	if not UIViewMgr:IsViewVisible(UIViewID.OpsConcertRecallWinView) then
		UIViewMgr:ShowView(UIViewID.OpsConcertRecallWinView,
			{ BindPlayerList = ViewModel.BindPlayerList, ActivityID = ViewModel.ActivityID, GetInviteListNodeID =
			ViewModel.GetInviteListNodeID })
	end
end

function OpsConcertMainPanelView:OnBtnInviteClick()
	DataReportUtil.ReportActivityFlowData("ConcertActionTypeClickFlow", tostring(self.Params.ActivityID), "4")
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	self:ShareMiniApp("sCode="..tostring(self.ViewModel.InviteCode), "")
end

function OpsConcertMainPanelView:OnGameEventMSDKDeliverMessageNotify(Notify)
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	if ViewModel.ShareRewardStatus and ViewModel.ShareRewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		_G.OpsActivityMgr:SendActivityEventReport(NodeType.ActivityNodeTypeShareInviterCode, self.ViewModel.ShareParams)
	end
    local RetCode = Notify[MSDKDefine.ClassMembers.BaseRet.RetCode]
	local MethodNameID = Notify[MSDKDefine.ClassMembers.BaseRet.MethodNameID]
	local RetMsg = Notify[MSDKDefine.ClassMembers.BaseRet.RetMsg]
	local ThirdCode = Notify[MSDKDefine.ClassMembers.BaseRet.ThirdCode]
	local ThirdMsg = Notify[MSDKDefine.ClassMembers.BaseRet.ThirdMsg]
	local ExtraJson = Notify[MSDKDefine.ClassMembers.BaseRet.ExtraJson]
	_G.FLOG_INFO("OpsConcertMainPanelView:OnGameEventMSDKDeliverMessageNotify, MethodNameID: %d, RetCode: %d, RetMsg: %s, ThirdCode: %d, ThirdMsg: %s, ExtraJson: %s, ActivityID: %d",
		MethodNameID, RetCode, RetMsg, ThirdCode, ThirdMsg, ExtraJson, self.Params.ActivityID)
end

function OpsConcertMainPanelView:InitSocialFriendList(FriendMap)
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	ViewModel:InitSocialFriendList(FriendMap)
end

function OpsConcertMainPanelView:OnBtnMoreClick()
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	ViewModel:UpdateSocialFriendList()
end

function OpsConcertMainPanelView:ShareMiniApp(Params, UserOpenID)
	_G.FLOG_INFO("拉起小程序")
	if _G.LoginMgr:IsQQLogin() then
		if not AccountUtil.IsQQInstalled() then
			MsgTipsUtil.ShowTips(LSTR(1600030)) --"未安装应用"
			return
		end
		_G.FLOG_INFO("是QQ")
		local DynamicData = {}
        DynamicData.prompt = LSTR(1600031)
        DynamicData.title = LSTR(1600001)
        DynamicData.desc = LSTR(1600032)
        DynamicData.preview = QQMiniAppCfg.TumbPath
        DynamicData.jumpUrl = QQMiniAppCfg.Link..Params
        local DynamicParams = Json.encode(DynamicData)
        _G.FLOG_INFO(string.format("DynamicParams:%s", DynamicParams))

        _G.ShareMgr:GetArkInfo(nil, DynamicParams)
		-- AccountUtil.SendQQMiniApp(UserOpenID or "",
		-- 	self.QQMiniAppCfg.Link,
		-- 	self.QQMiniAppCfg.Title,
		-- 	self.QQMiniAppCfg.Desc,
		-- 	self.QQMiniAppCfg.TumbPath,
		-- 	self.QQMiniAppCfg.AppID,
		-- 	self.QQMiniAppCfg.Path,
		-- 	"",
		-- 	3)
	elseif _G.LoginMgr:IsWeChatLogin() then
		if not AccountUtil.IsWeChatInstalled() then
			MsgTipsUtil.ShowTips(LSTR(1600030)) --"未安装应用"
			return
		end
		local Path = WeChatMiniAppCfg.Link..Params
		AccountUtil.SendWechatMiniApp(UserOpenID or "",
			Path,
			WeChatMiniAppCfg.TumbPath,
			WeChatMiniAppCfg.AppID,
			0,
			"MSG_INVITE",
			Path,
			"")
	end
end

function OpsConcertMainPanelView:OnMusicalNoteChanged(CurrentNum)
	CurrentNum = CurrentNum or 0
	for i = 1, CurrentNum do
		if i > #self.NoteList then
			return
		end
		UIUtil.SetIsVisible(self.NoteList[i].IconNoteFocus, true)
		UIUtil.SetIsVisible(self.NoteList[i].IconNoteNormal, false)
	end
	for i = CurrentNum + 1, #self.NoteList do
		UIUtil.SetIsVisible(self.NoteList[i].IconNoteFocus, false)
		UIUtil.SetIsVisible(self.NoteList[i].IconNoteNormal, true)
	end
end

function OpsConcertMainPanelView:InitNoteList()
	local BrightPathString = "PaperSprite'/Game/UI/Atlas/Ops/OpsConcert/Frames/UI_OpsConcert_Img_Note_Bright%d_png.UI_OpsConcert_Img_Note_Bright%d_png'" 
	local DarkPathString = "PaperSprite'/Game/UI/Atlas/Ops/OpsConcert/Frames/UI_OpsConcert_Img_Note_Dark%d_png.UI_OpsConcert_Img_Note_Dark%d_png'"
	for i, Note in ipairs(self.NoteList) do
		UIUtil.ImageSetBrushFromAssetPath(Note.IconNoteNormal, DarkPathString:format(i, i))
		UIUtil.ImageSetBrushFromAssetPath(Note.IconNoteFocus, BrightPathString:format(i, i))
	end
end
return OpsConcertMainPanelView