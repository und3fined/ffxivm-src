local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TitleMgr = require("Game/Title/TitleMgr")
local TitleDefine = require("Game/Title/TitleDefine")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local TitleMainPanelVM = require("Game/Title/View/TitleMainPanelVM")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")


local AchievementMgr = _G.AchievementMgr
local LSTR = _G.LSTR
local ButtonStyle = TitleDefine.ButtonStyle
local EToggleButtonState = _G.UE.EToggleButtonState
local AllTypeID = TitleDefine.AppendTitleType[2].ID

---@class TitleMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnFavorite UToggleButton
---@field BtnGoto UFButton
---@field BtnUse CommBtnLView
---@field CommMenu CommMenuView
---@field CommonBkg CommonBkg01View
---@field ImgGatWay UFImage
---@field ImgGoto UFImage
---@field PanelContent UFCanvasPanel
---@field PanelNone UFCanvasPanel
---@field SearchBar CommSearchBarView
---@field TableViewList UTableView
---@field TextAchive UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimSearch UWidgetAnimation
---@field AnimSetTitle UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TitleMainPanelView = LuaClass(UIView, true)

function TitleMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnFavorite = nil
	--self.BtnGoto = nil
	--self.BtnUse = nil
	--self.CommMenu = nil
	--self.CommonBkg = nil
	--self.ImgGatWay = nil
	--self.ImgGoto = nil
	--self.PanelContent = nil
	--self.PanelNone = nil
	--self.SearchBar = nil
	--self.TableViewList = nil
	--self.TextAchive = nil
	--self.TextEmpty = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--self.AnimSearch = nil
	--self.AnimSetTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TitleMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.SearchBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TitleMainPanelView:OnInit()
	UIUtil.SetIsVisible(self.TextSubtitle, true)
	self.SearchBar:SetCallback(self, nil, self.SearchCommittedCB, self.SearchCancelCB)
	self.BtnBack:AddBackClick(self, self.Hide)
	self.CurrentShowType = nil
	self.MenuDataList = {}
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList,  self.TableViewListSelectChanged, true)

	local TypeList = TitleMgr:GetAllTitleType()
	for i = 1, #TypeList do
		table.insert(self.MenuDataList, { Key = TypeList[i].ID , Name = TypeList[i].TypeName or "" })
	end

	self.Binders = {
		{ "CurrentTitleText", UIBinderSetText.New(self, self.TextSubtitle) },
		{ "TitleList", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter) },
		{ "AchievementText", UIBinderSetText.New(self, self.TextAchive) },
		{ "BtnFavoriteState", UIBinderSetCheckedState.New(self, self.BtnFavorite) },
		{ "UseBtnState", UIBinderValueChangedCallback.New(self, nil, self.OnUseBtnStateChange) },
		{ "AchieveIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGatWay) },
		{ "BtnGotoVisible", UIBinderSetIsVisible.New(self, self.ImgGoto) },
		{ "BtnGotoVisible", UIBinderSetIsVisible.New(self, self.BtnGoto, false, true) },

		{ "EmptyCollectionPanel", UIBinderSetIsVisible.New(self, self.PanelNone) },
		{ "EmptyCollectionPanel", UIBinderSetIsVisible.New(self, self.PanelContent, true ) },
		{ "EmptyPanelHintText", UIBinderSetText.New(self, self.TextEmpty) },
	}
end

function TitleMainPanelView:OnDestroy()

end

function TitleMainPanelView:OnShow()
	local ShowMenuList = {}
	for i = 1, #self.MenuDataList do
		if TitleMgr:GetShowTitleNumByType(self.MenuDataList[i].Key) > 0 
		or self.MenuDataList[i].Key == TitleDefine.AppendTitleType[1].ID
		or self.MenuDataList[i].Key == TitleDefine.AppendTitleType[2].ID  then 
			table.insert(ShowMenuList, self.MenuDataList[i])
		end
	end
	self.SearchBar:SetHintText(LSTR(710008))
	self.TextTitle:SetText(LSTR(710017))
	self.CommMenu:UpdateItems(ShowMenuList)
	TitleMainPanelVM:SetLastSelectTitleId(TitleMgr:GetCurrentTitle())  -- 首次打开优先选择 自己佩戴称号
	self.CommMenu:SetSelectedKey(AllTypeID, true)   -- 首次打开优先选择 “全部”分类
	
	TitleMainPanelVM:SetCurrentTitleText(TitleMgr:GetCurrentTitleText())
end

function TitleMainPanelView:OnHide()
	self.CurrentShowType = nil
	self.CommMenu:CancelSelected()
	TitleMgr:TitleUpdateLastReq()
	TitleMainPanelVM:SetSearchKeyword("")
end

function TitleMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)
    UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickedGoto)
	UIUtil.AddOnClickedEvent(self, self.BtnUse, self.OnClickedUse)
	UIUtil.AddOnClickedEvent(self, self.BtnFavorite, self.OnClickedFavorite)
end

function TitleMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TitleChange, self.OnGameEventTitleChange)
end

function TitleMainPanelView:OnRegisterBinder()
	self:RegisterBinders(TitleMainPanelVM, self.Binders)
end

function TitleMainPanelView:OnGameEventTitleChange(Params)
	if Params.EntityID == MajorUtil.GetMajorEntityID() then
		if self.AnimSetTitle then
			self:PlayAnimation(self.AnimSetTitle)
		end
	end
end

function TitleMainPanelView:TableViewListSelectChanged(Index, ItemData, ItemView)
	TitleMainPanelVM:SelectTitleChange(ItemData)
end

function TitleMainPanelView:SelectLastTitle()
	local Index = TitleMainPanelVM:GetLastSelectTitleIndex()
	if Index ~= nil then
		self.TableViewListAdapter:SetSelectedIndex(Index)
		self.TableViewListAdapter:ScrollToIndex(Index)
	end
end

function TitleMainPanelView:RefreshSelectTitleType()
	if self.CurrentShowType ~= nil then
		if AllTypeID ~= self.CurrentShowType and TitleMainPanelVM.SearchText ~= "" then
			self.SearchBar:OnClickButtonCancel()
		end
		TitleMainPanelVM:SelectTitleTypeChange(self.CurrentShowType)
		self:SelectLastTitle()
	end
end

function TitleMainPanelView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)
	if ItemData ~= nil then
		if self.CurrentShowType ~= nil then 
			TitleMgr:RemoveNewTitleFromType(self.CurrentShowType)
		end

		self.CurrentShowType = ItemData.Key
		TitleMainPanelVM:SelectTitleChange(nil)
		self:RefreshSelectTitleType()

		if self.AnimChangeTab then
			self:PlayAnimation(self.AnimChangeTab)
		end
	end
end

function TitleMainPanelView:OnUseBtnStateChange(NewValue)
	if NewValue == ButtonStyle.InUse then
		self.BtnUse:SetIsEnabled(true)
		self.BtnUse:SetText(LSTR(710003))
		self.BtnUse:SetIsNormal(true)
	elseif NewValue == ButtonStyle.UnUse then 
		self.BtnUse:SetIsEnabled(true)
		self.BtnUse:SetText(LSTR(710001))
		self.BtnUse:SetIsNormal(false)
	elseif NewValue == ButtonStyle.Lock then 
		self.BtnUse:SetIsEnabled(false)
		self.BtnUse:SetText(LSTR(710015))
	end
end

function TitleMainPanelView:OnClickedUse()
	local UseBtnState = TitleMainPanelVM.UseBtnState
	if UseBtnState == ButtonStyle.InUse then
		TitleMgr:TitleSetReq(0)
	elseif UseBtnState == ButtonStyle.UnUse then
		local TitleData = TitleMainPanelVM.CurrentSelectData
		if TitleData and TitleData.ID then
			TitleMgr:TitleSetReq(TitleData.ID)
		end
	end
end

function TitleMainPanelView:OnClickedFavorite()
	local TitleData = TitleMainPanelVM.CurrentSelectData
	if TitleData and TitleData.ID then
		if TitleMainPanelVM.BtnFavoriteState == EToggleButtonState.Checked then
			TitleMgr:UnCollectedTitle(TitleData.ID)
		else
			TitleMgr:CollectedTitle(TitleData.ID)
		end
	end
	self.BtnFavorite:SetCheckedState(TitleMainPanelVM.BtnFavoriteState)
end

function TitleMainPanelView:OnClickedGoto()
	local CurrentSelectData = TitleMainPanelVM.CurrentSelectData or {}
	local CfgData = TitleMgr:QueryTitleTableData(CurrentSelectData.ID)
	if CfgData == nil then
		MsgTipsUtil.ShowErrorTips(LSTR(710013), 1)
		return
	end
	local AchieveInfo = AchievementMgr:GetAchievementInfo(tonumber(CfgData.Condition))
	if  AchieveInfo == nil or CfgData.ConditionType ~= 1 then
		MsgTipsUtil.ShowErrorTips(LSTR(710012), 1)
		return 
	end
	AchievementMgr:OpenAchieveMainViewByAchieveID(tonumber(CfgData.Condition))
end

function TitleMainPanelView:SearchCommittedCB(Text, CommitMethod)
	if AllTypeID ~= self.CurrentShowType then
		TitleMainPanelVM:SetSearchKeyword(Text)
		self.CommMenu:SetSelectedKey(AllTypeID)
		self.CommMenu:ScrollToItemByKey(AllTypeID)
	else
		TitleMainPanelVM:InitiativeSearch(Text, self.CurrentShowType)
		self:SelectLastTitle()
	end
	self:PlayAnimation(self.AnimSearch)
end

function TitleMainPanelView:SearchCancelCB()
	TitleMainPanelVM:SetSearchKeyword("")
	self:RefreshSelectTitleType()
	self:PlayAnimation(self.AnimSearch)
end

return TitleMainPanelView