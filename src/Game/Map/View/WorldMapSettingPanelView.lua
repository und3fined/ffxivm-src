---
--- Author: peterxie
--- DateTime: 2025-03-17
--- Description: 地图设置界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MapSetting = require("Game/Map/MapSetting")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")

local SettingType = MapSetting.SettingType
local LSTR = _G.LSTR


---@class WorldMapSettingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox01 CommCheckBoxView
---@field CheckBox02 CommCheckBoxView
---@field PanelQuest UFCanvasPanel
---@field PanelSetUP UFCanvasPanel
---@field TableViewSetUPList UTableView
---@field TextMapSetUp UFTextBlock
---@field TextQuestSetUp UFTextBlock
---@field ToggleGroup UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapSettingPanelView = LuaClass(UIView, true)

function WorldMapSettingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox01 = nil
	--self.CheckBox02 = nil
	--self.PanelQuest = nil
	--self.PanelSetUP = nil
	--self.TableViewSetUPList = nil
	--self.TextMapSetUp = nil
	--self.TextQuestSetUp = nil
	--self.ToggleGroup = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapSettingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox01)
	self:AddSubView(self.CheckBox02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapSettingPanelView:OnInit()
	self.AdapterTableViewSetUPList = UIAdapterTableView.CreateAdapter(self, self.TableViewSetUPList, nil, false)
end

function WorldMapSettingPanelView:OnDestroy()

end

function WorldMapSettingPanelView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ShowTabType = Params.TabData.Type or SideBarDefine.MapSettingTabType.Basic
	if ShowTabType == SideBarDefine.MapSettingTabType.Basic then
		self:ShowBasic()
	elseif ShowTabType == SideBarDefine.MapSettingTabType.Gameplay then
		self:ShowGameplay()
	end
end

function WorldMapSettingPanelView:OnHide()

end

function WorldMapSettingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroup, self.OnGroupStateChangedQuest)
end

-- 基础显示设置
function WorldMapSettingPanelView:ShowBasic()
	self.TextMapSetUp:SetText(LSTR(700037)) -- "地图标记显示"
	self.TextQuestSetUp:SetText(LSTR(700038)) -- "任务标记显示"
	self.CheckBox01:SetText(LSTR(700039)) -- "全部任务"
	self.CheckBox02:SetText(LSTR(700040)) -- "主线任务"

	UIUtil.SetIsVisible(self.PanelQuest, true)
	UIUtil.SetIsVisible(self.TextQuestSetUp, true)

	local Index = MapSetting.GetSettingValue(SettingType.QuestType)
	self.ToggleGroup:SetCheckedIndex(Index, true)
	if Index == 0 then
		self.CheckBox01:SetChecked(true)
		self.CheckBox02:SetChecked(false)
	else
		self.CheckBox01:SetChecked(false)
		self.CheckBox02:SetChecked(true)
	end

	self.SetUPList =
	{
		{ SettingType = SettingType.ShowIcon },
		{ SettingType = SettingType.ShowText },
		{ SettingType = SettingType.ShowCrystalIcon },
	}

	self.AdapterTableViewSetUPList:UpdateAll(self.SetUPList)
end

-- 探索标记显示设置
function WorldMapSettingPanelView:ShowGameplay()
	self.TextMapSetUp:SetText(LSTR(700051)) -- "已探索后的标记显示"

	UIUtil.SetIsVisible(self.PanelQuest, false)
	UIUtil.SetIsVisible(self.TextQuestSetUp, false)

	-- 根据条件显示地图设置项
	self.SetUPList = {}

	if _G.AetherCurrentsMgr:IsAetherCurrentSysOpen() then
		table.insert(self.SetUPList, { SettingType = SettingType.ShowAetherCurrent })
	end

	if _G.WildBoxMoundMgr:IsOpenAnyBox() then
		table.insert(self.SetUPList, { SettingType = SettingType.ShowWildBox })
	end

	if _G.DiscoverNoteMgr:IsActiveAnyPerfectPoint() then
		table.insert(self.SetUPList, { SettingType = SettingType.ShowDiscoverNote })
	end

	self.AdapterTableViewSetUPList:UpdateAll(self.SetUPList)
end

function WorldMapSettingPanelView:OnStateChangedCheckBox(Params, ToggleButton, ButtonState)
	local Type = Params
	local IsChecked = UIUtil.IsToggleButtonChecked(ButtonState)
	MapSetting.SetSettingValue(Type, IsChecked and 1 or 0)
end

function WorldMapSettingPanelView:OnGroupStateChangedWeather(ToggleGroup, ToggleButton, Index, State)
	MapSetting.SetSettingValue(SettingType.WeatherType, Index)
end

function WorldMapSettingPanelView:OnGroupStateChangedQuest(ToggleGroup, ToggleButton, Index, State)
	MapSetting.SetSettingValue(SettingType.QuestType, Index)
end

return WorldMapSettingPanelView