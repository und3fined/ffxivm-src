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


local CurLv = 0

---@class CompanySealInfoWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field ImgFlag UFImage
---@field RichTextInfo URichTextBox
---@field TableView_49 UTableView
---@field TextCompanySeal UFTextBlock
---@field TextCondition UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMilitaryRank UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealInfoWinView = LuaClass(UIView, true)

function CompanySealInfoWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.ImgFlag = nil
	--self.RichTextInfo = nil
	--self.TableView_49 = nil
	--self.TextCompanySeal = nil
	--self.TextCondition = nil
	--self.TextLevel = nil
	--self.TextMilitaryRank = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealInfoWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealInfoWinView:OnInit()
	self.ViewModel = CompanySealInfoWinVM.New()
	self.RankTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_49, self.OnRankSelectChanged, true)
	self.Binders = {
		{ "RankList", UIBinderUpdateBindableList.New(self, self.RankTableViewAdapter) },
		{ "TitleText", UIBinderSetText.New(self, self.Comm2FrameL_UIBP.FText_Title) },
		{ "LeftDesc", UIBinderSetText.New(self, self.RichTextInfo) },
		{ "TextLevel", UIBinderSetText.New(self, self.TextLevel) },
		{ "TextMilitaryRank", UIBinderSetText.New(self, self.TextMilitaryRank) },
		{ "TextCompanySeal", UIBinderSetText.New(self, self.TextCompanySeal) },
		{ "TextCondition", UIBinderSetText.New(self, self.TextCondition) },
		{ "GrandIcon", UIBinderSetImageBrush.New(self, self.ImgFlag)},
	}
end

function CompanySealInfoWinView:OnDestroy()

end

function CompanySealInfoWinView:OnShow()
	CurLv = CompanySealMgr.MilitaryLevel or 0
	self.GrandCompanyID = self.Params.GrandCompanyID
	self.ViewModel:UpdateTextInfo(self.GrandCompanyID)
	self:UpdateRankList()
end

function CompanySealInfoWinView:OnHide()

end

function CompanySealInfoWinView:OnRegisterUIEvent()

end

function CompanySealInfoWinView:OnRegisterGameEvent()

end

function CompanySealInfoWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end	

function CompanySealInfoWinView:UpdateRankList()
	local List = CompanySealMgr.CompanyRankList[self.GrandCompanyID]
	--table.sort(List, self.SotrRankList)
	self.ViewModel:UpdateRankListInfo(List)
	if self.GrandCompanyID == CompanySealMgr.GrandCompanyID then
		self.RankTableViewAdapter:ScrollToIndex(CurLv)
	end
end

function CompanySealInfoWinView:OnRankSelectChanged(Index, ItemData, ItemView)
	FLOG_ERROR("OnRankSelectChanged = %d", Index)
end

function CompanySealInfoWinView.SotrRankList(l, r)
	if l.Level == CurLv then
		return true
	elseif r.Level == CurLv then
		return false
	else
		return l.Level < r.Level
	end
end

return CompanySealInfoWinView