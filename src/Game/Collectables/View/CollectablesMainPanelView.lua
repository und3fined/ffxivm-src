---
--- Author: Administrator
--- DateTime: 2025-03-04 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ScoreCfg = require("TableCfg/ScoreCfg")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local EventID = require("Define/EventID")
local CollectablesDefine = require("Game/Collectables/CollectablesDefine")
local CollectablesVM = require("Game/Collectables/CollectablesVM")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local FLOG_ERROR = _G.FLOG_ERROR
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local CollectablesMgr = _G.CollectablesMgr
local GatheringLogMgr = _G.GatheringLogMgr
local FishNotesMgr = _G.FishNotesMgr

local ShopMgr = _G.ShopMgr
local PersonInfoMgr = _G.PersonInfoMgr
local ActorMgr = _G.ActorMgr
local LSTR = _G.LSTR

---@class CollectablesMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnClose CommonCloseBtnView
---@field BtnExchange CommBtnLView
---@field BtnGoGet CommBtnLView
---@field BtnPlayerCard UFButton
---@field BtnShop UFButton
---@field BtnShutWin UFButton
---@field BtnWarn UFButton
---@field Comm96Slot CommBackpack96SlotView
---@field CommonTitle_UIBP CommonTitleView
---@field DropDownFilter CommDropDownListView
---@field FImage_196 UFImage
---@field FTextBlock_311 UFTextBlock
---@field ImgWarn UFImage
---@field MoneyBarHigh CommMoneySlotView
---@field MoneyBarLow CommMoneySlotView
---@field MsgBox CommMsgBoxView
---@field PanelGoGet UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelRecord UFCanvasPanel
---@field PanelRewardTips UFCanvasPanel
---@field SlotEXP CommBackpack96SlotView
---@field SlotTicket CommBackpack96SlotView
---@field TableViewMarket UTableView
---@field TableViewProp UTableView
---@field TextCountNum URichTextBox
---@field TextEmptyProp UFTextBlock
---@field TextHoldNum UFTextBlock
---@field TextLevel UFTextBlock
---@field TextName URichTextBox
---@field TextName02 UFTextBlock
---@field TextProp UFTextBlock
---@field TextReward UFTextBlock
---@field TextTips UFTextBlock
---@field TextValue UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimRefreshRecord UWidgetAnimation
---@field AnimTableViewTabsSelectionChanged UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CollectablesMainPanelView = LuaClass(UIView, true)

function CollectablesMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnClose = nil
	--self.BtnExchange = nil
	--self.BtnGoGet = nil
	--self.BtnPlayerCard = nil
	--self.BtnShop = nil
	--self.BtnShutWin = nil
	--self.BtnWarn = nil
	--self.Comm96Slot = nil
	--self.CommonTitle_UIBP = nil
	--self.DropDownFilter = nil
	--self.FImage_196 = nil
	--self.FTextBlock_311 = nil
	--self.ImgWarn = nil
	--self.MoneyBarHigh = nil
	--self.MoneyBarLow = nil
	--self.MsgBox = nil
	--self.PanelGoGet = nil
	--self.PanelInfo = nil
	--self.PanelRecord = nil
	--self.PanelRewardTips = nil
	--self.SlotEXP = nil
	--self.SlotTicket = nil
	--self.TableViewMarket = nil
	--self.TableViewProp = nil
	--self.TextCountNum = nil
	--self.TextEmptyProp = nil
	--self.TextHoldNum = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextName02 = nil
	--self.TextProp = nil
	--self.TextReward = nil
	--self.TextTips = nil
	--self.TextValue = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimRefreshRecord = nil
	--self.AnimTableViewTabsSelectionChanged = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CollectablesMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnExchange)
	self:AddSubView(self.BtnGoGet)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommonTitle_UIBP)
	self:AddSubView(self.DropDownFilter)
	self:AddSubView(self.MoneyBarHigh)
	self:AddSubView(self.MoneyBarLow)
	self:AddSubView(self.MsgBox)
	self:AddSubView(self.SlotEXP)
	self:AddSubView(self.SlotTicket)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CollectablesMainPanelView:OnInit()
	--创建Adapter
	self.TableViewMarketAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMarket, nil, true)
	self.TableViewPropAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProp, nil, true)

	--创建Binders
	self.Binders = {
		{"SelectID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectIDChanged)},
		{"LowTicketScoreID", UIBinderValueChangedCallback.New(self, nil, self.OnLowTicketScoreIDChange)},
		{"HighTicketScoreID", UIBinderValueChangedCallback.New(self, nil, self.OnHighTicketScoreIDChange)},
		{"CurCollectionVMList", UIBinderUpdateBindableList.New(self, self.TableViewMarketAdapter)},
		{"PossessCollectablesVMList", UIBinderUpdateBindableList.New(self, self.TableViewPropAdapter)},
		{"PossessCollectRefresh", UIBinderValueChangedCallback.New(self, nil, self.PossessCollectRefresh)},
		{"bTextEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelGoGet)},
		{"bTextEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelInfo, true )},
		{"bRewardVisible", UIBinderSetIsVisible.New(self, self.SlotTicket)},
		{"bRewardVisible", UIBinderSetIsVisible.New(self, self.SlotEXP)},
		{"TicketRewardNum", UIBinderSetTextFormatForMoney.New(self, self.SlotTicket.RichTextQuantity)},
		{"ExpRewardNum", UIBinderSetTextFormatForMoney.New(self, self.SlotEXP.RichTextQuantity)},
        {"TicketID", UIBinderValueChangedCallback.New(self, nil, self.OnTicketIDChanged)},
		{"bBtnWarnVisible", UIBinderSetIsVisible.New(self, self.ImgWarn)},
		{"bBtnWarnVisible", UIBinderSetIsEnabled.New(self, self.BtnWarn)},
		{"bBeyondMaxTicketTipVisible", UIBinderValueChangedCallback.New(self, nil, self.OnMaxTicketTipVisibleChanged)},
		{"MaxRecordText", UIBinderSetText.New(self, self.TextCountNum)},
		{"MaxRecordName", UIBinderSetText.New(self, self.TextName)},
		{"bMaxRecordVisible", UIBinderSetIsVisible.New(self, self.PanelRecord)},
		{"bBtnCardVisible", UIBinderSetIsEnabled.New(self, self.BtnPlayerCard)},
	}

	self.CommonTitle_UIBP:SetSubTitleIsVisible(true)
	self.CommonTitle_UIBP:SetCommInforBtnIsVisible(true)

	local ExpCfg = ScoreCfg:FindCfgByKey( SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP) or {}
	self.SlotEXP:SetIconImg(ExpCfg.IconName)
	UIUtil.SetIsVisible(self.SlotTicket.RichTextQuantity, true)
	UIUtil.SetIsVisible(self.SlotEXP.RichTextQuantity, true)
    UIUtil.SetIsVisible(self.SlotTicket.RichTextLevel, false)
	UIUtil.SetIsVisible(self.SlotTicket.IconChoose, false)
	UIUtil.SetIsVisible(self.SlotTicket.IconReceived, false)
    UIUtil.SetIsVisible(self.SlotEXP.RichTextLevel, false)
	UIUtil.SetIsVisible(self.SlotEXP.IconChoose, false)
	UIUtil.SetIsVisible(self.SlotEXP.IconReceived, false)

	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, false)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextQuantity, false)

    self.SlotEXP:SetClickButtonCallback(self, function()
        ItemTipsUtil.ShowTipsByResID(SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP, self.SlotEXP)
    end)
end

function CollectablesMainPanelView:OnDestroy()

end

function CollectablesMainPanelView:TranslatedText()
	self.CommonTitle_UIBP.CommInforBtn:SetHelpInfoID(11123)
    self.FTextBlock_311:SetText(LSTR(770025))
    self.TextProp:SetText(LSTR(770026))
    self.TextLevel:SetText(LSTR(770027))
    self.TextValue:SetText(LSTR(770028))
    self.TextReward:SetText(LSTR(770029))
    self.TextHoldNum:SetText(LSTR(770030))
    self.BtnExchange:SetText(LSTR(10026))
    self.TextEmptyProp:SetText(LSTR(770031))
    self.TextTips:SetText(LSTR(770032))
	self.CommonTitle_UIBP:SetTextTitleName(LSTR(770021))   -- "收藏品交易"
	self.TextEmptyProp:SetText(LSTR(770033)) 		-- "未持有该收藏品"
	self.BtnGoGet:SetButtonText(LSTR(770034))		-- "前往获取"
end

function CollectablesMainPanelView:OnShow()
	self.ShowingIDList = {}
    self:TranslatedText()
	CollectablesMgr:SendMsgGetRecordinfo()
    CollectablesMgr:UpdateCurAndMaxTicket()
    CollectablesMgr:UpdateProfessionData()
    local LastSelectData = CollectablesMgr.LastSelectData
    LastSelectData.CollectIDMap = {}
    LastSelectData.DropFilterIndexMap = {}
    LastSelectData.ProfID = 0

    local ProfessIndex
    local ProfessData = CollectablesMgr.ProfessionData or {}
    if #ProfessData < 1 then
        FLOG_ERROR("No profession was opened #ProfessData < 1")
        return
    end

    local Simple = ActorMgr:GetMajorRoleDetail().Simple
    local Prof = Simple.Prof
    if Prof >= CollectablesDefine.MinLifeProfID and Simple.Level >= CollectablesDefine.MinUnLockLevel then
        ProfessIndex = CollectablesMgr:GetProfIndexByData(ProfessData, Prof)
    end

    ProfessIndex = ProfessIndex or 1
    for i = 1, #ProfessData do
        ProfessData[i].RedDotData = {
            IsStrongReminder = false,
            RedDotName = CollectablesDefine.RedDotName .. "/" .. tostring(ProfessData[i].ProfID)
        }
    end
    self.VerIconTabs:UpdateItems(ProfessData, ProfessIndex)

    --刷一下自己当前选中的收藏品，防止刚开界面没有拿到最新数据
    self:RegisterTimer(function()
        local LastSelectData = CollectablesMgr.LastSelectData
        local CollectableID = LastSelectData.CollectIDMap[LastSelectData.ProfID] or 0
        CollectablesVM:UpdateRecord(CollectableID)
    end, 0.5)
    self:PlayAnimation(self.AnimIn)
end

function CollectablesMainPanelView:OnHide()
	self:ClearShowedRedDot()
end

function CollectablesMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnBtnShopClick)
	UIUtil.AddOnClickedEvent(self, self.BtnWarn, self.OnBtnWarnClick)
    UIUtil.AddOnClickedEvent(self, self.BtnPlayerCard, self.OnBtnCardClick)
    UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDownFilter, self.OnSelectionChangedDropDown)
    UIUtil.AddOnClickedEvent(self, self.BtnExchange, self.OnBtnExchangeClick)
    UIUtil.AddOnClickedEvent(self, self.BtnShutWin, self.OnBtnShutWinClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGoGet.Button, self.OnBtnGoGetClick)
end

function CollectablesMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SetBtnShutWinVisibleEvent, self.SetBtnShutWinVisible)
    self:RegisterGameEvent(EventID.OnExchangeRspEvent, self.OnGameEventCollectExchange)
    self:RegisterGameEvent(EventID.ScoreUpdate, self.OnGameEventScoreUpdate)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnGameEventBagUpdate)
end

function CollectablesMainPanelView:OnRegisterBinder()
	self:RegisterBinders(CollectablesVM, self.Binders)
end

function CollectablesMainPanelView:OnSelectIDChanged(NewValue)
	local Cfg = ItemCfg:FindCfgByKey(NewValue)
	if nil ~= Cfg then
        local Path = UIUtil.GetIconPath(Cfg.IconID)
		self.Comm96Slot:SetIconImg(Path)
		self.Comm96Slot:SetClickButtonCallback(self, function()
			ItemTipsUtil.ShowTipsByResID(NewValue, self.Comm96Slot)
		end)
        self.TextName02:SetText(string.gsub(Cfg.ItemName or "", "%b<>", ""))
	end
end

function CollectablesMainPanelView:OnTicketIDChanged(NewValue)
    local ScoreCfgData = {}
    if (NewValue or 0) == 0 then
        NewValue = SCORE_TYPE.SCORE_TYPE_GOLD_CODE
    end
    ScoreCfgData = ScoreCfg:FindCfgByKey(NewValue) or {}
    self.SlotTicket:SetIconImg(ScoreCfgData.IconName)
    self.SlotTicket:SetClickButtonCallback(self, function()
        ItemTipsUtil.ShowTipsByResID(NewValue, self.SlotTicket)
    end)
end

function CollectablesMainPanelView:OnHighTicketScoreIDChange(NewValue)
	if (NewValue or 0) ~= 0 then
		self.MoneyBarHigh:UpdateView(NewValue, false, nil, true, true)
	end 
end

function CollectablesMainPanelView:OnLowTicketScoreIDChange(NewValue)
	if (NewValue or 0) ~= 0 then
		self.MoneyBarLow:UpdateView(NewValue, false, nil, true, true)
	end
end

function CollectablesMainPanelView:OnBtnShopClick()
	ShopMgr:OpenInletMainView(4)
end

function CollectablesMainPanelView:OnBtnGoGetClick()
	local LastSelectData = CollectablesMgr.LastSelectData
	if LastSelectData.ProfID >= CollectablesDefine.MinLifeProfID then 
		if LastSelectData.ProfID >= CollectablesDefine.MinEarthHandsProfID then
			if LastSelectData.ProfID ==  ProtoCommon.prof_type.PROF_TYPE_FISHER then
				FishNotesMgr:ShowCanFishLocation(CollectablesVM.SelectID)
			else
				GatheringLogMgr:SearchInGatheringLog(CollectablesVM.SelectID)
			end
		else
			SystemEntranceMgr:ShowCraftingLogEntrance(CollectablesVM.SelectID)
		end
	end
end

---@type 拥有收藏品表格数据刷新
function CollectablesMainPanelView:PossessCollectRefresh()
    self.TableViewPropAdapter:ScrollToIndex(1)
end

---@type  提示框确认回调
function CollectablesMainPanelView:TipVerifyClick()
    CollectablesVM:OnBtnExchangeClick()
    self:TipsMaskCallBack()
end

---@type 提示框关闭回调
function CollectablesMainPanelView:TipsMaskCallBack()
    CollectablesVM.bBeyondMaxTicketTipVisible = false
end

function CollectablesMainPanelView:OnMaxTicketTipVisibleChanged(NewValue)
    if NewValue then
        local MaxTicketTipParams = self.MaxTicketTipParams or {}
        local Params = {CloseClickCB = self.TipsMaskCallBack}
        MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            MaxTicketTipParams.Title or "",
            MaxTicketTipParams.Message or "",
            self.TipVerifyClick,
            self.TipsMaskCallBack,
            LSTR(770014),
            LSTR(770018),
            Params
        )
    end
end

---@type 点击警告按钮
function CollectablesMainPanelView:OnBtnWarnClick()
    local Visible = UIUtil.IsVisible(self.PanelRewardTips)
    if Visible then
        self:PlayAnimation(self.AnimRewardTipsIn)
	else
		self:SetBtnShutWinVisible()
    end
    UIUtil.SetIsVisible(self.PanelRewardTips, not Visible)

    --TipsUtil.ShowInfoTips(self.PanelRewardTips, self.BtnWarn, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(1, 0), false)
end

---@type 显示保持记录玩家的名片
function CollectablesMainPanelView:OnBtnCardClick()
    local RoleID = CollectablesMgr.RecordRoleID
    PersonInfoMgr:ShowPersonalSimpleInfoView(RoleID)
end

---@type 职业选择变化
---@param ProfessionIndex number @职业索引1~11
function CollectablesMainPanelView:OnSelectionChangedVerIconTabs(ProfessionIndex, ItemData, ItemView, bByClick)
    local ProfessData = CollectablesMgr.ProfessionData
    local LastSelectData = CollectablesMgr.LastSelectData
    if ProfessData[ProfessionIndex].IsLock then
        MsgTipsUtil.ShowTips(string.format(CollectablesDefine.LockStateTipsText, ProfessData[ProfessionIndex].ProfessionName or ""), nil,  2)
        self.VerIconTabs:SetSelectedIndex(LastSelectData.ProfIndex)
        return
    end
    local ProfID = ProfessData[ProfessionIndex].ProfID
    if LastSelectData.ProfID == ProfID then
        return
    end
	self:PlayAnimation(self.AnimChangeTab)
	self.CommonTitle_UIBP:SetTextSubtitle(ProfessData[ProfessionIndex].ProfessionName)
    
    local MinEarHandsProfIndex = CollectablesDefine.MinEarthHandsProfID
    local WarnTipsParams = CollectablesDefine.WarnTipsParams or {}
    if ProfID < MinEarHandsProfIndex then
        self.MaxTicketTipParams = WarnTipsParams.SkillfulHandsProfession
    else
        self.MaxTicketTipParams = WarnTipsParams.EarthMessengerProfession
    end

    --大地使者职业不显示记录
    CollectablesVM.bMaxRecordVisible = ProfID < MinEarHandsProfIndex
    --保存上次选择的职业
    LastSelectData.ProfID = ProfID
    LastSelectData.ProfIndex = ProfessionIndex
	CollectablesVM:UpdateTicketIcon(ProfID)
    local ProfessionData = CollectablesMgr.ProfessionData[ProfessionIndex]
    local ProfessionLevel = ProfessionData.Level
    local DropFilterTabData = CollectablesMgr:GetDropFilterData(ProfessionLevel)
    local DefaultSelectIndex = LastSelectData.DropFilterIndexMap[ProfID]
    for i = 1, #DropFilterTabData do
        local DropFilter = DropFilterTabData[i]
        DropFilter.RedDotData = {
            IsStrongReminder = false,
            RedDotName = CollectablesDefine.RedDotName ..
                "/" .. tostring(ProfessionData.ProfID) .. "/" .. tostring(DropFilter.MinValue)
        }
        if DefaultSelectIndex == nil and DropFilter.MaxValue >= ProfessionLevel and DropFilter.MinValue <= ProfessionLevel then
            DefaultSelectIndex = i
        end
    end
    DefaultSelectIndex = DefaultSelectIndex or 1
    self.DropDownFilter:UpdateItems(DropFilterTabData, DefaultSelectIndex)
    self.DropDownFilter:SetSelectedIndex(DefaultSelectIndex)
    self:OnSelectionChangedDropDown(DefaultSelectIndex)
    _G.ObjectMgr:CollectGarbage(false, true, false)
end

---@type 筛选选择变化
---@param DropFilterIndex number @范围：1~5
function CollectablesMainPanelView:OnSelectionChangedDropDown(DropFilterIndex, ItemData, ItemView, bByClick)
	self:PlayAnimation(self.AnimUpdateList)
    --保存上次选择的筛选
    local LastSelectData = CollectablesMgr.LastSelectData
    local ProfIndex = LastSelectData.ProfIndex or 1
    local ProfessData = CollectablesMgr.ProfessionData
    local ProfID = LastSelectData.ProfID or ProfessData[1].ProfID
    --ProfessionIndex范围：1~11
    local ProfessionData = CollectablesMgr.ProfessionData[ProfIndex]
    local ProfessionLevel = ProfessionData.Level
    local DropFilterTabData = CollectablesMgr:GetDropFilterData(ProfessionLevel)

    local DropFilterID = DropFilterTabData[DropFilterIndex].ID
    LastSelectData.DropFilterIndexMap[ProfID] = DropFilterIndex
    local CollectionData = CollectablesMgr:GetCollectByDropFilter(ProfID, DropFilterID)
    local ShowCollectionData = {}
    for _, Elem in pairs(CollectionData) do
        if CollectablesMgr:CheckCollectionDisplayed(Elem) then
            table.insert(self.ShowingIDList, Elem.ID)
            table.insert(ShowCollectionData, Elem)
        end
    end
    if #ShowCollectionData < 1 then
        CollectablesVM.bRewardVisible = false
        CollectablesVM.bTableViewPropVisible = false
    end
    CollectablesVM:UpdateCollectionList(ShowCollectionData)
    self.TableViewMarketAdapter:ScrollToIndex(LastSelectData.CurCollectSelectIndex or 1)
    _G.ObjectMgr:CollectGarbage(false, true, false)
end

---@type 点击交换按钮
function CollectablesMainPanelView:OnBtnExchangeClick()
	if CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_SUBMIT, true) then
		--如果出现警告了要先出现提示框
		CollectablesVM.bBeyondMaxTicketTipVisible = CollectablesVM.bBtnWarnVisible
		if CollectablesVM.bBeyondMaxTicketTipVisible then
			return
		end
		CollectablesVM:OnBtnExchangeClick()
	end
end

---@type 点击ShutWin按钮
function CollectablesMainPanelView:OnBtnShutWinClick()
    UIViewMgr:HideView(UIViewID.CollectablesTransactionTipsView)
    local PanelRewardTips = self.PanelRewardTips
    local PanelRewardTipsVisible = UIUtil.IsVisible(PanelRewardTips)
    if PanelRewardTipsVisible then
        UIUtil.SetIsVisible(self.PanelRewardTips, false)
    end

    UIUtil.SetIsVisible(self.BtnShutWin, false)
end

---@type 设置遮罩按钮出现
function CollectablesMainPanelView:SetBtnShutWinVisible()
    UIUtil.SetIsVisible(self.BtnShutWin, true, true)
end

---@type 积分更新回调
function CollectablesMainPanelView:OnGameEventScoreUpdate()
    CollectablesMgr:UpdateCurAndMaxTicket()
    CollectablesVM:OnPossSelectChanged(CollectablesVM:GetSelectPossCollect())
end

---@type 物品变动回调
function CollectablesMainPanelView:OnGameEventBagUpdate(Params)
    if nil == Params then return end
    local ResIDList = {}
	for _, Value in pairs(Params) do
		local Item = Value.PstItem
        table.insert(ResIDList, Item.ResID) 
	end

    CollectablesVM:RefreshCollectiblesNum(ResIDList)
    local CollectiblesTypeVM = CollectablesVM:GetSelectCollectItem()
    if CollectiblesTypeVM and table.contain(ResIDList, CollectiblesTypeVM.ID) then
        CollectablesVM:OnSelectChanged(CollectiblesTypeVM.ID)
    end
end

---@type 成功收到交换结果更新工票和警告图片以及记录提示等
function CollectablesMainPanelView:OnGameEventCollectExchange(bIsBreakRecord)
    CollectablesMgr:UpdateCurAndMaxTicket()
    CollectablesVM:UpdateWarnImgVisbile()
    if bIsBreakRecord then
        local SelectPossCollect = CollectablesVM:GetSelectPossCollect()
        CollectablesVM:UpdateImproveRecordTips(SelectPossCollect)
    else
        CollectablesVM:RemovePossCollect()
    end
end

---@type 清除显示过的红点
function CollectablesMainPanelView:ClearShowedRedDot()
    for i = 1 , #self.ShowingIDList do
        CollectablesMgr:RemoveRedDot(self.ShowingIDList[i])
    end
    self.ShowingIDList = {}
end

---@type 刷新记录后的动效
function CollectablesMainPanelView:RefreshRecordedEffect(ItemName)
    MsgTipsUtil.ShowInfoTextTips(3, LSTR(770013), ItemName, 3)
	self:RegisterTimer(
		function() 
			self:PlayAnimation(self.AnimRefreshRecord)
		end, 1
	)
end

return CollectablesMainPanelView