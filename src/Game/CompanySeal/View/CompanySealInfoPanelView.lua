---
--- Author: Administrator
--- DateTime: 2024-06-12 15:28
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CompanySealInfoWinVM = require("Game/CompanySeal/View/Item/CompanySealInfoWinVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")




local CurLv = 0

---@class CompanySealInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg01_UIBP CommonBkg01View
---@field CommonTitle CommonTitleView
---@field IconMilitaryrank UFImage
---@field IconMilitaryrank_1 UFImage
---@field IconMoney UFImage
---@field ImgArmyBG UFImage
---@field ImgArmyLogo UFImage
---@field ImgFlag UFImage
---@field RichTextBoxHint URichTextBox
---@field TableViewList UTableView
---@field TextAmount UFTextBlock
---@field TextCompanySeal UFTextBlock
---@field TextCondition UFTextBlock
---@field TextCurrentrank UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMilitaryRank UFTextBlock
---@field TextMilitaryRankLevel UFTextBlock
---@field TextMoney UFTextBlock
---@field TextPrivilege UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealInfoPanelView = LuaClass(UIView, true)

function CompanySealInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CommonBkg01_UIBP = nil
	--self.CommonTitle = nil
	--self.IconMilitaryrank = nil
	--self.IconMilitaryrank_1 = nil
	--self.IconMoney = nil
	--self.ImgArmyBG = nil
	--self.ImgArmyLogo = nil
	--self.ImgFlag = nil
	--self.RichTextBoxHint = nil
	--self.TableViewList = nil
	--self.TextAmount = nil
	--self.TextCompanySeal = nil
	--self.TextCondition = nil
	--self.TextCurrentrank = nil
	--self.TextLevel = nil
	--self.TextMilitaryRank = nil
	--self.TextMilitaryRankLevel = nil
	--self.TextMoney = nil
	--self.TextPrivilege = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg01_UIBP)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealInfoPanelView:OnInit()
	self.ViewModel = CompanySealInfoWinVM.New()
	self.RankTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{ "RankList", UIBinderUpdateBindableList.New(self, self.RankTableViewAdapter) },
		--{ "TitleText", UIBinderSetText.New(self, self.Comm2FrameL_UIBP.FText_Title) },
		{ "LeftDesc", UIBinderSetText.New(self, self.RichTextBoxHint) },
		{ "TextLevel", UIBinderSetText.New(self, self.TextLevel) },
		{ "TextMilitaryRank", UIBinderSetText.New(self, self.TextMilitaryRank) },
		{ "TextCompanySeal", UIBinderSetText.New(self, self.TextCompanySeal) },
		{ "TextCondition", UIBinderSetText.New(self, self.TextCondition) },
		{ "GrandIcon", UIBinderSetImageBrush.New(self, self.ImgFlag)},
		{ "TitleText", UIBinderSetText.New(self, self.CommonTitle.TextTitleName) },
		{ "CurrentrankDes", UIBinderSetText.New(self, self.TextCurrentrank) },
		{ "RankIcon", UIBinderSetImageBrush.New(self, self.IconMilitaryrank)},
		{ "RankLevel", UIBinderSetText.New(self, self.TextMilitaryRankLevel) },	
		{ "CurAmount", UIBinderSetText.New(self, self.TextAmount) },
		{ "SealIcon", UIBinderSetImageBrush.New(self, self.IconMoney)},
		{ "TextMoneyDes", UIBinderSetText.New(self, self.TextMoney) },	
		{ "TextPrivilege", UIBinderSetText.New(self, self.TextPrivilege) },
		{ "LockIconVisible", UIBinderSetIsVisible.New(self, self.IconMilitaryrank_1) },
		{ "RightInfoVisible", UIBinderSetIsVisible.New(self, self.FHorizontalBox_0) },
		{ "ArmyLogo", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyLogo) },	
		{ "ArmyBG", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyBG) },
	}
end

function CompanySealInfoPanelView:OnDestroy()

end

function CompanySealInfoPanelView:OnShow()
	self.CommonTitle:SetCommInforBtnIsVisible(false)
	CurLv = CompanySealMgr.MilitaryLevel or 0
	self.GrandCompanyID = self.Params.GrandCompanyID
	self.ViewModel:UpdateTextInfo(self.GrandCompanyID)
	self:UpdateRankList()
end

function CompanySealInfoPanelView:OnHide()

end

function CompanySealInfoPanelView:OnRegisterUIEvent()

end

function CompanySealInfoPanelView:OnRegisterGameEvent()

end

function CompanySealInfoPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end	

function CompanySealInfoPanelView:UpdateRankList()
	local List = CompanySealMgr.CompanyRankList[self.GrandCompanyID]
	--table.sort(List, self.SotrRankList)
	self.ViewModel:UpdateRankListInfo(List)
	if self.GrandCompanyID == CompanySealMgr.GrandCompanyID then
		self.RankTableViewAdapter:ScrollToIndex(CurLv)
	end
end

function CompanySealInfoPanelView:OnRankSelectChanged(Index, ItemData, ItemView)
	FLOG_ERROR("OnRankSelectChanged = %d", Index)
end

function CompanySealInfoPanelView.SotrRankList(l, r)
	if l.Level == CurLv then
		return true
	elseif r.Level == CurLv then
		return false
	else
		return l.Level < r.Level
	end
end

return CompanySealInfoPanelView