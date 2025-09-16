---
--- Author: Administrator
--- DateTime: 2023-12-18 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local Log = require("Game/MagicCard/Module/Log")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local CardCfg = require("TableCfg/FantasyCardCfg")
local EventID = require("Define/EventID")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local AudioUtil = require("Utils/AudioUtil")
local MagicCardCollectionVM = require("Game/MagicCardCollection/VM/MagicCardCollectionVM")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")


local LSTR = _G.LSTR

---@class MagicCardMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnInfo UFButton
---@field CardBox UTableView
---@field CommEmpty CommBackpackEmptyView
---@field CommSearchBar6 CommSearchBarView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field ImgBgAsh UFImage
---@field ImgBgYellow UFImage
---@field ItmeBox MagicCardBoxItmeItemView
---@field ItmeCard MagicCardCollectionCardItemView
---@field ListTask1 UTableView
---@field MagicCardPanel UFCanvasPanel
---@field PanelAward UFCanvasPanel
---@field PanelCarddetails UFCanvasPanel
---@field PanelCardname UFCanvasPanel
---@field PanelCollectPercent UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelNoInfo UFCanvasPanel
---@field PanelNull UFCanvasPanel
---@field Panelbook UFCanvasPanel
---@field ScreenerBtn CommScreenerBtnView
---@field ScrollBox UScrollBox
---@field SingleBox CommSingleBoxView
---@field TextBlock UFTextBlock
---@field TextCardQuantity UFTextBlock
---@field TextCardname UFTextBlock
---@field TextCardnumber UFTextBlock
---@field TextCollectPercent UFTextBlock
---@field TextContent UFTextBlock
---@field TextCumulativeQuantity UFTextBlock
---@field TextNoInfo UFTextBlock
---@field TextNull UFTextBlock
---@field TextNum UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field SoundStartPath SoftObjectPath
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardMainPanelView = LuaClass(UIView, true)

function MagicCardMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnInfo = nil
	--self.CardBox = nil
	--self.CommEmpty = nil
	--self.CommSearchBar6 = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.ImgBgAsh = nil
	--self.ImgBgYellow = nil
	--self.ItmeBox = nil
	--self.ItmeCard = nil
	--self.ListTask1 = nil
	--self.MagicCardPanel = nil
	--self.PanelAward = nil
	--self.PanelCarddetails = nil
	--self.PanelCardname = nil
	--self.PanelCollectPercent = nil
	--self.PanelInfo = nil
	--self.PanelNoInfo = nil
	--self.PanelNull = nil
	--self.Panelbook = nil
	--self.ScreenerBtn = nil
	--self.ScrollBox = nil
	--self.SingleBox = nil
	--self.TextBlock = nil
	--self.TextCardQuantity = nil
	--self.TextCardname = nil
	--self.TextCardnumber = nil
	--self.TextCollectPercent = nil
	--self.TextContent = nil
	--self.TextCumulativeQuantity = nil
	--self.TextNoInfo = nil
	--self.TextNull = nil
	--self.TextNum = nil
	--self.TextQuantity = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.SoundStartPath = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommSearchBar6)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.ItmeBox)
	self:AddSubView(self.ItmeCard)
	self:AddSubView(self.ScreenerBtn)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardMainPanelView:OnInit()
	self.MagicCardAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.CardBox, self.OnMagicCardSelectChanged, true, false)
	self.MagicCardGetWayAdapter = UIAdapterTableView.CreateAdapter(self, self.ListTask1, self.OnMagicCardGetWaySelect, true, false)
	self.Binders = {
		{"MagicCardVMList", UIBinderUpdateBindableList.New(self, self.MagicCardAdapterTableView)},
		{"SelectedCardIndex", UIBinderSetSelectedIndex.New(self, self.MagicCardAdapterTableView)},
		{"IsCheckLocked", UIBinderSetIsChecked.New(self, self.SingleBox.ToggleButton)},
		{"MagicCardUnlockNumText", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
		{"CurCardIndexNumText", UIBinderSetText.New(self, self.TextCardnumber)}, -- 编号
		{"MagicCardTotalCollectNumText", UIBinderSetText.New(self, self.TextCumulativeQuantity)},
		{"CurSelectedCard", UIBinderValueChangedCallback.New(self, nil, self.OnSelectCardChanged)},
		{"CollectPercent", UIBinderValueChangedCallback.New(self, nil, self.OnSelectCardCollectPercentChanged)},
		{"MagicCardUnlockPercent", UIBinderValueChangedCallback.New(self, nil, self.OnCardUnLockPercentChanged)},
		{"IsSearchEmpty", UIBinderValueChangedCallback.New(self, nil, self.OnIsSearchEmptyChanged)},
	}
	self.CommonTitle:SetCommInforBtnIsVisible(false)
	UIUtil.SetIsVisible(self.ItmeCard.CardDisable, false)
	UIUtil.SetIsVisible(self.ItmeCard.ImgCardSelect, false)
	UIUtil.SetIsVisible(self.ImgBgYellow, false)
	UIUtil.SetIsVisible(self.PanelInfo, false) --测试版本屏蔽留言功能
	self.CardWidgetInfos = {
		self.CardBox,
		self.PanelCarddetails,
		self.ScrollBox,
		self.PanelCardname,

	}
end

function MagicCardMainPanelView:OnDestroy()

end

function MagicCardMainPanelView:SetLSTR()
	self.CommonTitle:SetTextTitleName(_G.LSTR(1140012))--("九宫幻卡收藏册")
	self.CommEmpty:SetTipsContent(_G.LSTR(1140014))--("未搜索到相关幻卡")
	self.TextBlock:SetText(_G.LSTR(1140013))--("获取途径")
	self.TextNoInfo:SetText(_G.LSTR(1140011))--("详细信息将在收录该幻卡后显示")
	self.SingleBox:SetText(_G.LSTR(1140015))--("未收录")
end

function MagicCardMainPanelView:OnShow()
	self:SetLSTR()
	self.SingleBox:SetChecked(false)
	self.ScreenerBtn:SetChecked(false)
	self.CommSearchBar6:SetHintText(MagicCardCollectionDefine.SearchTipText)

	local function ScrollToIndex()
		local DefaultSelectIndex = MagicCardCollectionVM.SelectedCardIndex
		if DefaultSelectIndex and DefaultSelectIndex > 0 then
			self.MagicCardAdapterTableView:ScrollToIndex(DefaultSelectIndex)
		end
	end
	self:RegisterTimer(ScrollToIndex,0.2)
	AudioUtil.LoadAndPlayUISound(self.SoundStartPath:ToString())
end

function MagicCardMainPanelView:OnHide()
	MagicCardCollectionVM:RemoveNewUnLockCard()
end

function MagicCardMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnClickButtonClose)
	UIUtil.AddOnClickedEvent(self, self.ItmeBox.Btn, self.OnClickCollectAward)
	self.SingleBox:SetStateChangedCallback(self, self.OnCheckStateChanged)
	self.ScreenerBtn:SetStateChangedCallback(self, self.OnBtnfilterClicked)
	self.CommSearchBar6:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
end

function MagicCardMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScreenerResult, self.OnScreenerAction)
	self:RegisterGameEvent(EventID.HideUI, self.OnHideView)
	self:RegisterGameEvent(EventID.ShowUI, self.OnShowView)
end

function MagicCardMainPanelView:OnHideView(ViewID)
    if ViewID == nil then
        return
    end

	if ViewID == _G.UIViewID.ScreenerWin then
		self.ScreenerBtn:SetChecked(self.IsInFiltering)
	end

	if ViewID == _G.UIViewID.CollectionAwardPanel then
		UIUtil.SetIsVisible(self.BtnBack, true)
	end
end

function MagicCardMainPanelView:OnShowView(ViewID)
    if ViewID == nil then
        return
    end

	if ViewID == _G.UIViewID.CollectionAwardPanel then
		UIUtil.SetIsVisible(self.BtnBack, false)
	end
end

---@type 筛选结果处理
function MagicCardMainPanelView:OnScreenerAction(ScreenerResult)
	self.ScreenerSelectedInfo = ScreenerResult and ScreenerResult.ScreenerList or {}
	if ScreenerResult == nil then
		self:OnScreenerWithEmpty()
	else
		self.SingleBox:SetChecked(false)
		self.CommSearchBar6:OnClickButtonCancel() --取消搜索
		MagicCardCollectionVM:OnScreenerAction(ScreenerResult)
		self.IsInFiltering = true
		self:SwitchToSelected()
	end
end

function MagicCardMainPanelView:OnScreenerWithEmpty()
	self.ScreenerBtn:SetChecked(false)
	self.IsInFiltering = false
	self:OnCancelSelect()
	MagicCardCollectionVM:OnCancelSearch()
	self:SwitchToSelected()
end

function MagicCardMainPanelView:OnRegisterBinder()
	self:RegisterBinders(MagicCardCollectionVM, self.Binders)
end

---@type 选中列表中的幻卡
function MagicCardMainPanelView:OnMagicCardSelectChanged(Index, ItemData, ItemView)
	self.CurSelectCardIdx = Index
	if ItemData and ItemData.CardID then
		ItemData.IsNewUnlock = false
		MagicCardCollectionMgr:SendNetMsgMagicCardCollectionCount(ItemData.CardID)
	end
	MagicCardCollectionVM:OnMagicCardSelected(Index)
end

---@type 关闭当前界面
function MagicCardMainPanelView:OnClickButtonClose()
	self:Hide()
end

---@type 点击进度奖励
function MagicCardMainPanelView:OnClickCollectAward()
	MagicCardCollectionMgr:OnCollectionAwardClicked()
end

---@type 点击过滤
function MagicCardMainPanelView:OnBtnfilterClicked(IsChecked)
	local ScreenerWinView = UIViewMgr:ShowView(_G.UIViewID.ScreenerWin, {RelatedSystem = ProtoRes.ScreenerRelatedSystem.MAGIC_CARD_SYSTEM, 
	SystemRelatedValue = 1, ScreenerSelectedInfo = self.ScreenerSelectedInfo})
	if ScreenerWinView and ScreenerWinView.Bg then
		ScreenerWinView.Bg.FText_Title:SetText(MagicCardCollectionDefine.CardFilterText)
	end
end



function MagicCardMainPanelView:OnSelectCardChanged(SelectCard)
	-- local SelectCard = MagicCardCollectionVM:GetCurMagicCardByIndex(Index)
	-- if SelectCard == nil then
	-- 	return
	-- end
	if SelectCard == nil or next(SelectCard) == nil then
		return
	end
	
	local SelectCardID = SelectCard.CardID or 0
	local IsUnLock = SelectCard.IsUnLock
	local ItemCfg = CardCfg:FindCfgByKey(SelectCardID)
	if nil == ItemCfg then
		Log.E("MagicCardCardItemView:OnCardIdChanged CardId error: [%d]", SelectCardID)
		return
	end

	local UnLockDesc = ItemCfg.Desc ~= nil and ItemCfg.Desc or "Desc is not config"
	local CardDesc = UnLockDesc
	local CardName = IsUnLock and ItemCfg.Name or MagicCardCollectionDefine.LockNameText
	UIUtil.SetIsVisible(self.PanelNoInfo, not IsUnLock)
	UIUtil.SetIsVisible(self.TextContent, IsUnLock)

	self.ItmeCard:OnCardIDChanged(SelectCardID)
	self.ItmeCard:UpdateFrameType(IsUnLock, SelectCard.FrameType)

	self.TextContent:SetText(CardDesc)
	self.TextCardname:SetText(CardName)
	self:OnCardhanged(SelectCardID)
end

function MagicCardMainPanelView:OnCardUnLockPercentChanged(Percent)
	self.ItmeBox:OnPerCentChanged(Percent)
end

function MagicCardMainPanelView:OnSelectCardCollectPercentChanged(CollectPercent)
	if CollectPercent == nil then
		return
	end

	local CollectPercentText = string.format( MagicCardCollectionDefine.CollectPercentText, CollectPercent)
	local IsRare = CollectPercent <= 1
	UIUtil.SetIsVisible(self.ImgBgYellow, IsRare)
	UIUtil.SetIsVisible(self.ImgBgAsh, not IsRare)
	self.TextCollectPercent:SetText(CollectPercentText)
end

function MagicCardMainPanelView:OnCardhanged(NewCardID)
	local CommGetWayItems = ItemUtil.GetItemGetWayList(NewCardID)
	--限制获取途径显示数
	if CommGetWayItems then
		local Length = #CommGetWayItems
		for i = Length, 1, -1 do
			if #CommGetWayItems > MagicCardCollectionDefine.MaxGetWayShow then
				table.remove(CommGetWayItems, i)
			end
		end
	end
	self.MagicCardGetWayAdapter:UpdateAll(CommGetWayItems)
end


function MagicCardMainPanelView:OnMagicCardGetWaySelect(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	if not ItemData.IsUnLock then
		MsgTipsUtil.ShowTips(MagicCardCollectionDefine.LockGetWayTips)
		return
	end

	if ItemData.IsRedirect == 0 then --跳转状态为0不跳转
		return
	end

	local ItemUtil = require("Utils/ItemUtil")
	ItemUtil.JumpGetWayByItemData(ItemData)
end

--------------------------------------------搜索幻卡------------------------------------------------------
-----------

---@type 关闭搜索框
function MagicCardMainPanelView:OnClickCancelSearchBar()
	self:OnCancelSelect()
	MagicCardCollectionVM:OnCancelSearch()
	self:SwitchToSelected()
end

---@type 提交搜索
function MagicCardMainPanelView:OnSearchTextCommitted(SearchText)
	self:OnCancelSelect()
	--重置筛选状态和单项筛选CheckBOX
	self.SingleBox:SetChecked(false)
	self.ScreenerBtn:SetChecked(false)
	MagicCardCollectionVM:OnSearchCardByText(SearchText)
	self:SwitchToSelected()
end

function MagicCardMainPanelView:OnIsSearchEmptyChanged(IsSearchEmpty)
	UIUtil.SetIsVisible(self.PanelNull, IsSearchEmpty)
	if IsSearchEmpty then
		UIUtil.SetIsVisible(self.PanelNoInfo, false)
	end

	for _, Widget in ipairs(self.CardWidgetInfos) do
		UIUtil.SetIsVisible(Widget, not IsSearchEmpty, true)
	end
end

function MagicCardMainPanelView:OnCancelSelect()
	self.MagicCardAdapterTableView:CancelSelected()
end

---@type 单项筛选未解锁
function MagicCardMainPanelView:OnCheckStateChanged(IsChecked)
	MagicCardCollectionVM:OnSearchCardByTag(IsChecked)
	self:SwitchToSelected()
end

function MagicCardMainPanelView:SwitchToSelected()
	local DefaultSelectIndex = MagicCardCollectionVM:GetSelectedCardIdx()
	if DefaultSelectIndex and DefaultSelectIndex > 0 then
		self.MagicCardAdapterTableView:SetSelectedIndex(DefaultSelectIndex)
		self.MagicCardAdapterTableView:ScrollToIndex(DefaultSelectIndex)
	end
end
--------------------------------------------搜索幻卡 End------------------------------------------------------

-- function MagicCardMainPanelView:RefreshNewTabRed()
	
-- 	for i, v in ipairs(self.Tabs) do
-- 		local HideNewRed = (v.Key == AdventureDefine.MainTabIndex.Weekly and AdventureMgr:IsStageRewardCanGet())
-- 		if not HideNewRed and AdventureMgr:IsCurPageNew(v.Key) then
-- 			RedDotMgr:AddRedDotByID(AdventureDefine.TabNewRed[v.Key].Child)
-- 		else
-- 			if AdventureDefine.TabNewRed[v.Key] then
-- 				RedDotMgr:DelRedDotByID(AdventureDefine.TabNewRed[v.Key].Child)
-- 			end
-- 		end
-- 	end


-- end

return MagicCardMainPanelView