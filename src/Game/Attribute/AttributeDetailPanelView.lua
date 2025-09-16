---
--- Author: enqingchen
--- DateTime: 2021-12-31 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AttributeDetailPanelVM = require("Game/Attribute/VM/AttributeDetailPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MajorUtil = require("Utils/MajorUtil")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

---@class AttributeDetailPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableView UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AttributeDetailPanelView = LuaClass(UIView, true)

function AttributeDetailPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableView = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AttributeDetailPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AttributeDetailPanelView:OnInit()
	self.ViewModel = AttributeDetailPanelVM.New()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableView)
	self.AdapterTableView:SetScrollbarIsVisible(false)
	
end

function AttributeDetailPanelView:OnDestroy()
end

function AttributeDetailPanelView:OnShow()
	self:PlayAnimation(self.AnimIn)
	self.ViewModel:GenDetailAttribute(MajorUtil.GetMajorEntityID())
	_G.EquipmentMgr:RegisterCombatAttrMsg()
	_G.EquipmentMgr:UpdateAttrFromAttrCmp()
	local DelayTime = self.AnimIn:GetEndTime() or 0
	self:RegisterTimer(function()
		self:PlayAnimation(self.AnimIn, DelayTime, 1, 0, 1.0, false)
	end, DelayTime, 0, 1)
end

function AttributeDetailPanelView:OnHide()
	self:PlayAnimation(self.AnimOut)
	_G.EquipmentMgr:UnRegisterCombatAttrMsg()
end

function AttributeDetailPanelView:OnRegisterUIEvent()

end

function AttributeDetailPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.AttributeDetailOpen, self.OnAttributeDetailOpen)
	self:RegisterGameEvent(_G.EventID.Major_Attr_Change, self.OnMajorAttrChange)
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnMajorProfSwitch)
	self:RegisterGameEvent(_G.EventID.MajorLevelSyncSwitch, self.OnLevelSyncSwitch)
end

function AttributeDetailPanelView:OnRegisterBinder()
	local Binders = {
		{ "lstAttributeDetailDescItemVM", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
	}
	self:RegisterBinders(self.ViewModel, Binders)

	local Binders1 = {
		{ "UnSteadyMap", UIBinderValueChangedCallback.New(self, nil, self.OnUnSteadyMapChange) },
	}
	self:RegisterBinders(EquipmentVM, Binders1)
end

function AttributeDetailPanelView:OnAttributeDetailOpen(Params)
	local bOpen = Params.BoolParam1
	local Index = Params.IntParam1
	self.ViewModel:SetOpen(Index, bOpen)
end

function AttributeDetailPanelView:OnMajorAttrChange(Params)
	self.ViewModel:UpdateAllAttr()
end

function AttributeDetailPanelView:OnUnSteadyMapChange()
	if EquipmentVM == nil or EquipmentVM.UnSteadyMap == nil then
		return
	end
	-- _G.UE.FProfileTag.StaticBegin("view-OnUnSteadyMapChange")
	--动态属性变更
	for Key,_ in pairs(EquipmentVM.UnSteadyMap) do
		self.ViewModel:UpdateAttr(Key)
	end
	-- _G.UE.FProfileTag.StaticEnd()
end

function AttributeDetailPanelView:OnMajorProfSwitch(Params)
	if nil == Params then
		return
	end
	self.ViewModel:GenDetailAttribute(MajorUtil.GetMajorEntityID())
end

function AttributeDetailPanelView:OnLevelSyncSwitch()
	self.ViewModel:UpdateLevelSyncState()
end

function AttributeDetailPanelView:ReScrollToTop()
	self.AdapterTableView:ScrollToTop()
end

return AttributeDetailPanelView