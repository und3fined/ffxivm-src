---
--- Author: Administrator
--- DateTime: 2025-07-28 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local NightGiftReceiveRecordVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftReceiveRecordVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local LSTR = _G.LSTR
---@class NightGiftReceiveRecordWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field CommBackpackEmpty CommBackpackEmptyView
---@field FTreeViewList UFTreeView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftReceiveRecordWinView = LuaClass(UIView, true)

local PutGiftTitle =
{
	[1] = LSTR(1700018),
	[2] = LSTR(1700019),
	[3] = LSTR(1700020),
}

local GetGiftTitle =
{
	[1] = LSTR(1700015),
	[2] = LSTR(1700016),
	[3] = LSTR(1700017),
}

function NightGiftReceiveRecordWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommBackpackEmpty = nil
	--self.FTreeViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftReceiveRecordWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommBackpackEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftReceiveRecordWinView:OnInit()
	self.ViewModel = NightGiftReceiveRecordVM.New()
	self.TreeViewAdapter = UIAdapterTreeView.CreateAdapter(self, self.FTreeViewList)
    self.Binders = {
        { "GiftTreeList", UIBinderUpdateBindableList.New(self, self.TreeViewAdapter)},
		{ "EmptyVisible", UIBinderSetIsVisible.New(self, self.CommBackpackEmpty)},
		
    }
end

function NightGiftReceiveRecordWinView:OnDestroy()

end

function NightGiftReceiveRecordWinView:OnShow()
	if self.Params == nil then
		return
	end

	local PutGift = self.Params.PutGift
	if PutGift then
		self.BG:SetTitleText(LSTR(1700008))
		self.CommBackpackEmpty:SetTipsContent(LSTR(1700022))
		local PutGiftValues = {}
		local StarPutGift = PutGift.Extra.StarPutGift or {}
		local PutGift = StarPutGift.Gifts or {}
		for i, value in ipairs(PutGift) do
			table.insert(PutGiftValues, {Title = PutGiftTitle[i], Gift = value, Index = i + (i-1)*100 })
		end

		self.ViewModel:UpdateGiftRecordInfo(PutGiftValues)
	end

	local GetGift = self.Params.GetGift
	if GetGift then
		self.BG:SetTitleText(LSTR(1700014))
		self.CommBackpackEmpty:SetTipsContent(LSTR(1700023))
		local GetGiftValues = {}
		local StarGift = GetGift.Extra.StarGift or {}
		local GetGift = StarGift.Gifts or {}
		for i, value in ipairs(GetGift) do
			table.insert(GetGiftValues, {Title = GetGiftTitle[i], Gift = value, Index = i + (i-1)*100 })
		end

		self.ViewModel:UpdateGiftRecordInfo(GetGiftValues)
	end
end

function NightGiftReceiveRecordWinView:OnHide()

end

function NightGiftReceiveRecordWinView:OnRegisterUIEvent()

end

function NightGiftReceiveRecordWinView:OnRegisterGameEvent()

end

function NightGiftReceiveRecordWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return NightGiftReceiveRecordWinView