---
--- Author: Administrator
--- DateTime: 2023-11-22 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local UUIUtil = _G.UE.UUIUtil
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local ArmyStatePanelVM = nil

---@class ArmyStatePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyStatePanelView = LuaClass(UIView, true)

function ArmyStatePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--self.AnimIn = nil
	--self.AnimTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyStatePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyStatePanelView:OnInit()
	ArmyStatePanelVM = ArmyMainVM:GetStatePanelVM()
	 self.TableViewAdapter  = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	 self.TableViewAdapter:SetOnClickedCallback(self.OnClickedStateItem)
    self.Binders = {
        {"GroupPermissionList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)}, 
    }
end

function ArmyStatePanelView:OnDestroy()

end

function ArmyStatePanelView:SetPanelTipsEnable(InIsEnable)
	UIUtil.SetIsVisible(self.PanelTips, InIsEnable)
end

function ArmyStatePanelView:OnClickedStateItem(Index, ItemData, ItemView)
	if nil == ItemView then
		return
	end
	----改版不需要tips
	-- self.TextTitle:SetText(ItemData.Permission)
	-- self.TextContent:SetText(ItemData.Describe)
	-- UIUtil.SetIsVisible(self.PanelTips, true)
	-- local ScreenSize = UIUtil.GetScreenSize()
	-- local ViewportSize = UIUtil.GetViewportSize()
	-- local TargetWidgetSize = UUIUtil.GetLocalSize(ItemView.BtnClick)
	-- local TipsWidgetSize = UUIUtil.GetLocalSize(self.PanelTips)
	-- local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(ItemView.BtnClick)
	-- local OffsetY = 0
	-- if TragetAbsolute.Y  > ViewportSize.Y/2 then
	-- 	OffsetY = TargetWidgetSize.Y/2 - TipsWidgetSize.Y
	-- else
	-- 	OffsetY = TargetWidgetSize.Y/2
	-- end
	-- UIUtil.AdjustTipsPosition_Top(self.PanelTips, ItemView.BtnClick, _G.UE.FVector2D(0, OffsetY))
end

function ArmyStatePanelView:OnShow()
	self:UpdateStateInfo()
end

function ArmyStatePanelView:UpdateStateInfo()
	ArmyStatePanelVM:UpdateGroupPermissionList()
end

function ArmyStatePanelView:OnHide()

end

function ArmyStatePanelView:OnRegisterUIEvent()

end

function ArmyStatePanelView:OnRegisterGameEvent()

end

function ArmyStatePanelView:OnRegisterBinder()
    self:RegisterBinders(  ArmyStatePanelVM, self.Binders)
end

function ArmyStatePanelView:IsForceGC()
	return true
end

return ArmyStatePanelView