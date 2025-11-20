---
--- Author: zhangyuhao
--- DateTime: 2025-08-15 11:29
--- Description: 冒险-推荐危命
---

local BaseView = require("Game/Adventure/View/AdventureChildPageBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AdventureRecommendFateVM = require("Game/Adventure/AdventureRecommendFateVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class AdventureFateRecommendPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownList CommDropDownListView
---@field InforBtn CommInforBtnView
---@field TableList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureFateRecommendPanelView = LuaClass(BaseView, true)

function AdventureFateRecommendPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownList = nil
	--self.InforBtn = nil
	--self.TableList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureFateRecommendPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.InforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureFateRecommendPanelView:OnInit()
	self.VM = AdventureRecommendFateVM.New()
	self.FateMapReconnebdList = UIAdapterTableView.CreateAdapter(self, self.TableList)
	self.DropList = {}
	self.CurSelectLevel = 1
end

function AdventureFateRecommendPanelView:OnShow()
	self.InforBtn:SetHelpInfoID(18400)
	local FateDropList = _G.AdventureFateRecommendMgr:GetFateProfDropList()
	local MajorUtil = require("Utils/MajorUtil")
	local MajorProfID = MajorUtil.GetMajorProfID()
	if next(FateDropList) and MajorProfID ~= FateDropList[1].Prof then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(520079))
	end
	self.DropList = FateDropList
	self.DropDownList:SetForceTrigger(true)
	self.DropDownList:UpdateItems(FateDropList, 1)
end

function AdventureFateRecommendPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.AdventureFateMapsWeight, self.OnGetAdventureFateMapsWeight) 
end

function AdventureFateRecommendPanelView:OnGetAdventureFateMapsWeight(Data)
	local FateRecommendList = _G.AdventureFateRecommendMgr:GetMapListDataByServerMapsWeight(Data.MapsWeight, self.CurSelectLevel)
	self:CreatItemList(FateRecommendList)
end

function AdventureFateRecommendPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)
end

function AdventureFateRecommendPanelView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	local Level = self.DropList[Index].Level
	self.CurSelectLevel = Level
	_G.AdventureFateRecommendMgr:SendGetFateRecommendMapsDataByLevel(Level)
end

function AdventureFateRecommendPanelView:OnHide()
	self.Super.OnHide(self)
	self.DropList = {}
end

function AdventureFateRecommendPanelView:OnRegisterBinder()
	local Binders = {
		{"ItemList", UIBinderUpdateBindableList.New(self, self.FateMapReconnebdList)},
	}

	self:RegisterBinders(self.VM, Binders)
end

return AdventureFateRecommendPanelView