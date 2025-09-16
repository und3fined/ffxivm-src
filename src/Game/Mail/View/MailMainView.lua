local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MailDefine = require("Game/Mail/MailDefine")
local MailMgr = require("Game/Mail/MailMgr")
local MailMainVM = require("Game/Mail/View/MailMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ActorUtil = require("Utils/ActorUtil")
local ObjectGCType = require("Define/ObjectGCType")
local AudioUtil = require("Utils/AudioUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreUtil = require("Game/Store/StoreUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local QuestHelper = require("Game/Quest/QuestHelper")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local CHAPTER_STATUS =  QuestDefine.CHAPTER_STATUS
local MailType = MailDefine.MailType
local MailTypeInfo = MailDefine.MailTypeInfo
local LSTR = _G.LSTR

---@class MailMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnDelete CommBtnMView
---@field BtnDeleteMail CommBtnLView
---@field BtnGet CommBtnLView
---@field BtnGetAll CommBtnMView
---@field BtnModel UFButton
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonModelToImage CommonModelToImageView
---@field CommonTitle CommonTitleView
---@field GiftPage MailGiftPageView
---@field ImgBGItem01 UFImage
---@field ImgBGItem03 UFImage
---@field ImgMentorIcon UFImage
---@field ModelAdjustUI_106 ModelAdjustUIView
---@field PanelAdventuring UFCanvasPanel
---@field PanelAdventuring02 UFCanvasPanel
---@field PanelBGItem UFCanvasPanel
---@field PanelBtnModel UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelMailContent01 UFCanvasPanel
---@field PanelMailContent02 UFCanvasPanel
---@field PanelMentor UFCanvasPanel
---@field PanelReward UFCanvasPanel
---@field PanelReward02 UFCanvasPanel
---@field RichTextBy URichTextBox
---@field RichTextBy02 URichTextBox
---@field RichTextCountDown URichTextBox
---@field RichTextCountDown_1 URichTextBox
---@field RichTextDate URichTextBox
---@field RichTextDate02 URichTextBox
---@field RichTextMailContent URichTextBox
---@field RichTextMailContent02 URichTextBox
---@field Spine_LetterIn USpineWidget
---@field TableViewMailList UTableView
---@field TableViewReward UTableView
---@field TableViewReward02 UTableView
---@field TextEmpty UFTextBlock
---@field TextMailTitle UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTItleTips URichTextBox
---@field TextTitle UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimChangeListItem UWidgetAnimation
---@field AnimChangeTab UWidgetAnimation
---@field AnimGiftBack UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimIn3 UWidgetAnimation
---@field AnimIn4 UWidgetAnimation
---@field AnimInModel1 UWidgetAnimation
---@field AnimInModel2 UWidgetAnimation
---@field AnimInModel3 UWidgetAnimation
---@field AnimInModel4 UWidgetAnimation
---@field AnimToEmpty UWidgetAnimation
---@field ModelDistance float
---@field ModelHeight float
---@field ModelPitch float
---@field ModelRotate float
---@field ModelPan float
---@field ModelAnimationPath text
---@field CurveModelFlyIn CurveFloat
---@field CurveModelBallIn CurveFloat
---@field CurveModelEmptyFlyIn CurveFloat
---@field CurveModelFlyIn2 CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MailMainView = LuaClass(UIView, true)

function MailMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnDelete = nil
	--self.BtnDeleteMail = nil
	--self.BtnGet = nil
	--self.BtnGetAll = nil
	--self.BtnModel = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonModelToImage = nil
	--self.CommonTitle = nil
	--self.GiftPage = nil
	--self.ImgBGItem01 = nil
	--self.ImgBGItem03 = nil
	--self.ImgMentorIcon = nil
	--self.ModelAdjustUI_106 = nil
	--self.PanelAdventuring = nil
	--self.PanelAdventuring02 = nil
	--self.PanelBGItem = nil
	--self.PanelBtnModel = nil
	--self.PanelContent = nil
	--self.PanelEmpty = nil
	--self.PanelMailContent01 = nil
	--self.PanelMailContent02 = nil
	--self.PanelMentor = nil
	--self.PanelReward = nil
	--self.PanelReward02 = nil
	--self.RichTextBy = nil
	--self.RichTextBy02 = nil
	--self.RichTextCountDown = nil
	--self.RichTextCountDown_1 = nil
	--self.RichTextDate = nil
	--self.RichTextDate02 = nil
	--self.RichTextMailContent = nil
	--self.RichTextMailContent02 = nil
	--self.Spine_LetterIn = nil
	--self.TableViewMailList = nil
	--self.TableViewReward = nil
	--self.TableViewReward02 = nil
	--self.TextEmpty = nil
	--self.TextMailTitle = nil
	--self.TextSubtitle = nil
	--self.TextTItleTips = nil
	--self.TextTitle = nil
	--self.VerIconTabs = nil
	--self.AnimChangeListItem = nil
	--self.AnimChangeTab = nil
	--self.AnimGiftBack = nil
	--self.AnimIn = nil
	--self.AnimIn3 = nil
	--self.AnimIn4 = nil
	--self.AnimInModel1 = nil
	--self.AnimInModel2 = nil
	--self.AnimInModel3 = nil
	--self.AnimInModel4 = nil
	--self.AnimToEmpty = nil
	--self.ModelDistance = nil
	--self.ModelHeight = nil
	--self.ModelPitch = nil
	--self.ModelRotate = nil
	--self.ModelPan = nil
	--self.ModelAnimationPath = nil
	--self.CurveModelFlyIn = nil
	--self.CurveModelBallIn = nil
	--self.CurveModelEmptyFlyIn = nil
	--self.CurveModelFlyIn2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MailMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnDelete)
	self:AddSubView(self.BtnDeleteMail)
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnGetAll)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonModelToImage)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.GiftPage)
	self:AddSubView(self.ModelAdjustUI_106)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MailMainView:OnInit()
	local RichTextMailContentParent = self.RichTextMailContent:GetParent()
	if nil ~= RichTextMailContentParent then
		RichTextMailContentParent:SetScrollBarVisibility(_G.UE.ESlateVisibility.Collapsed)
	end
	local RichTextMailContent02Parent = self.RichTextMailContent02:GetParent()
	if nil ~= RichTextMailContent02Parent then
		RichTextMailContent02Parent:SetScrollBarVisibility(_G.UE.ESlateVisibility.Collapsed)
	end

	self.CommonModelToImage:SetAutoCreateDefaultScene(false)

	self.ShowMailTypeIconList = { }
	self.CurrentSelectData = nil
	self.ThroughDelete = false
	self.MainPanelResidentAnimMontage = nil
	self.BtnClose:SetCallback(self, self.ActiveClose)

	for _, Value in pairs({MailType.System, MailType.Gift}) do
		local CurrentMailType = Value
		local RedDotData = nil
		local TypeRedDotName = _G.MailMgr:GetRedDotName(CurrentMailType)
		if TypeRedDotName ~= "" then
			RedDotData = { RedDotName = TypeRedDotName, IsStrongReminder = true }
		end
		table.insert( self.ShowMailTypeIconList, { IconPath = MailTypeInfo[CurrentMailType].IconPath, SelectIcon = MailTypeInfo[CurrentMailType].IconPath, MailType = CurrentMailType, RedDotData = RedDotData } )
	end

	self.AdapterTableViewMailList = UIAdapterTableView.CreateAdapter(self, self.TableViewMailList, self.OnSelectChangedTableViewMailList, true)
	self.AdapterTableViewReward = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, self.OnSelectChangedTableViewReward, true )
	self.AdapterTableViewReward02 = UIAdapterTableView.CreateAdapter(self, self.TableViewReward02, self.OnSelectChangedTableViewReward02, true)

	self.Binders = {
		{ "MailTitle", UIBinderSetText.New(self, self.TextMailTitle) },
		{ "MailContent", UIBinderSetText.New(self, self.RichTextMailContent) },
		{ "MailContent", UIBinderSetText.New(self, self.RichTextMailContent02) },
		{ "MaturityDayText", UIBinderSetText.New(self, self.RichTextCountDown_1) },
		{ "MaturityDayText", UIBinderSetText.New(self, self.RichTextCountDown) },
		{ "SendTimeText", UIBinderSetText.New(self, self.RichTextDate) },
		{ "SendTimeText", UIBinderSetText.New(self, self.RichTextDate02) },
		{ "SenderName", UIBinderSetText.New(self, self.RichTextBy02) },
		{ "SenderName", UIBinderSetText.New(self, self.RichTextBy) },
		{ "TextSubtitle", UIBinderSetText.New(self, self.TextSubtitle) },
		{ "TextTItleTipsVisible", UIBinderSetIsVisible.New(self, self.TextTItleTips) },
		{ "BtnGetAllIsEnabled", UIBinderSetIsEnabled.New(self, self.BtnGetAll) },

		{ "MainPanelContentVisible", UIBinderSetIsVisible.New(self, self.PanelContent) },
		{ "PanelEmptyVisible", UIBinderValueChangedCallback.New(self, nil, self.PanelEmptyChanged) },
		{ "PanelEmptyText", UIBinderSetText.New(self, self.TextEmpty) },

		{ "BtnGetVisible", UIBinderSetIsVisible.New(self, self.BtnGet) },
		{ "BtnDeleteMailVisible", UIBinderSetIsVisible.New(self, self.BtnDeleteMail) },

		{ "ContentPanelVisible", UIBinderSetIsVisible.New(self, self.PanelMailContent02) },
		{ "MaturityDayVisible", UIBinderSetIsVisible.New(self, self.RichTextCountDown_1) },
		{ "SenderNameVisible", UIBinderSetIsVisible.New(self, self.RichTextBy02) },

		{ "AttachContentPanelVisible", UIBinderSetIsVisible.New(self, self.PanelMailContent01) },
		{ "SenderNameVisible", UIBinderSetIsVisible.New(self, self.RichTextBy) },
		{ "MaturityDayVisible", UIBinderSetIsVisible.New(self, self.RichTextCountDown) },
		{ "LittleAttachPanelVisible", UIBinderSetIsVisible.New(self, self.PanelReward) },
		{ "AttachsInfoList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewReward) },

		{ "LargeAttachPanelVisible", UIBinderSetIsVisible.New(self, self.PanelReward02) },
		{ "AttachsInfoList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewReward02) },

		{ "MailList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewMailList) },
		{ "MailListDelChanged", UIBinderValueChangedCallback.New(self, nil, self.OnMailListDelChanged) },

		{ "MaturityDayVisible", UIBinderSetIsVisible.New(self, self.RichTextCountDown) },
		{ "GiftPageVisible", UIBinderSetIsVisible.New(self, self.GiftPage) },
		{ "ModelToImageVisible", UIBinderValueChangedCallback.New(self, nil, self.OnModelToImageVisibleChanged) },

		{ "TopCenterIconVisible", UIBinderSetIsVisible.New(self, self.PanelMentor) },
		{ "TopCenterIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMentorIcon) },
		{ "SpineLetterInStyle", UIBinderValueChangedCallback.New(self, nil, self.SpineLetterInStyleChanged) },
	}
end

function MailMainView:OnDestroy()

end

function MailMainView:TranslatedText()
	self.TextTitle:SetText(LSTR(740017))
	self.BtnGet:SetText(LSTR(10021))
	self.BtnDeleteMail:SetText(LSTR(10024))
	self.BtnDelete:SetText(LSTR(10022))
	self.BtnGetAll:SetText(LSTR(10023))
	self.TextTItleTips:SetText(LSTR(740022))
end

function MailMainView:OnShow()
	--确保与Hide里面成对
	self.CommonModelToImage:SwitchModelCamera(true) 
	self:LoadUIWeather(true)

	self:TranslatedText()
	self:InitModelToImage()
	local Params = self.Params or {}
	local ShowMailType = Params.MailType or MailType.System
	local _, TypeIndex = table.find_item(self.ShowMailTypeIconList, ShowMailType, "MailType")
	TypeIndex = TypeIndex or 1
	MailMainVM:SetFirstPickMailID(Params.FirstPickMailID)
	MailMainVM:SelectMailTab(ShowMailType, true)
	self.VerIconTabs:UpdateItems(self.ShowMailTypeIconList, TypeIndex)
	local MailListData = MailMgr:GetCacheMailList(ShowMailType, false)
	
	if ShowMailType == MailType.System then
		self.IsHaveMail = #MailListData > 0
		local HaveUnreadMail = MailMgr:CheckUnReadMail(MailType.System)
		if MailMainVM.HaveMailAnim and HaveUnreadMail then
			self:PlayAnimation(self.AnimIn3)
			self:PlayAnimation(self.AnimInModel1)
			MailMainVM:SetHaveMailAnim(false)
		else
			self:PlayAnimation(self.AnimIn4)
			if self.IsHaveMail then
				self:PlayAnimation(self.AnimInModel2)
			else
				self:PlayAnimation(self.AnimInModel3)
			end
		end
	end

	-- 商城TLOG上报
	local MailTabType = ShowMailType == MailType.System and StoreDefine.MailTabType.Main or StoreDefine.MailTabType.GiftInbox
	StoreUtil.ReportMailFlow(MailTabType)
end

function MailMainView:ActiveClose()
	UIUtil.SetIsVisible(self.CommonModelToImage, false)
	self:RegisterTimer(self.Hide, 0.05)
end

function MailMainView:OnHide()
	self.CommonModelToImage:SwitchModelCamera(false)
	UIUtil.SetIsVisible(self.CommonModelToImage, false)
	self:LoadUIWeather(false)
	MailMgr:GetSeverStoreMail()
	MailMgr:GetNewEmails()

	if MailMgr.CreatedNPCEntityID ~= nil then
		_G.UE.UActorManager.Get():RemoveClientActor(MailMgr.CreatedNPCEntityID)
		MailMgr:ClearCreatedNPCEntityID()
	end
end

function MailMainView:OnActive()

end

function MailMainView:OnInactive()

end

function MailMainView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)
	UIUtil.AddOnClickedEvent(self, self.BtnDeleteMail.Button, self.OnBtnDeleteMailClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnBtnGetClick)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnBtnDeleteClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGetAll, self.OnBtnGetAllClick)
	UIUtil.AddOnClickedEvent(self, self.BtnModel, self.OnBtnModelClick)

	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMailContent02, self.OnRichTextMailContentClick, nil)
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMailContent, self.OnRichTextMailContentClick, nil)
end

function MailMainView:OnRichTextMailContentClick(_, LinkID)
	local nLinkID = tonumber(LinkID)
	local MapData = MailMainVM:GetMapHyperLink(nLinkID)
	if MapData ~= nil then
		local WorldMapMgr = _G.WorldMapMgr
		if MapData.MapID ~= nil then
			WorldMapMgr:ShowWorldMapNpc(tonumber(MapData.MapID), tonumber(MapData.NpcID))
		elseif MapData.ChapterID ~= nil then
			local ChapterStatus = _G.QuestMgr:GetChapterStatus(MapData.ChapterID)
			if ChapterStatus == CHAPTER_STATUS.NOT_STARTED then
				local ChapterCfg = QuestHelper.GetChapterCfgItem(MapData.ChapterID)
				if not ChapterCfg then
					MsgTipsUtil.ShowTipsByID(171016)
					return
				end
				local QuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfg.StartQuest)
				if QuestCfgItem and QuestCfgItem.AcceptMapID ~= 0 and QuestCfgItem.AcceptUIMapID ~= 0 then
					WorldMapMgr:ShowWorldMapQuest(QuestCfgItem.AcceptMapID, QuestCfgItem.AcceptUIMapID, ChapterCfg.StartQuest)
				else
					MsgTipsUtil.ShowTipsByID(171016)
				end
			elseif ChapterStatus == CHAPTER_STATUS.FINISHED or ChapterStatus == CHAPTER_STATUS.FAILED then
				MsgTipsUtil.ShowTipsByID(171015)
			elseif ChapterStatus == CHAPTER_STATUS.IN_PROGRESS or ChapterStatus == CHAPTER_STATUS.CAN_SUBMIT then
				MsgTipsUtil.ShowTipsByID(171014)
			end
		end
	end
end

function MailMainView:OnRegisterGameEvent()
end

function MailMainView:OnRegisterBinder()
	self:RegisterBinders(MailMainVM, self.Binders)
end

function MailMainView:OnSelectionChangedVerIconTabs(ProfessionIndex)
	if ProfessionIndex ~= MailMainVM.CurrentMailType then
		self:PlayAnimation(self.AnimChangeTab)

		-- 商城TLOG上报
		if ProfessionIndex == MailDefine.MailType.System or ProfessionIndex == MailDefine.MailType.Gift then
			StoreUtil.ReportMailFlow(ProfessionIndex == MailDefine.MailType.System and StoreDefine.MailTabType.Main or
				StoreDefine.MailTabType.GiftInbox)
		end
	end

	local GiftType = MailDefine.MailType.Gift
	if ProfessionIndex ~= GiftType and MailMainVM.CurrentMailType == GiftType then
		self:PlayAnimation(self.AnimGiftBack)
	end
	self.AdapterTableViewMailList:CancelSelected()

	MailMainVM:SetCurrentMailBoxType(MailDefine.MailBoxType.InBox)
	MailMainVM:SelectMailTab(ProfessionIndex, true )

	if ProfessionIndex ~= GiftType then
		if self.AdapterTableViewMailList:GetNum() > 0 and MailMainVM.MainPanelContentVisible then
			self.AdapterTableViewMailList:SetSelectedIndex(1)
			self.AdapterTableViewMailList:ScrollToIndex(1)
		end
	else
		if MailMainVM.PanelEmptyVisible then
			self:PlayAnimation(self.AnimToEmpty)
		end
	end
end

function MailMainView:OnSelectChangedTableViewMailList(Index, ItemData, ItemView)
	MailMainVM:SetMailListLastSelectIndex(Index)
	self:PlayAnimation(self.AnimChangeListItem)
	self.CurrentSelectData = MailMgr:GetMailData(ItemData.ID, MailMainVM.CurrentMailType, MailMainVM.CurrentMailBoxType)
	MailMainVM:SelectMail(ItemData.ID)
	local RichTextMailContentParent = self.RichTextMailContent:GetParent()
	if nil ~= RichTextMailContentParent then
		RichTextMailContentParent:ScrolltoStart()
	end
	local RichTextMailContent02Parent = self.RichTextMailContent02:GetParent()
	if nil ~= RichTextMailContent02Parent then
		RichTextMailContent02Parent:ScrolltoStart()
	end
end

function MailMainView:OnSelectChangedTableViewReward(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0,Y = -715}, nil)
end

function MailMainView:OnSelectChangedTableViewReward02(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView,  {X = 0,Y = -715}, nil)
end

function MailMainView:OnBtnModelClick()
	self:OnCommonModelToImageClick()
end

function MailMainView:OnBtnDeleteMailClick()
	if self.CurrentSelectData ~= nil then
		self.ThroughDelete = true
		local DeleteList = { self.CurrentSelectData.ID }
		MailMgr:DeleteMail(DeleteList, MailMainVM.CurrentMailType, MailMainVM.CurrentMailBoxType )
	end
end

function MailMainView:OnBtnGetClick()
	if self.CurrentSelectData ~= nil then
		MailMgr:CheckScoreUpperLimit(self.CurrentSelectData.ID, MailMainVM.CurrentMailType)
	end
end

function MailMainView:OnBtnDeleteClick()
	self.ThroughDelete = true
	MailMgr:DeleteAllReadMail(MailMainVM.CurrentMailType)
end

function MailMainView:OnBtnGetAllClick()
	if #MailMainVM.MailAllAttchList > 1 then
		MailMgr:GetMailAttch(MailMainVM.MailAllAttchList, MailMainVM.CurrentMailType)
	elseif #MailMainVM.MailAllAttchList == 1 then
		MailMgr:CheckScoreUpperLimit(MailMainVM.MailAllAttchList[1], MailMainVM.CurrentMailType)
	end
end

function MailMainView:OnMailListDelChanged()
	if MailMainVM.GiftPageVisible then return end
	local Index = MailMainVM.MailListLastSelectIndex
	if Index ~= nil and self.AdapterTableViewMailList:GetNum() >= Index then
		self.AdapterTableViewMailList:SetSelectedIndex(Index)
	else
		local MailListCount = self.AdapterTableViewMailList:GetNum()
		if MailListCount > 0 then
			self.AdapterTableViewMailList:SetSelectedIndex(MailListCount)
		end
	end
end

function MailMainView:SpineLetterInStyleChanged(NewValue)
	self.Spine_LetterIn:SetSkin(NewValue)
end

function MailMainView:PanelEmptyChanged(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelEmpty, NewValue)

	if OldValue ~= nil and NewValue then
		self:PlayAnimation(self.AnimToEmpty)
	elseif OldValue ~= nil and not NewValue then
		if  MailMainVM.ModelToImageVisible then
			self:PlayAnimation(self.AnimInModel4)
		end
	end
end

function MailMainView:OnModelToImageVisibleChanged(NewValue, OldValue)
	--if OldValue == nil then return end
	if NewValue then
		UIUtil.SetIsVisible(self.PanelBtnModel, true )
		UIUtil.SetIsVisible(self.CommonModelToImage, true )
		if MailMgr.CreatedNPCEntityID ~= nil then
			local Actor = ActorUtil.GetActorByEntityID(MailMgr.CreatedNPCEntityID)
			self.CommonModelToImage:Show(Actor)
		end
	else
		UIUtil.SetIsVisible(self.CommonModelToImage, false )
		UIUtil.SetIsVisible(self.PanelBtnModel, false )
	end
end

-------- ModelToImage Begin

function MailMainView:LoadUIWeather(Init)
	local LightMgr = _G.LightMgr
	if LightMgr == nil then
		return 
	end
	
	if Init then 
		LightMgr:EnableUIWeather(13)  --id 在天气表里
	else
		LightMgr:DisableUIWeather()
	end
end

function MailMainView:OnCommonModelToImageClick()
	if MailMgr.CreatedNPCEntityID == nil or self.ClickAniming then
		return
	end
	local ClickAnimPath = MailDefine.ClickAnimPath[math.random( #MailDefine.ClickAnimPath )]
	local ClickAnim = _G.ObjectMgr:LoadObjectSync(ClickAnimPath, ObjectGCType.LRU)
	local MainPanelResidentAnim = _G.ObjectMgr:LoadObjectSync(MailDefine.FirstFlyInStep4AnimPath, ObjectGCType.LRU)
	local Actor = ActorUtil.GetActorByEntityID(MailMgr.CreatedNPCEntityID)
	if Actor and ClickAnim and MainPanelResidentAnim then
		local AnimationComponent = Actor:GetAnimationComponent()
		AnimationComponent:StopMontage(self.MainPanelResidentAnimMontage)
		local AudioIndex = math.random(5) > 1 and 1 or 2
		AudioUtil.LoadAndPlayUISound(MailDefine.ClickAudioPathList[AudioIndex])

		self.ClickAniming = true
		self.MainPanelResidentAnimMontage = AnimationUtil.CreateLoopDynamicMontage(ClickAnim, MainPanelResidentAnim, "WholeBody")
		AnimationComponent:PlayMontage(self.MainPanelResidentAnimMontage)
		local AnimTime = ClickAnim:GetPlayLength() or 1
		self:RegisterTimer(function ()
			self.ClickAniming = false
		end, AnimTime)
	end
end

function MailMainView:InitModelToImage()
	self.ClickAniming = false
	if MailMgr.CreatedNPCEntityID == nil then
		return
	end
	local Actor = ActorUtil.GetActorByEntityID(MailMgr.CreatedNPCEntityID)
	if (Actor ~= nil) then
		Actor:GetAvatarComponent():SetForcedLODForAll(1)
		Actor:GetAvatarComponent():SwitchForceMipStreaming(true)
		Actor:GetMeshComponent():SetBoundsScale(30)
		self.CommonModelToImage:Show(Actor)
		self.CommonModelToImage:SetYawAngle(180)
		--Actor:FSetRotationForServer(_G.UE.FRotator(0, 180, 0))
	end
end

function MailMainView:SequenceEvent_SetModelCamera()
	self:SetModelCameraValue()
	self.CommonModelToImage:SetDistance(self.ModelDistance)
	self.CommonModelToImage:SetHightOffset(self.ModelHeight)
	self.CommonModelToImage:SetPitchAngle(self.ModelPitch)
	--self.CommonModelToImage:RotateCamera(self.ModelRotate)
	self.CommonModelToImage:SetPan(self.ModelPan)
end

function MailMainView:SequenceEvent_SetModelAnimation(lPathIndex)
	self:SetModelAnimationPathValue(lPathIndex)
	local Actor = ActorUtil.GetActorByEntityID(MailMgr.CreatedNPCEntityID)
	if (Actor ~= nil) then
		local AnimationComponent = Actor:GetAnimationComponent()
		if self.MainPanelResidentAnimMontage ~= nil then
			AnimationComponent:StopMontage(self.MainPanelResidentAnimMontage)
			self.MainPanelResidentAnimMontage = nil
		end
		if self.ModelAnimationPath == MailDefine.FirstFlyInStep2AnimPath then
			AudioUtil.LoadAndPlayUISound(MailDefine.FlyInAudioPath)
		end
		local ModelAnimationObj = _G.ObjectMgr:LoadObjectSync(self.ModelAnimationPath, ObjectGCType.LRU)
		self.MainPanelResidentAnimMontage = AnimationComponent:PlaySequenceToMontage(ModelAnimationObj, "WholeBody", nil, nil, 1.0, 0.25, 0.25, nil, 10000000, true)
	end
end

-------- ModelToImage End

return MailMainView