---
--- Author: Administrator
--- DateTime: 2023-08-29 03:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DepotVM = require("Game/Depot/DepotVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local DepotMgr = _G.DepotMgr

local LSTR = _G.LSTR
---@class NewBagDepotListPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonEnlarge UFButton
---@field ButtonToplimit UFButton
---@field PanelEnlarge UFCanvasPanel
---@field PanelToplimit UFCanvasPanel
---@field RichTextEnlarge URichTextBox
---@field StoreEnlarge UFCanvasPanel
---@field TableViewList UTableView
---@field TextToplimit URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagDepotListPageView = LuaClass(UIView, true)

function NewBagDepotListPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonEnlarge = nil
	--self.ButtonToplimit = nil
	--self.PanelEnlarge = nil
	--self.PanelToplimit = nil
	--self.RichTextEnlarge = nil
	--self.StoreEnlarge = nil
	--self.TableViewList = nil
	--self.TextToplimit = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagDepotListPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagDepotListPageView:OnInit()
	--self.AdapterToggleGroupItem = UIAdapterToggleGroup.CreateAdapter(self, self.TableViewList)
	self.AdapterTableViewList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChangedTableView)
	self.Binders = {
		{ "PageListPage", UIBinderUpdateBindableList.New(self, self.AdapterTableViewList) },
		{ "IsOpenEnlarge", UIBinderSetIsVisible.New(self, self.PanelEnlarge) },
		{ "IsCloseEnlarge", UIBinderSetIsVisible.New(self, self.PanelToplimit) },
	}
end

function NewBagDepotListPageView:OnDestroy()

end

function NewBagDepotListPageView:OnShow()
	local Page = DepotVM.CurrentPage or 1
	DepotVM:SetCurrentPage(Page)
	self.AdapterTableViewList:ScrollToIndex(Page)
end

function NewBagDepotListPageView:OnHide()

end

function NewBagDepotListPageView:OnRegisterUIEvent()
	--UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamicItem, self.OnToggleGroupStateChanged)
	UIUtil.AddOnClickedEvent(self, self.ButtonEnlarge, self.OnButtonEnlarge)
end

function NewBagDepotListPageView:OnRegisterGameEvent()

end

function NewBagDepotListPageView:OnRegisterBinder()
	self:RegisterBinders(DepotVM, self.Binders)

	self.RichTextEnlarge:SetText(LSTR(990071))
	self.TextToplimit:SetText(LSTR(990072))
end


function NewBagDepotListPageView:OnSelectChangedTableView(Index, ItemData, ItemView)
	DepotVM:SetCurrentPage(Index)
	DepotVM:SetDepotListVisible(false)

	local PageIndex = DepotVM:GetCurDepotIndex()
	DepotMgr:QueryDepotDetailInfo(PageIndex)
end

function NewBagDepotListPageView:OnButtonEnlarge()
	UIViewMgr:ShowView(UIViewID.DepotExpandWin, {EnlargeID = DepotVM.Enlarge})
	DepotVM:SetDepotListVisible(false)
end


return NewBagDepotListPageView