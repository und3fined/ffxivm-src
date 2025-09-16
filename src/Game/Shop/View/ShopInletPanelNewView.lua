---
--- Author: Administrator
--- DateTime: 2023-10-13 14:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreSummaryTypeCfg = require("TableCfg/ScoreSummaryTypeCfg")
local EquipmentCurrencyVM = require("Game/Equipment/VM/EquipmentCurrencyVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ShopInletPanelNewVM = require("Game/Shop/ShopInletPanelNewVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local ShopMgr = require("Game/Shop/ShopMgr")
local EventID = require("Define/EventID")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr


---@class ShopInletPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field ImgBg UFImage
---@field TabList ShopTabListItemNewView
---@field TableViewList UTableView
---@field TextTitleName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopInletPanelNewView = LuaClass(UIView, true)

function ShopInletPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.ImgBg = nil
	--self.TabList = nil
	--self.TableViewList = nil
	--self.TextTitleName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopInletPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.TabList)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopInletPanelNewView:OnInit()
	self.ViewModel = ShopInletPanelNewVM.New()
	self.ShopTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList,self.OnSelectChanged,true)
	
	self.Binders = {
		{ "CurShopList", UIBinderUpdateBindableList.New(self, self.ShopTableViewAdapter) },
	}
end

function ShopInletPanelNewView.Comp(V1, V2)
	local ScoreSumType1 = V1.ScoreSumType or V1.ShowTypeIndex
	local ScoreSumType2 = V2.ScoreSumType or V2.ShowTypeIndex
    if ScoreSumType1 < ScoreSumType2 then
        return true
    else
        return false
    end
end

function ShopInletPanelNewView:OnDestroy()

end

function ShopInletPanelNewView:OnShow()
	self:GetSummaryType()
	self.FirstTabList = self:GetFirstTabInfo()
	self.TabList:UpdateItems(self.FirstTabList)
	self.TabList:SetSelectedIndex(1)
	self:InintShopTypeList(1)
end

function ShopInletPanelNewView:OnHide()

end

function ShopInletPanelNewView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.TabList, self.UpdateShopTypeList)
end

function ShopInletPanelNewView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.OpenShop, self.OpenShop)
end

function ShopInletPanelNewView:OpenShop(MallId)
	local ItemData = {}
	ItemData.ShopId = MallId
	ItemData.Open = 1
	UIViewMgr:ShowView(UIViewID.ShopMainPanelNewView, ItemData)
end

function ShopInletPanelNewView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ShopInletPanelNewView:OnSelectChanged(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ShopId == 0 or ItemData.ShopId == nil then
		FLOG_ERROR("没有商店ID 信息")
		return
	end

	--open = 1 从商会打开商店 = 2 从Npc打开商店
	--ItemData.Open = 1
	ShopMgr:SendMsgMallInfoReq(ItemData.ShopId,1)
end

function ShopInletPanelNewView:InintShopTypeList(Index)
	ShopMgr.ShopMainIndex = Index
	local ShopList = ShopMgr:GetShopCfgByTab(self.FirstTabList[ShopMgr.ShopMainIndex].ShowTypeIndex)
	self.ViewModel:UpdateShopListInfo(ShopList)
	self:PlayAnimation(self.AnimUpdateList)
end

function ShopInletPanelNewView:UpdateShopTypeList(Index)
	if Index ==  ShopMgr.ShopMainIndex then
		return
	end
	ShopMgr.ShopMainIndex = Index
	local ShopList = ShopMgr:GetShopCfgByTab(self.FirstTabList[ShopMgr.ShopMainIndex].ShowTypeIndex)
	self.ViewModel:UpdateShopListInfo(ShopList)
	self:PlayAnimation(self.AnimUpdateList)
end

function ShopInletPanelNewView:CheckListDataItemIsExist()
	local TempListData = {}
	for i = 1, #self.ListData do
		if EquipmentCurrencyVM:CheckCurrencyTypeIsExist(self.ListData[i].ScoreSumType) then
			table.insert(TempListData, self.ListData[i])
		end
	end
	return #TempListData == #self.ListData and self.ListData or TempListData
end

function ShopInletPanelNewView:GetSummaryType()
	self.ListData = {}
	for _, value in pairs(ProtoRes.ScoreSummaryType) do
		if value > 0 then
			local SearchConditions = string.format("%s%s", "ScoreSumType=", tostring(value))
			local Cfg = ScoreSummaryTypeCfg:FindCfg(SearchConditions)
			local Data
			if Cfg ~= nil then
				Data = {Name = Cfg.ScoreSummaryTabShow, ScoreSumType = Cfg.ScoreSumType}
			else
				local TabName = ProtoEnumAlias.GetAlias(ProtoRes.ScoreSummaryType, value)
				Data = {Name = TabName, ScoreSumType = value}
			end
		end
	end
	table.sort(self.ListData, self.Comp)
end

function ShopInletPanelNewView:GetFirstTabInfo()
	local List = ShopMgr:GetFirstTypeTab()
	local NewList = {}
	for i = 1, #self.ListData do
		for j = 1, #List do
			if self.ListData[i].Name == List[j].Name then
				List[j].ScoreSumType = self.ListData[i].ScoreSumType
			end
		end
	end

	for i = 1, #List do
		local UnlockShop = ShopMgr:GetShopCfgByTab(List[i].ShowTypeIndex)
		if #UnlockShop > 0 then
			table.insert(NewList, List[i])
		end
	end

	table.sort(NewList, self.Comp)
	return NewList
end

return ShopInletPanelNewView