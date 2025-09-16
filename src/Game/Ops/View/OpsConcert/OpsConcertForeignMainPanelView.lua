---
--- Author: usakizhang
--- DateTime: 2025-03-26 17:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsConcertMainPanelVM = require("Game/Ops/VM/OpsConcert/OpsConcertMainPanelVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")
local CommonUtil = require("Utils/CommonUtil")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local UIViewID = require("Define/UIViewID")
local AudioUtil = require("Utils/AudioUtil")
local NodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
---@class OpsConcertForeignMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnConfirm CommBtnMView
---@field BtnCopy UFButton
---@field BtnInviteFriends CommBtnMView
---@field BtnPerformance UFButton
---@field InputBoxPhoneNumber CommInputBoxView
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
---@field PanelList UFCanvasPanel
---@field PanelPerformanceFocus UFCanvasPanel
---@field PanelPerformanceNormal UFCanvasPanel
---@field PanelRecallFriends UFCanvasPanel
---@field RichTextQuantity URichTextBox
---@field TabBtn1 UToggleButton
---@field TabBtn2 UToggleButton
---@field TableViewGetList UTableView
---@field TableViewSlot UTableView
---@field Text1TabNormal UFTextBlock
---@field Text1TabSelect UFTextBlock
---@field Text2TabNormal UFTextBlock
---@field Text2TabSelect UFTextBlock
---@field TextBinding UFTextBlock
---@field TextExplain UFTextBlock
---@field TextInviteCode UFTextBlock
---@field TextInviteCode1 UFTextBlock
---@field TextPerformance UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimComLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPerformanceLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertForeignMainPanelView = LuaClass(UIView, true)
local ClickSound = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Play_Activity_Return_click.Play_Activity_Return_click'"
local MusicSound = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Play_Activity_Return_start.Play_Activity_Return_start'"
function OpsConcertForeignMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnConfirm = nil
	--self.BtnCopy = nil
	--self.BtnInviteFriends = nil
	--self.BtnPerformance = nil
	--self.InputBoxPhoneNumber = nil
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
	--self.PanelList = nil
	--self.PanelPerformanceFocus = nil
	--self.PanelPerformanceNormal = nil
	--self.PanelRecallFriends = nil
	--self.RichTextQuantity = nil
	--self.TabBtn1 = nil
	--self.TabBtn2 = nil
	--self.TableViewGetList = nil
	--self.TableViewSlot = nil
	--self.Text1TabNormal = nil
	--self.Text1TabSelect = nil
	--self.Text2TabNormal = nil
	--self.Text2TabSelect = nil
	--self.TextBinding = nil
	--self.TextExplain = nil
	--self.TextInviteCode = nil
	--self.TextInviteCode1 = nil
	--self.TextPerformance = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.AnimComLoop = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimPerformanceLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertForeignMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnInviteFriends)
	self:AddSubView(self.InputBoxPhoneNumber)
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

function OpsConcertForeignMainPanelView:OnInit()
	self.ViewModel = OpsConcertMainPanelVM.New()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewSlot)
	self.RewardListAdapter:SetOnClickedCallback(self.TableViewRewardClicked)
	self.TaskListAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewGetList)

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
		{"CallFriendTabSelected", UIBinderSetIsVisible.New(self, self.PanelRecallFriends)},
		{"InviteCode", UIBinderSetText.New(self, self.TextInviteCode1)},
		{ "IsBind", UIBinderValueChangedCallback.New(self, nil, self.OnBindStateChanged) },
	}
	self.NoteList = {
		self.Note1, self.Note2, self.Note3, self.Note4, self.Note5, self.Note6, self.Note7, self.Note8, self.Note9, self.Note10
	}
	self.ClickSoundHandle = nil
	self.MusicSoundHandle = nil
	--- 设置演奏Icon
	self:InitNoteList()
end

function OpsConcertForeignMainPanelView:OnDestroy()
	self.ViewModel = nil
end

function OpsConcertForeignMainPanelView:OnShow()
	self.TextTitle:SetText(LSTR(1600001)) --萌神演奏会
	self.TextSubTitle:SetText(LSTR(1600002)) --召集回归冒险者登陆游戏，赢取库啵好礼！
	self.TextExplain:SetText(LSTR(1600004)) --积攒音符演奏曲谱，随机获得1次演出奖品
	self.Text1TabSelect:SetText(LSTR(1600005)) --获取乐章
	self.Text1TabNormal:SetText(LSTR(1600005)) --获取乐章
	self.Text2TabSelect:SetText(LSTR(1600006)) --召回好友
	self.Text2TabNormal:SetText(LSTR(1600006)) --召回好友
	self.TextInviteCode:SetText(LSTR(1600011)) --绑定召回玩家
	self.TextBinding:SetText(LSTR(1600012)) --绑定账号
	self.BtnInviteFriends:SetText(LSTR(1600009)) --邀请好友
	self.InputBoxPhoneNumber:SetHintText(LSTR(1600021)) --请输入被召回玩家的绑定账号
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
	else
		UIUtil.SetIsVisible(self.PanelPerformanceFocus, false)
	end
end

function OpsConcertForeignMainPanelView:OnHide()
	---抽奖过程中强制退出，可能导致侧边栏无法正常弹出
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsConcertMainPanel, false)
	if self.ClickSoundHandle then
		AudioUtil.StopAsyncAudioHandle(self.ClickSoundHandle)
	end
	if self.BackgroundSoundHandle then
		AudioUtil.StopAsyncAudioHandle(self.BackgroundSoundHandle)
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

function OpsConcertForeignMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.TabBtn1, self.OnClickMusicalNoteTab)
	UIUtil.AddOnClickedEvent(self,  self.TabBtn2, self.OnClickCallFriendTab)
	UIUtil.AddOnClickedEvent(self,  self.BtnPerformance, self.OnBtnPerformanceClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnCopy, self.OnBtnBtnCopyClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnConfirm, self.OnBtnConfirmClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnInviteFriends, self.OnBtnShareClick)
end

function OpsConcertForeignMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnActivityUpdateInfo)
end

function OpsConcertForeignMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end
function OpsConcertForeignMainPanelView:TableViewRewardClicked(_, ItemData, ItemView)
	if ItemData.ItemID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
	end
end

function OpsConcertForeignMainPanelView:OnClickMusicalNoteTab()
	self.ViewModel:SetMusicalNoteTabSelected()
end

function OpsConcertForeignMainPanelView:OnClickCallFriendTab()
	self.ViewModel:SetCallFriendTabSelected()
end

function OpsConcertForeignMainPanelView:OnActivityUpdateInfo(MsgBody)
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
	elseif OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeBindCallCode then
		self:OnRecieveBindCallCode(MsgBody)
	end
end

function OpsConcertForeignMainPanelView:OnRecieveBindRoleInfo(MsgBody)
	local Result = MsgBody.NodeOperate.Result or {}
	local ParamsType = Result.Data or "BindAccount"
	local RoleData = Result[ParamsType] and Result[ParamsType].BindRole or {}
	self.ViewModel:SetInviteList(RoleData)
end

function OpsConcertForeignMainPanelView:OnRecieveLotteryResult(MsgBody)
	local ViewModel = self.ViewModel
	_G.LootMgr:SetDealyState(true)
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsConcertForeignMainPanel, true)
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
		_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsConcertForeignMainPanel, false)
		ViewModel:UpdateRewardList(self.Params)
		UIViewMgr:HideView(UIViewID.CommonRewardPanel)
	end
	local VMList = UIBindableList.New(ItemVM)
	for _, V in pairs(RewardItem) do
		VMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
	end
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {Title = LSTR(740015), ItemVMList = VMList, CloseCallback = BtnCB})
end

function OpsConcertForeignMainPanelView:OnRecieveBindCallCode(MsgBody)
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	local ActivityDetail = MsgBody.ActivityDetail or {}
	local Nodes = ActivityDetail.Nodes or {}
	for _, Node in ipairs(Nodes) do
		if Node.Head.NodeID == ViewModel.BindeCodeNodeID then
			local IsBind = not string.isnilorempty(Node.Extra.BindCode.Code)
			self.ViewModel.IsBind = IsBind
			if IsBind then
				MsgTipsUtil.ShowTips(LSTR(1600024)) --"绑定成功"
			else
				MsgTipsUtil.ShowTips(LSTR(1600025)) --"绑定失败"
			end
		end
	end
end

function OpsConcertForeignMainPanelView:OnBindStateChanged(IsBind)
	if not IsBind then
		self.BtnConfirm:SetText(LSTR(1600010)) --确定绑定
		self.BtnConfirm:SetIsEnabled(true, true)
	else
		self.BtnConfirm:SetText(LSTR(1600025)) --已解绑
		self.BtnConfirm:SetIsEnabled(false, false)
		self.InputBoxPhoneNumber:SetText(self.ViewModel.BindCode)
		self.InputBoxPhoneNumber:SetIsReadOnly(true)
	end
end
function OpsConcertForeignMainPanelView:OnBtnPerformanceClick()
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

function OpsConcertForeignMainPanelView:OnBtnRecallListClick()
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

function OpsConcertForeignMainPanelView:OnBtnBtnCopyClick()
	CommonUtil.ClipboardCopy(self.TextInviteCode1:GetText())
	MsgTipsUtil.ShowTips(LSTR(1600022)) --"邀请码已复制"
end

function OpsConcertForeignMainPanelView:OnBtnConfirmClick()
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	local Text = self.InputBoxPhoneNumber:GetText()
	if string.isnilorempty(Text) then
		MsgTipsUtil.ShowTips(LSTR(1600023)) --"未输入邀请码"
		return
	end
	--- 进行邀请码绑定的节点操作
	local Data = {InviterCode = Text}
	_G.OpsActivityMgr:SendActivityNodeOperate(ViewModel.BindeCodeNodeID,ProtoCS.Game.Activity.NodeOpType.NodeOpTypeBindCallCode,
	{BindInviterCode = Data})
end

function OpsConcertForeignMainPanelView:OnBtnShareClick()
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	if ViewModel.ShareRewardStatus and ViewModel.ShareRewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		_G.OpsActivityMgr:SendActivityEventReport(NodeType.ActivityNodeTypeShareInviterCode, self.ViewModel.NodeID)
	end
	---海外分享待接入
end
function OpsConcertForeignMainPanelView:OnMusicalNoteChanged(CurrentNum)
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
function OpsConcertForeignMainPanelView:InitNoteList()
	local BrightPathString = "PaperSprite'/Game/UI/Atlas/Ops/OpsConcert/Frames/UI_OpsConcert_Img_Note_Bright%d_png.UI_OpsConcert_Img_Note_Bright%d_png'" 
	local DarkPathString = "PaperSprite'/Game/UI/Atlas/Ops/OpsConcert/Frames/UI_OpsConcert_Img_Note_Dark%d_png.UI_OpsConcert_Img_Note_Dark%d_png'"
	for i, Note in ipairs(self.NoteList) do
		UIUtil.ImageSetBrushFromAssetPath(Note.IconNoteNormal, DarkPathString:format(i, i))
		UIUtil.ImageSetBrushFromAssetPath(Note.IconNoteFocus, BrightPathString:format(i, i))
	end
end
return OpsConcertForeignMainPanelView