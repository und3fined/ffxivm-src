---
--- Author: Administrator
--- DateTime: 2024-06-03 14:07
--- Description:
---

local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")

local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR
local AdventureMgr = _G.AdventureMgr
local ShopMgr = _G.ShopMgr

---@class PVPInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAchievement UFButton
---@field BtnAdventure UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnPworldPVP UFButton
---@field BtnTrophyCrystal UFButton
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field MenuTab CommVerIconTabsView
---@field PanelCrystallinePerformance PVPCrystallinePerformancePanelView
---@field PanelOverview PVPInfoOverviewPanelView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPInfoPanelView = LuaClass(UIView, true)

function PVPInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAchievement = nil
	--self.BtnAdventure = nil
	--self.BtnClose = nil
	--self.BtnPworldPVP = nil
	--self.BtnTrophyCrystal = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonTitle = nil
	--self.MenuTab = nil
	--self.PanelCrystallinePerformance = nil
	--self.PanelOverview = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.MenuTab)
	self:AddSubView(self.PanelCrystallinePerformance)
	self:AddSubView(self.PanelOverview)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPInfoPanelView:OnInit()

end

function PVPInfoPanelView:OnDestroy()

end

function PVPInfoPanelView:OnShow()
	self:SetFixText()
	self.CommonTitle.CommInforBtn:SetHelpInfoID(11160)
end

function PVPInfoPanelView:OnHide()
	--self.MenuTab:CancelSelected()
end

function PVPInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTrophyCrystal, self.OnClickBtnTrophyCrystal)
	UIUtil.AddOnClickedEvent(self, self.BtnPworldPVP, self.OnClickBtnPworldPVP)
	UIUtil.AddOnClickedEvent(self, self.BtnAdventure, self.OnClickBtnAdventure)
	UIUtil.AddOnClickedEvent(self, self.BtnAchievement, self.OnClickBtnAchievement)
	UIUtil.AddOnSelectionChangedEvent(self, self.MenuTab, self.OnMenuTabSelectionChanged)
end

function PVPInfoPanelView:OnRegisterGameEvent()

end

function PVPInfoPanelView:OnRegisterBinder()
	self:InitMenuTab()
end

function PVPInfoPanelView:InitMenuTab()
	local TabType = PVPInfoDefine.DefaultTab
	if self.Params and self.Params.TabType then
		TabType = self.Params.TabType
	end
	self.MenuTab:UpdateItems(PVPInfoDefine.Tabs, TabType)
end

function PVPInfoPanelView:OnClickBtnTrophyCrystal()
	ShopMgr:OpenShop(PVPInfoDefine.TrophyCrystalShopID, nil, true)
end

function PVPInfoPanelView:OnClickBtnPworldPVP()
	local Params = {
		JumpData = {
			[1] = 3 -- 3代表对战页签，详情看View文件，不是枚举后续有改动风险
		}
	}
	UIViewMgr:ShowView(UIViewID.PWorldEntrancePanel, Params)
end

function PVPInfoPanelView:OnClickBtnAdventure()
	AdventureMgr:JumpAndScrollToTargetWeekTask(37)
end

function PVPInfoPanelView:OnClickBtnAchievement()
	local Params = {
		TypeID = 2 -- 2对应玩家对战分类，详情看成就表的类型页，不是枚举后续有改动风险
	}
	_G.AchievementMgr:OpenAchievementMainPanelView(Params)
end

function PVPInfoPanelView:OnMenuTabSelectionChanged(Index, ItemData, ItemView)
	local TabIndex = ItemData.ID

	UIUtil.SetIsVisible(self.PanelOverview, TabIndex == PVPInfoDefine.TabType.Overview)
	UIUtil.SetIsVisible(self.PanelCrystallinePerformance, TabIndex == PVPInfoDefine.TabType.CrystallineConflitPerformance)
	self.CommonTitle:SetTextSubtitle(PVPInfoDefine.Tabs[TabIndex].Name)
end

function PVPInfoPanelView:SetFixText()
	self.CommonTitle.TextTitleName:SetText(LSTR(130025))
end

return PVPInfoPanelView