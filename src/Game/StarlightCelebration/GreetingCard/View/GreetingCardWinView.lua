---
--- Author: Administrator
--- DateTime: 2025-06-30 14:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local LightDefine = require("Game/Light/LightDefine")

local EventID = require("Define/EventID")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local GreetingCardDefine = require("Game/StarlightCelebration/GreetingCard/GreetingCardDefine")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")


local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local FriendVM = require("Game/Social/Friend/FriendVM")
local GreetingCardWinVM = require("Game/StarlightCelebration/GreetingCard/VM/GreetingCardWinVM")


local ActivtyNodeID = 2507210103    -- 星芒节活动贺卡节点ID
local PostmanNPCID = 1001174
local SceneCenter = LightDefine.LightLevelCreateLocation[LightDefine.LightLevelID.LIGHT_LEVEL_ID_EMAIL]
local LSTR = _G.LSTR
local OpsActivityMgr = _G.OpsActivityMgr

---@class GreetingCardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAddLimit UFButton
---@field BtnClose UFButton
---@field BtnGift CommBtnLView
---@field BtnReceive CommBtnLView
---@field CommEmpty CommBackpackEmptyView
---@field CommonModelToImage CommonModelToImageView
---@field DropDownFilter CommDropDownListView
---@field HorizontalPrice UFHorizontalBox
---@field ImgBlackBg_1 UFImage
---@field ImgMoney UFImage
---@field MultilineInputBox CommMultilineInputBoxView
---@field PanelGiftBtns UFCanvasPanel
---@field PanelLackStyle UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelMail UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field PortraitNode CommonPlayerPortraitItemView
---@field RichTextLimit URichTextBox
---@field SearchBar CommSearchBarView
---@field SkillHandleCloseBtn SkillHandleCloseBtnView
---@field Spine_Store_Mail USpineWidget
---@field Spine_Store_Mail_Flower USpineWidget
---@field Spine_Store_Mail_Front USpineWidget
---@field TableViewFriendList UTableView
---@field TableViewMailStyle UTableView
---@field TextCurrentPrice UFTextBlock
---@field TextDate UFTextBlock
---@field TextEditTips UFTextBlock
---@field TextFromName UFTextBlock
---@field TextLackStyle UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextTitle UFTextBlock
---@field TextToName UFTextBlock
---@field AnimPack UWidgetAnimation
---@field AnimShow UWidgetAnimation
---@field AnimUnpack UWidgetAnimation
---@field ModelDistance float
---@field ModelHeight float
---@field ModelYaw float
---@field ModelPitch float
---@field ModelPan float
---@field ModelAnimationPath text
---@field CurveModelDistance CurveFloat
---@field CurveModelHeight CurveFloat
---@field CurveModelYaw CurveFloat
---@field CurveModelPitch CurveFloat
---@field CurveModelPan CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GreetingCardWinView = LuaClass(UIView, true)

function GreetingCardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAddLimit = nil
	--self.BtnClose = nil
	--self.BtnGift = nil
	--self.BtnReceive = nil
	--self.CommEmpty = nil
	--self.CommonModelToImage = nil
	--self.DropDownFilter = nil
	--self.HorizontalPrice = nil
	--self.ImgBlackBg_1 = nil
	--self.ImgMoney = nil
	--self.MultilineInputBox = nil
	--self.PanelGiftBtns = nil
	--self.PanelLackStyle = nil
	--self.PanelList = nil
	--self.PanelMail = nil
	--self.PanelOriginal = nil
	--self.PortraitNode = nil
	--self.RichTextLimit = nil
	--self.SearchBar = nil
	--self.SkillHandleCloseBtn = nil
	--self.Spine_Store_Mail = nil
	--self.Spine_Store_Mail_Flower = nil
	--self.Spine_Store_Mail_Front = nil
	--self.TableViewFriendList = nil
	--self.TableViewMailStyle = nil
	--self.TextCurrentPrice = nil
	--self.TextDate = nil
	--self.TextEditTips = nil
	--self.TextFromName = nil
	--self.TextLackStyle = nil
	--self.TextOriginalPrice = nil
	--self.TextTitle = nil
	--self.TextToName = nil
	--self.AnimPack = nil
	--self.AnimShow = nil
	--self.AnimUnpack = nil
	--self.ModelDistance = nil
	--self.ModelHeight = nil
	--self.ModelYaw = nil
	--self.ModelPitch = nil
	--self.ModelPan = nil
	--self.ModelAnimationPath = nil
	--self.CurveModelDistance = nil
	--self.CurveModelHeight = nil
	--self.CurveModelYaw = nil
	--self.CurveModelPitch = nil
	--self.CurveModelPan = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GreetingCardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.BtnReceive)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommonModelToImage)
	self:AddSubView(self.DropDownFilter)
	self:AddSubView(self.MultilineInputBox)
	self:AddSubView(self.PortraitNode)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SkillHandleCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GreetingCardWinView:OnInit()
	self.TableAdapterFriendList = UIAdapterTableView.CreateAdapter(self, self.TableViewFriendList)
	self.AdapterMailStyle = UIAdapterTableView.CreateAdapter(self, self.TableViewMailStyle, self.OnMailStyleSeceltedChanged, true, false)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)

	local ActivityNode = ActivityNodeCfg:FindCfgByKey(ActivtyNodeID) or {}
	self.BuyGiftGoldCoinNum = (ActivityNode.Params or {})[3] or 0

	self.MainBinders =
	{
		{ "FriendItemVMList", 				UIBinderUpdateBindableList.New(self, self.TableAdapterFriendList) },
		{ "CardStyleList", 					UIBinderUpdateBindableList.New(self, self.AdapterMailStyle) },

		{ "ShowMode",                      UIBinderValueChangedCallback.New(self, nil, self.OnShowModeChanged) },
		{ "TextTitle", 					   UIBinderSetText.New(self, self.TextTitle) },
		{ "FriendListCommEmptyVisible", 	UIBinderSetIsVisible.New(self, self.CommEmpty) },
	}
	self.CanGiftNum = -1
	self.SendGreetingCardTimes = -1
	self.MultilineInputBox:SetCallback(self, self.MultilineInputBoxChangeCallback)
	self:GreetingCardStyleShowChanged(1)
end

function GreetingCardWinView:MultilineInputBoxChangeCallback()
	local IsEnabled = not self.MultilineInputBox:CheckTextOverLimit(nil, false)
	self.BtnReceive:SetIsEnabled(IsEnabled, IsEnabled)
end

function GreetingCardWinView:OnDestroy()

end

function GreetingCardWinView:UIActorInit()
	local UActorManager = _G.UE.UActorManager.Get()
	local Rotation = _G.UE.FRotator(0, 0, 0)
	local Params = _G.UE.FCreateClientActorParams()
	self.CreatedNPCEntityID = UActorManager:CreateClientActorByParams(_G.UE.EActorType.Npc, 0, PostmanNPCID, SceneCenter, Rotation, Params)
	_G.LightMgr:LoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_MAIL, LightDefine.LightLevelCreateLocation[LightDefine.LightLevelID.LIGHT_LEVEL_ID_EMAIL])
end

function GreetingCardWinView:TranslatedText()
	self.TextEditTips:SetText(LSTR(1670005))     --（点击可进行编辑）
	self.CommEmpty:SetTipsContent(LSTR(1670001)) -- 暂无搜索结果
	self.SearchBar:SetHintText(LSTR(950089))     -- 搜索好友
	self.DefaultGreetingMsg = LSTR(1670018)		 -- "	今天是你的生日。。。"
end

function GreetingCardWinView:OnShow()
	local Params = self.Params or {}
	if Params.StarlightViewEnter then
		self:PlayAnimation(self.AnimShow)
		self:UIActorInit()
	else
		if Params.FirstOpenBrowsing then
			self:PlayAnimation(self.AnimUnpack)
		else
			self:PlayAnimation(self.AnimShow)
		end
	end

	self:TranslatedText()

	FriendVM:FilterFriendVMByGroupID(FriendDefine.AllGroupID)
	GreetingCardWinVM:UpdateFriendList()

	self:UpdateDropDownListItems(1)
	self:OpsActivityUpdateInfo()
end

function GreetingCardWinView:OnHide()
	local Params = self.Params or {}
	if Params.StarlightViewEnter then
		if self.CreatedNPCEntityID then
			_G.UE.UActorManager.Get():RemoveClientActor(self.CreatedNPCEntityID)
		end
		_G.LightMgr:UnLoadLightLevel(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_MAIL)
	end
end

function GreetingCardWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownFilter, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnClickedEvent(self, self.BtnAddLimit, self.OnBtnAddLimitClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClick)
	UIUtil.AddOnClickedEvent(self, self.BtnReceive, self.OnBtnReceiveClick)
end

function GreetingCardWinView:SequenceEvent_SetModelCamera()
	self:SetModelCameraValue()
	self.CommonModelToImage:SetDistance(self.ModelDistance)
	self.CommonModelToImage:SetHightOffset(self.ModelHeight)
	self.CommonModelToImage:SetPitchAngle(self.ModelPitch)
	self.CommonModelToImage:SetYawAngle(self.ModelYaw)
	self.CommonModelToImage:SetPan(self.ModelPan)
end

function GreetingCardWinView:SequenceEvent_SetModelAnimation(lPathIndex)
	self:SetModelAnimationPathValue(lPathIndex)
	local Actor = ActorUtil.GetActorByEntityID(self.CreatedNPCEntityID)
	if (Actor ~= nil) then
		local AnimationComponent = Actor:GetAnimationComponent()
		if self.MainPanelResidentAnimMontage ~= nil then
			AnimationComponent:StopMontage(self.MainPanelResidentAnimMontage)
			self.MainPanelResidentAnimMontage = nil
		end
		local ModelAnimationObj = _G.ObjectMgr:LoadObjectSync(self.ModelAnimationPath, ObjectGCType.LRU)
		self.MainPanelResidentAnimMontage = AnimationComponent:PlaySequenceToMontage(ModelAnimationObj, "WholeBody", nil, nil, 1.0, 0.25, 0.25, nil, 10000000, true)
	end
end

function GreetingCardWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OpsActivityUpdateInfo)
end

function GreetingCardWinView:SendEndAnim()
	self:PlayAnimation(self.AnimPack)
	local Actor = ActorUtil.GetActorByEntityID(self.CreatedNPCEntityID)
	if(Actor ~= nil)then
		self.CommonModelToImage:Show(Actor, nil, SceneCenter, {X=512, Y=512})
		Actor:GetAvatarComponent():SetForcedLODForAll(0)
	end
	local AnimDuringTime = self.Animpack:GetEndTime()
	self:RegisterTimer(function() self:Hide() end, AnimDuringTime, 0, 1)
end

function GreetingCardWinView:OpsActivityUpdateInfo(MsgBody)
	local IsEvent = MsgBody ~= nil
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(25072101)
	if NodeData and NodeData.NodeList then
		local NodeList = NodeData.NodeList or {}
		for i = 1, #NodeList do
			if NodeList[i].Head.NodeID == ActivtyNodeID then
				local NodeExtraStarDaySendGreetingCard = NodeList[i].Extra or {}
				local CanGiftNum = (NodeExtraStarDaySendGreetingCard.StarDaySendGreetingCard or {}).RemainSendGreetingTimes or 0
				local SendGreetingCardTimes = (NodeExtraStarDaySendGreetingCard.StarDaySendGreetingCard or {}).SendGreetingCardTimes or 0
				if CanGiftNum > self.CanGiftNum and IsEvent then
					MsgTipsUtil.ShowTips(LSTR(1670008))		--"赠送数量+1"
				end
				if SendGreetingCardTimes > self.SendGreetingCardTimes and IsEvent then
					self:SendEndAnim()
					MsgTipsUtil.ShowTips(LSTR(1670004))		--"赠送成功"
				end
				self.SendGreetingCardTimes = SendGreetingCardTimes
				self.CanGiftNum = CanGiftNum
			end
		end
	end
	self:RemainingQuotaText()
end

function GreetingCardWinView:OnRegisterBinder()
	self:RegisterBinders(GreetingCardWinVM, self.MainBinders)
end

function GreetingCardWinView:OnShowModeChanged(NewValue, OldValue)
	self.PortraitNode:SetParams(nil)
	if NewValue == GreetingCardDefine.ShowMode.ChoosingFriends then
		self.PortraitNode:SetParams({ Data = {RoleID = MajorUtil.GetMajorRoleID()}})
		self.TextTitle:SetText(LSTR(1670003))			--"选择好友赠送"
		UIUtil.SetIsVisible(self.PanelMail, false)
		UIUtil.SetIsVisible(self.PanelList, true)
		UIUtil.SetIsVisible(self.TableViewMailStyle, true, true)
	elseif NewValue == GreetingCardDefine.ShowMode.EditingCard then
		self.BtnReceive:SetBtnName(LSTR(1670016))  		--"赠 送"
		self.TextTitle:SetText(LSTR(1670002))			--"赠送贺卡"
		UIUtil.SetIsVisible(self.PanelMail, true)
		UIUtil.SetIsVisible(self.PanelList, false)
		UIUtil.SetIsVisible(self.TableViewMailStyle, true, true)

		UIUtil.SetIsVisible(self.MultilineInputBox.RichTextNumber, true)
		UIUtil.SetIsVisible(self.TextEditTips, true)
		UIUtil.SetIsVisible(self.BtnReceive, true, true)
		self.MultilineInputBox:SetIsReadOnly(false)

		local FriendName = ""
		if (GreetingCardWinVM.CurFriendRoleID or 0) ~= 0 then
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(tonumber(GreetingCardWinVM.CurFriendRoleID), true) or {}
			FriendName = RoleVM.Name or ""
		end
		self.TextToName:SetText(LSTR(1670014) .. FriendName)    --- 亲爱的:
		self.TextFromName:SetText(LSTR(1670015) .. MajorUtil.GetMajorName())   --- 来自:
		self.TextDate:SetText(TimeUtil.GetServerTimeFormat(LSTR(1670017))) 	   --"%Y年%m月%d日"
		self.MultilineInputBox:SetText(self.DefaultGreetingMsg)
	elseif NewValue == GreetingCardDefine.ShowMode.BrowsingCard then
		local BrowsingCardData = GreetingCardWinVM.BrowsingCardData

		UIUtil.SetIsVisible(self.PanelMail, true)
		UIUtil.SetIsVisible(self.PanelList, false)
		UIUtil.SetIsVisible(self.TableViewMailStyle, false)

		self.MultilineInputBox:SetIsReadOnly(true)
		UIUtil.SetIsVisible(self.MultilineInputBox.RichTextNumber, false)
		UIUtil.SetIsVisible(self.TextEditTips, false)
		UIUtil.SetIsVisible(self.BtnReceive, not BrowsingCardData.Readed, false == BrowsingCardData.Readed)

		self.TextToName:SetText(LSTR(1670014) .. (BrowsingCardData.ReceiverName or ""))    --- 亲爱的:
		self.TextFromName:SetText(LSTR(1670015) .. (BrowsingCardData.SenderName or ""))   --- 来自:
		self.MultilineInputBox:SetText(BrowsingCardData.GiftMessage or "")
		self.TextTitle:SetText(LSTR(1670009))      --"贺卡"
		self.BtnReceive:SetBtnName(LSTR(1670010))  --"收下贺卡"
		self.TextDate:SetText(TimeUtil.GetTimeFormat(LSTR(1670017), BrowsingCardData.GiftTime or 0))  --"%Y年%m月%d日"

		self:GreetingCardStyleShowChanged(BrowsingCardData.StyleID or 1)
		self.PortraitNode.RoleVM = BrowsingCardData.SenderRoleVM
		self.PortraitNode:SetPortraitUrlFlag(BrowsingCardData.URL or "")
	end
end

function GreetingCardWinView:OnMailStyleSeceltedChanged(Index, ItemData, ItemView)
	GreetingCardWinVM:SwitchCardStyle(Index)
	self:GreetingCardStyleShowChanged(Index)
end

function GreetingCardWinView:GreetingCardStyleShowChanged(StyleID)
	if StyleID == 1 then
		self.Spine_Store_Mail:SetSkin("Holiday")
		self.Spine_Store_Mail_Front:SetSkin("Holiday")
		self.Spine_Store_Mail_Flower:SetSkin("Holiday")
	elseif StyleID == 2 then
		self.Spine_Store_Mail:SetSkin("Store")
		self.Spine_Store_Mail_Front:SetSkin("Store")
		self.Spine_Store_Mail_Flower:SetSkin("Store")
	end
end

---@param SearchText string @回调的文本
function GreetingCardWinView:OnSearchTextCommitted(SearchText)
	self.DropDownFilter:ResetDropDown()
	if not string.isnilorempty(SearchText) then
		FriendVM:FilterFriendByKeyword(SearchText)
		GreetingCardWinVM:UpdateFriendList()
	else
		self:OnClickCancelSearchBar()
	end
	self:PlayAnimation(self.AnimUpdateFriendList)
end

function GreetingCardWinView:OnClickCancelSearchBar()
	self.SearchBar:SetText("")
	FriendVM:ClearFilterData()

	GreetingCardWinVM:UpdateFriendList()
end

function GreetingCardWinView:OnSelectionChangedDropDownList(Index, _, _, bIsByClick)
	if nil == self.DropDownListData or nil == Index or self.CurDropDownIdx == Index then
		return
	end
	if not bIsByClick then
		return
	end
	self:PlayAnimation(self.AnimUpdateFriendList)
	self.CurDropDownIdx = Index
	local GroupID = (self.DropDownListData[Index] or {}).GroupID
	if GroupID then
		FriendVM:FilterFriendVMByGroupID(GroupID)
		self.SearchBar:SetText("")
		GreetingCardWinVM:UpdateFriendList()
	end
end

function GreetingCardWinView:UpdateDropDownListItems(Index)
	local ListData = FriendVM:GetDropDownItems() or {}
	table.remove_item(ListData, FriendDefine.BlackGroupID, "GroupID")
	self.DropDownFilter:UpdateItems(ListData, Index or self.CurDropDownIdx)

	self.DropDownListData = ListData
end

function GreetingCardWinView:RemainingQuotaText()
	self.RichTextLimit:SetText(LSTR(1670006) .. tostring(self.CanGiftNum))  -- "剩余可赠送次数："
end

function GreetingCardWinView:OnBtnCloseClick()
	if GreetingCardWinVM.ShowMode == GreetingCardDefine.ShowMode.EditingCard then
		GreetingCardWinVM:OpenChoosingFriendsPanel()
	else
		self:Hide()
	end
end

function GreetingCardWinView:OnBtnReceiveClick()
	if GreetingCardWinVM.ShowMode == GreetingCardDefine.ShowMode.BrowsingCard then
		_G.MailMainVM:ReceiveGreetingCard()
		self:Hide()
	elseif GreetingCardWinVM.ShowMode == GreetingCardDefine.ShowMode.EditingCard then
		local ReqData = {
			RecipientRoleID = GreetingCardWinVM.CurFriendRoleID,
			StyleID = GreetingCardWinVM.SelectedCardStyleIndex,
			Text = self.MultilineInputBox:GetText(),
			ProfID = MajorUtil.GetMajorProfID(),
		}
		local NodeOpType = ProtoCS.Game.Activity.NodeOpType.NodeOpTypeStarDaySendGreetingCard
		OpsActivityMgr:SendActivityNodeOperate(ActivtyNodeID, NodeOpType, {StarDaySendGreetingCardReq = ReqData})
	end
end

function GreetingCardWinView:OnBtnAddLimitClick()
	local BackToGame = function()
		if self.MsgBoxView ~= nil then
			self.MsgBoxView:Hide()
			self.MsgBoxView = nil
		end
	end

	local ConfirmFun = function()
		if self.MsgBoxView ~= nil then
			self.MsgBoxView:Hide()
			self.MsgBoxView = nil
			--增加 赠送次数
			local NodeOpType = ProtoCS.Game.Activity.NodeOpType.NodeOpTypeStarDayBuySendGreetingTimes
			OpsActivityMgr:SendActivityNodeOperate(ActivtyNodeID, NodeOpType, { StarDayBuySendGreetingTimesReq = {Num = 1} })
		end
	end

	local Params = {CostNum = self.BuyGiftGoldCoinNum, CostItemID = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE }
	self.MsgBoxView = MsgBoxUtil.ShowMsgBoxTwoOp(self , LSTR(1670011), string.sformat(LSTR(1670012), tostring(self.BuyGiftGoldCoinNum)), 
		ConfirmFun, BackToGame,  LSTR(10003), LSTR(10002), Params)
end

return GreetingCardWinView