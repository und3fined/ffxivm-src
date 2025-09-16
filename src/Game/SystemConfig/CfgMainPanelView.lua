---
--- Author: chaooren
--- DateTime: 2021-10-22 19:38
--- Description: 临时交互和代码
---
---

local CfgEntrance = require("Game/SystemConfig/CfgEntrance")


local WidgetType = CfgEntrance.WidgetType


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")

---@class CfgMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field Cfg_Button_UIBP CfgButtonView
---@field Cfg_Slider_UIBP_1 CfgSliderView
---@field Cfg_ToggleGroup_UIBP CfgToggleGroupView
---@field FCanvasPanel_1 UFCanvasPanel
---@field FCanvasPanel_2 UFCanvasPanel
---@field FCanvasPanel_3 UFCanvasPanel
---@field FHorizontalBox_71 UFHorizontalBox
---@field FTextBlock_3 UFTextBlock
---@field FVerticalBox_1 UFVerticalBox
---@field FVerticalBox_2 UFVerticalBox
---@field FVerticalBox_3 UFVerticalBox
---@field FVerticalBox_4 UFVerticalBox
---@field FVerticalBox_5 UFVerticalBox
---@field ToggleGroupDynamic_211 UToggleGroupDynamic
---@field WidgetSwitcher_144 UWidgetSwitcher
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CfgMainPanelView = LuaClass(UIView, true)

function CfgMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.Cfg_Button_UIBP = nil
	--self.Cfg_Slider_UIBP_1 = nil
	--self.Cfg_ToggleGroup_UIBP = nil
	--self.FCanvasPanel_1 = nil
	--self.FCanvasPanel_2 = nil
	--self.FCanvasPanel_3 = nil
	--self.FHorizontalBox_71 = nil
	--self.FTextBlock_3 = nil
	--self.FVerticalBox_1 = nil
	--self.FVerticalBox_2 = nil
	--self.FVerticalBox_3 = nil
	--self.FVerticalBox_4 = nil
	--self.FVerticalBox_5 = nil
	--self.ToggleGroupDynamic_211 = nil
	--self.WidgetSwitcher_144 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CfgMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Cfg_Button_UIBP)
	self:AddSubView(self.Cfg_Slider_UIBP_1)
	self:AddSubView(self.Cfg_ToggleGroup_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local function CreateSwitcherPanel(Self, WidgetSwitcher)
	local ScrollBox = _G.NewObject(_G.UE.UScrollBox.StaticClass(), Self)
	local VerticalBox = _G.NewObject(_G.UE.UFVerticalBox.StaticClass(), Self)
	ScrollBox:AddChild(VerticalBox)
	WidgetSwitcher:AddChild(ScrollBox)
	local Margin = _G.UE.FMargin()
	Margin.Left = 0
	Margin.Top = 20
	Margin.Right = 0
	Margin.Bottom = 0
	ScrollBox:SetScrollbarPadding(Margin)
	return VerticalBox
end

local function SetTitle(TextBlock, Title)
	UIUtil.CanvasSlotSetPosition(TextBlock, _G.UE.FVector2D(0, 10))
	UIUtil.CanvasSlotSetSize(TextBlock, _G.UE.FVector2D(100, 70))
	TextBlock:SetText(Title)
	UIUtil.TextBlockSetColorAndOpacity(TextBlock, 0, 0, 0, 1)
	local TitleCount = #Title
	local Diff = TitleCount - 15
	Diff = Diff > 0 and Diff or 0
	local Size = 24 - 0.67 * Diff
	Size = Size < 14 and 14 or Size
	TextBlock.Font.Size = math.ceil(Size)
end

local function CreateToggleGroup(Self, Cfg)
	local CanvasPanel = _G.NewObject(_G.UE.UFCanvasPanel.StaticClass(), Self)
	local TextBlock = _G.NewObject(_G.UE.UFTextBlock.StaticClass(), Self)
	local ToggleGroupBP = UIViewMgr:CloneView(Self.Cfg_ToggleGroup_UIBP, Self, true, true)
	local ToggleGroup = ToggleGroupBP.ToggleGroupDynamic_1
	for i = 0, #Cfg.DescList - 1 do
		local Entry = ToggleGroup:BP_CreateEntry()
		Entry:Init(Cfg, Cfg.DescList[i + 1], i, nil, Cfg.Callback, Cfg.SaveKey)
		if i == Cfg.DefaultIndex then
			Entry:SetToggleButtonChecked(true, false)
		end
	end
	ToggleGroup:SetCheckedIndex(Cfg.DefaultIndex, false)
	ToggleGroup.NotifyOnInitialize = false
	CanvasPanel:AddChildToCanvas(TextBlock)
	CanvasPanel:AddChildToCanvas(ToggleGroupBP)

	SetTitle(TextBlock, Cfg.Title)

	UIUtil.CanvasSlotSetPosition(ToggleGroupBP, _G.UE.FVector2D(200, 0))

	return CanvasPanel
end

local function CreateSlider(Self, Cfg)
	local CanvasPanel = _G.NewObject(_G.UE.UFCanvasPanel.StaticClass(), Self)
	local TextBlock = _G.NewObject(_G.UE.UFTextBlock.StaticClass(), Self)
	local Slider = UIViewMgr:CloneView(Self.Cfg_Slider_UIBP_1, Self, true, true, Cfg)

	CanvasPanel:AddChildToCanvas(TextBlock)
	CanvasPanel:AddChildToCanvas(Slider)

	SetTitle(TextBlock, Cfg.Title)

	Slider:SetRenderScale(_G.UE.FVector2D(1, 1))
	Slider:SetRenderTransformPivot(_G.UE.FVector2D(0, 0))
	UIUtil.CanvasSlotSetPosition(Slider, _G.UE.FVector2D(200, 0))

	return CanvasPanel
end

local function CreateButton(Self, Cfg)
	local CanvasPanel = _G.NewObject(_G.UE.UFCanvasPanel.StaticClass(), Self)
	local TextBlock = _G.NewObject(_G.UE.UFTextBlock.StaticClass(), Self)
	local HorizontalBox = _G.NewObject(_G.UE.UFHorizontalBox.StaticClass(), Self)
	for _, value in ipairs(Cfg.Buttons) do
		local Button = UIViewMgr:CloneView(Self.Cfg_Button_UIBP, Self, true, true, value)
		HorizontalBox:AddChildToHorizontalBox(Button)
		Button.Slot.Padding.Right = 20
	end
	CanvasPanel:AddChildToCanvas(TextBlock)
	CanvasPanel:AddChildToCanvas(HorizontalBox)

	SetTitle(TextBlock, Cfg.Title)

	UIUtil.CanvasSlotSetPosition(HorizontalBox, _G.UE.FVector2D(200, 0))

	return CanvasPanel
end

function CfgMainPanelView:OnInit()
	local SwitcherMap = {}

	local Count = #CfgEntrance.ClassificationList
	self.WidgetSwitcher_144:ClearChildren()
	for i = 1, Count do
		local VerticalBox = CreateSwitcherPanel(self, self.WidgetSwitcher_144)
		SwitcherMap[i] = VerticalBox
	end
	local SwitcherCount = self.WidgetSwitcher_144:GetNumWidgets()
	if Count ~= SwitcherCount then
		return
	end

	for _, value in ipairs(CfgEntrance.CfgList) do
		if SwitcherMap[value.Section]~= nil then
			local VerticalBox = SwitcherMap[value.Section]
			local CanvasPanel = nil
			if value.Type == WidgetType.ToggleGroup then
				CanvasPanel = CreateToggleGroup(self, value)
			elseif value.Type == WidgetType.Slider then
				CanvasPanel = CreateSlider(self, value)
			elseif value.Type == WidgetType.Button then
				CanvasPanel = CreateButton(self, value)
			end

			if CanvasPanel ~= nil then
				VerticalBox:AddChildToVerticalBox(CanvasPanel)
				CanvasPanel.Slot.Padding.Left = 60
			end
		end
	end
	local Index = 0
	for _, value in pairs(CfgEntrance.ClassificationList) do
		local Entry = self.ToggleGroupDynamic_211:BP_CreateEntry()
		Entry:Init(nil, value, Index, self, self.OnNavStateChanged)
		Index = Index + 1
	end
end

function CfgMainPanelView:OnDestroy()

end

function CfgMainPanelView:OnShow()

end

function CfgMainPanelView:OnHide()

end

function CfgMainPanelView.OnToggleGroupStateChanged(_, ToggleGroup, View, ToggleButton, Index, State)
	if ToggleGroup ~= nil then
		local Count = ToggleGroup:GetNumEntries()
		for i = 0, Count - 1 do
			local TB = ToggleGroup:GetEntry(i)
			if TB then
				TB:OnToggleGroupStateChanged(Index == TB:GetIndex())
			end
		end
	end
end

function CfgMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnCloseHandle)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamic_211, CfgMainPanelView.OnToggleGroupStateChanged, self.ToggleGroupDynamic_211)
end

function CfgMainPanelView:OnRegisterGameEvent()

end

function CfgMainPanelView:OnRegisterBinder()

end

function CfgMainPanelView:OnCloseHandle()
	UIViewMgr:HideView(UIViewID.CfgMainPanel)
end

function CfgMainPanelView:OnNavStateChanged(Index, Name)
	self.WidgetSwitcher_144:SetActiveWidgetIndex(Index)
end

return CfgMainPanelView