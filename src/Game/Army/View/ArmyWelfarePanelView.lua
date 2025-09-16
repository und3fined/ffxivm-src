---
--- Author: Administrator
--- DateTime: 2023-11-22 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyMgr = nil
local ShopMgr = nil

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local GroupUplevelpermissionCfg = require("TableCfg/GroupUplevelpermissionCfg")

local ArmyWelfarePanelVM = nil

---@class ArmyWelfarePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewWelFare UTableView
---@field AnimIn UWidgetAnimation
---@field ItemOffsetY int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyWelfarePanelView = LuaClass(UIView, true)

function ArmyWelfarePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewWelFare = nil
	--self.AnimIn = nil
	--self.ItemOffsetY = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyWelfarePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyWelfarePanelView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	ShopMgr = require("Game/Shop/ShopMgr")
	ArmyWelfarePanelVM = ArmyMainVM:GetWelfarePanelVM()
	local OffsetYList = {}
	for Index = 1, 4 do
		if self.ItemOffsetY and self.ItemOffsetY[Index] then
            local OffsetY = self.ItemOffsetY[Index]
			table.insert(OffsetYList, OffsetY)
        end
	end
	ArmyWelfarePanelVM:SetItemOffsetY(OffsetYList)
	self.TableViewAdapter  = UIAdapterTableView.CreateAdapter(self, self.TableViewWelFare)
	self.TableViewAdapter:SetOnClickedCallback(self.OnClickedStateItem)
    self.Binders = {
        {"WelfareList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)}, 
    }
end

function ArmyWelfarePanelView:OnDestroy()

end

function ArmyWelfarePanelView:OnShow()
	ArmyWelfarePanelVM:UpdateArmyWelfareInfo()
	--ArmyMainVM:SetIsMask(false)
end

function ArmyWelfarePanelView:OnHide()
	--ArmyMainVM:SetIsMask(true)
end

function ArmyWelfarePanelView:OnClickedStateItem(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end
	if ItemData.IsLocked then
		return
	end
	if ItemData.ID == ArmyDefine.ArmyWelfarePageId.Store then
		--ArmyMgr:OpenArmyStore(StoreIndex, IsArmyopen)
		---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
		if ArmyMgr:GetArmyStoreIsOpen() then
			ArmyMgr:OpenArmyStore()
		else
			_G.MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.NoOpenArmyStore)
		end
	elseif ItemData.ID == ArmyDefine.ArmyWelfarePageId.Shop then
		ArmyMgr:OpenArmyShopPanel()
	elseif ItemData.ID == ArmyDefine.ArmyWelfarePageId.SE then
		ArmyMgr:OpenArmySEPanel()
	end
end

function ArmyWelfarePanelView:OpenArmyStore(StoreIndex)
	
end

function ArmyWelfarePanelView:OnRegisterUIEvent()

end

function ArmyWelfarePanelView:OnRegisterGameEvent()

end

function ArmyWelfarePanelView:OnRegisterBinder()
    self:RegisterBinders(  ArmyWelfarePanelVM, self.Binders)
end

function ArmyWelfarePanelView:IsForceGC()
	return true
end

return ArmyWelfarePanelView