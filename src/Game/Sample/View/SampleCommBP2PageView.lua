---
--- Author: anypkvcai
--- DateTime: 2023-04-03 15:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO

---@class SampleCommBP2PageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommHorTabs CommHorTabsView
---@field CommHorTabs2 CommHorTabsView
---@field CommHorTabs3 CommHorTabsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleCommBP2PageView = LuaClass(UIView, true)

function SampleCommBP2PageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommHorTabs = nil
	--self.CommHorTabs2 = nil
	--self.CommHorTabs3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SampleCommBP2PageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHorTabs)
	self:AddSubView(self.CommHorTabs2)
	self:AddSubView(self.CommHorTabs3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleCommBP2PageView:OnInit()

end

function SampleCommBP2PageView:OnDestroy()

end

function SampleCommBP2PageView:OnShow()
	--固定tab可以在蓝图里配置
	self.CommHorTabs:SetSelectedIndex(2)

	--显示文字  文字和图标是否可见由美术在蓝图里控制
	local ListData = { { Name = "Item1" }, { Name = "Item2" }, { Name = "Item3" }, { Name = "Item4" } }
	self.CommHorTabs2:UpdateItems(ListData, 1)

	--显示图标 文字和图标是否可见由美术在蓝图里控制
	local IconPathNormal = "PaperSprite'/Game/UI/Atlas/CraftingLog/Frames/UI_GatheringLog_Icon_Favor_png.UI_GatheringLog_Icon_Favor_png'"
	local IconPathSelect = "PaperSprite'/Game/UI/Atlas/CraftingLog/Frames/UI_GatheringLog_Icon_Favor_Select_png.UI_GatheringLog_Icon_Favor_Select_png'"
	local ListData2 = { { IconPathNormal = IconPathNormal, IconPathSelect = IconPathSelect }, { IconPathNormal = IconPathNormal, IconPathSelect = IconPathSelect } }
	self.CommHorTabs3:UpdateItems(ListData2, 2)
end

function SampleCommBP2PageView:OnHide()

end

function SampleCommBP2PageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommHorTabs, self.OnSelectionChangedCommHorTabs)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommHorTabs2, self.OnSelectionChangedCommHorTabs2)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommHorTabs3, self.OnSelectionChangedCommHorTabs3)
end

function SampleCommBP2PageView:OnRegisterGameEvent()

end

function SampleCommBP2PageView:OnRegisterBinder()

end

function SampleCommBP2PageView:OnSelectionChangedCommHorTabs(Index)
	FLOG_INFO("OnSelectionChangedCommHorTabs Index=%d ", Index)
end

function SampleCommBP2PageView:OnSelectionChangedCommHorTabs2(Index)
	FLOG_INFO("OnSelectionChangedCommHorTabs2 Index=%d ", Index)
end

function SampleCommBP2PageView:OnSelectionChangedCommHorTabs3(Index)
	FLOG_INFO("OnSelectionChangedCommHorTabs3 Index=%d ", Index)
end

return SampleCommBP2PageView