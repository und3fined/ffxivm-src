---
--- Author: Administrator
--- DateTime: 2024-11-18 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsNewbieStrategyPanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TipsUtil = require("Utils/TipsUtil")
local FirstChoicePanelVM
local OpsNewbieStrategyDefine
---@class OpsNewbieStrategyFirstChoicePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCourage1 UFButton
---@field TableViewList UTableView
---@field TextQuantity1 UFTextBlock
---@field TextTarget UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyFirstChoicePanelView = LuaClass(UIView, true)

function OpsNewbieStrategyFirstChoicePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCourage1 = nil
	--self.TableViewList = nil
	--self.TextQuantity1 = nil
	--self.TextTarget = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyFirstChoicePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyFirstChoicePanelView:OnInit()
	OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
	FirstChoicePanelVM = OpsNewbieStrategyPanelVM:GetFirstChoicePanelVM()
	self.TableViewActiveNodeAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = 
	{
		{ "CompletedNumText", UIBinderSetText.New(self, self.TextQuantity1)},
		{ "ActiveNodeList", UIBinderUpdateBindableList.New(self, self.TableViewActiveNodeAdapter) },
	}
end

function OpsNewbieStrategyFirstChoicePanelView:OnDestroy()

end

function OpsNewbieStrategyFirstChoicePanelView:OnShow()
	-- LSTR string:完成以下全部目标获得
	self.TextTarget:SetText(LSTR(920001))
	---红点名设置
	--_G.OpsNewbieStrategyMgr:DelFirstOpenRedDot(OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID)
end

function OpsNewbieStrategyFirstChoicePanelView:OnHide()

end

function OpsNewbieStrategyFirstChoicePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnCourage1, self.OnBtnCourageClicked)
end

function OpsNewbieStrategyFirstChoicePanelView:OnRegisterGameEvent()

end

function OpsNewbieStrategyFirstChoicePanelView:OnRegisterBinder()
	if FirstChoicePanelVM then
		self:RegisterBinders(FirstChoicePanelVM, self.Binders)
	end
end

function OpsNewbieStrategyFirstChoicePanelView:OnBtnCourageClicked()
	local Content = {
		-- LSTR string:勇气徽记
		{Title = LSTR(920005), Content = {LSTR(920015)}}
	}
	TipsUtil.ShowInfoTitleTips(Content, self.BtnCourage1, _G.UE.FVector2D(0,60), _G.UE.FVector2D(0,0))
end

return OpsNewbieStrategyFirstChoicePanelView