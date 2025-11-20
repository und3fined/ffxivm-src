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
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR
local AdventureMgr = _G.AdventureMgr
local ShopMgr = _G.ShopMgr
local AchievementMgr = _G.AchievementMgr
local ModuleOpenMgr = _G.ModuleOpenMgr

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
---@field ImgBGDefault UFImage
---@field ImgBgCrystallineRank UFImage
---@field MenuTab CommVerIconTabsView
---@field PanelBtnBar UFHorizontalBox
---@field PanelCrystallineLeaderBoard PVPCrystallineLeaderBoardPanelView
---@field PanelCrystallinePerformance PVPCrystallinePerformancePanelView
---@field PanelCrystallineRankRecord PVPCrystallineRankRecordPanelView
---@field PanelCrystallineRankReward PVPCrystallineRankRewardPanelView
---@field PanelOverview PVPInfoOverviewPanelView
---@field AnimIn UWidgetAnimation
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
	--self.ImgBGDefault = nil
	--self.ImgBgCrystallineRank = nil
	--self.MenuTab = nil
	--self.PanelBtnBar = nil
	--self.PanelCrystallineLeaderBoard = nil
	--self.PanelCrystallinePerformance = nil
	--self.PanelCrystallineRankRecord = nil
	--self.PanelCrystallineRankReward = nil
	--self.PanelOverview = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.MenuTab)
	self:AddSubView(self.PanelCrystallineLeaderBoard)
	self:AddSubView(self.PanelCrystallinePerformance)
	self:AddSubView(self.PanelCrystallineRankRecord)
	self:AddSubView(self.PanelCrystallineRankReward)
	self:AddSubView(self.PanelOverview)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPInfoPanelView:OnInit()

end

function PVPInfoPanelView:OnDestroy()

end

function PVPInfoPanelView:OnShow()
	self:SetFixText()
end

function PVPInfoPanelView:OnHide()

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

	local TabDataList = {}
	for _, TabData in ipairs(PVPInfoDefine.Tabs) do
		if ModuleOpenMgr:CheckOpenState(TabData.ModuleID) then
			if TabData.CheckTabValidFunc == nil then
				table.insert(TabDataList, TabData)
			elseif type(TabData.CheckTabValidFunc) == "function" then
				if TabData.CheckTabValidFunc() then
					table.insert(TabDataList, TabData)
				end
			end
		end
	end
	self.MenuTab:UpdateItems(TabDataList, TabType)
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
	PWorldEntUtil.GoToPWorldEntranceUI(Params)
end

function PVPInfoPanelView:OnClickBtnAdventure()
	AdventureMgr:JumpAndScrollToTargetWeekTask(37)
end

function PVPInfoPanelView:OnClickBtnAchievement()
	local Params = {
		TypeID = 2 -- 2对应玩家对战分类，详情看成就表的类型页，不是枚举后续有改动风险
	}
	AchievementMgr:OpenAchievementMainPanelView(Params)
end

function PVPInfoPanelView:OnMenuTabSelectionChanged(Index, ItemData, ItemView)
	local TabIndex = ItemData.ID
	local TabData = PVPInfoDefine.Tabs[TabIndex]

	UIUtil.SetIsVisible(self.PanelOverview, TabIndex == PVPInfoDefine.TabType.Overview)
	UIUtil.SetIsVisible(self.PanelCrystallinePerformance, TabIndex == PVPInfoDefine.TabType.CrystallineConflitPerformance)
	UIUtil.SetIsVisible(self.PanelCrystallineLeaderBoard, TabIndex == PVPInfoDefine.TabType.CrystallineLeaderBoard)
	UIUtil.SetIsVisible(self.PanelCrystallineRankReward, TabIndex == PVPInfoDefine.TabType.CrystallineRankReward)
	UIUtil.SetIsVisible(self.PanelCrystallineRankRecord, TabIndex == PVPInfoDefine.TabType.CrystallineRankRecord)
	UIUtil.SetIsVisible(self.ImgBGDefault, TabData.BGType == PVPInfoDefine.TabBGType.Default)
	UIUtil.SetIsVisible(self.ImgBgCrystallineRank, TabData.BGType == PVPInfoDefine.TabBGType.CrystallineRank)
	self.CommonTitle:SetTextSubtitle(TabData.Name)
	self.CommonTitle.CommInforBtn:SetHelpInfoID(TabData.HelpInfoID)
	UIUtil.SetIsVisible(self.PanelBtnBar, TabData.IsShowFunctionBtn)
end

function PVPInfoPanelView:SetFixText()
	self.CommonTitle.TextTitleName:SetText(LSTR(130025))
end

return PVPInfoPanelView