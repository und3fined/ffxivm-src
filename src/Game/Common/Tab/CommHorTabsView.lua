---
--- Author: anypkvcai
--- DateTime: 2023-04-03 15:21
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")

---@class CommHorTabsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HorizontalBoxTabs UHorizontalBox
---@field ImgBtnLight UFImage
---@field ImgBtnNormal UFImage
---@field Tab1 CommHorTabItemView
---@field Tab2 CommHorTabItemView
---@field Tab3 CommHorTabItemView
---@field Tab4 CommHorTabItemView
---@field ParamShowText bool
---@field ParamShowIcon bool
---@field TabStyle CommHorTabStyleEnum
---@field ParamTabItems CommHorTabParams
---@field TabItems CommHorTabItem_UIBP_C
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHorTabsView = LuaClass(UIView, true)
local TabStyleEnum = {
	DarkBackgroundStyle = 0,
	ColorfulBackgroundStyle = 1,
	PaperBackgroundStyle = 2,
}
function CommHorTabsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HorizontalBoxTabs = nil
	--self.ImgBtnLight = nil
	--self.ImgBtnNormal = nil
	--self.Tab1 = nil
	--self.Tab2 = nil
	--self.Tab3 = nil
	--self.Tab4 = nil
	--self.ParamShowText = nil
	--self.ParamShowIcon = nil
	--self.TabStyle = nil
	--self.ParamTabItems = nil
	--self.TabItems = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHorTabsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Tab1)
	self:AddSubView(self.Tab2)
	self:AddSubView(self.Tab3)
	self:AddSubView(self.Tab4)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHorTabsView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.AdapterTabs = UIAdapterPanelWidget.CreateAdapter(self, self.HorizontalBoxTabs)
	local Param = { ShowIcon = self.ParamShowIcon, ShowText = self.ParamShowText }
	self.AdapterTabs:SetParams(Param)
	self.ModuleIDList = {}
	self.ImageNormal = nil
	self.ImageSelect = nil
	self.ColorNormal = nil
	self.ColorSelect = nil
	self:InitListData()
end

function CommHorTabsView:InitListData()
	self:SetTabStyle(self.TabStyle)
	local ListData = {}
	for i = 1, self.ParamTabItems:Length() do
		local Item = self.ParamTabItems:GetRef(i)
		local TextUkey = Item.TextUkey
		local Data = {
			Index = i,
			Name = string.isnilorempty(TextUkey) and Item.Text or _G.LSTR(TextUkey),
			IconNormal = Item.Normal and Item.Normal.Icon or nil,
			IconSelect = Item.Select and Item.Select.Icon or nil,
			ImageNormal = self.ImageNormal,
			ImageSelect = self.ImageSelect,
			ColorNormal = self.ColorNormal,
			ColorSelect = self.ColorSelect,
			ModuleID = self.ModuleIDList[i] or 0,
			RedDotType = self.RedDotType,
		}

		table.insert(ListData, Data)
	end

	self.DefaultListData = ListData
end

function CommHorTabsView:OnDestroy()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
	self.ListData = nil
	self.DefaultListData = nil
end

function CommHorTabsView:OnShow()
	self:UpdateItems(self.ListData , self.SelectedIndex)
	self:UpdateSelect(self.SelectedIndex, true)
end

function CommHorTabsView:OnHide()
	self.ModuleIDList = {}
end

function CommHorTabsView:OnRegisterUIEvent()

end

function CommHorTabsView:OnRegisterGameEvent()

end

function CommHorTabsView:OnRegisterBinder()

end

function CommHorTabsView:OnSelectChanged(Index)
	self.SelectedIndex = Index
	self.OnSelectionChanged:OnTriggered(Index)
end

---UpdateItems
---@param ListData table @ 显示文字时：{ { Name = "Item1" }, { Name = "Item2" }} 显示图标时： { { IconPathNormal = "IconPathNormal1", IconPathSelect = "IconPathSelect1" }, { IconPathNormal = "IconPathNormal2", IconPathSelect = "IconPathSelect2" } }
---@private SelectedIndex number @当前选中索引 从 1 开始
function CommHorTabsView:UpdateItems(ListData, SelectedIndex)
	---UpdateItems调用来源有两个，外部调用接口传入文字、图标属性，内部初始化时根据蓝图配置的参数传入Data
	---此处重写逻辑将程序传入的参数优先级调高
	self.ListData = ListData
	local NewListData = self:CreateTabItemsParam(ListData or self.DefaultListData)
	self.AdapterTabs:UpdateAll(NewListData)
	self:SetSelectedIndex(SelectedIndex or 1)
end

function CommHorTabsView:CreateTabItemsParam(Data)
	local ListData = {}
	if nil == Data or #Data < 1 then
		return ListData
	end
	for i = 1, #Data do
		local Item = Data[i]
		local Param = {
			Name = Item.Name,
			IconNormal = Item.IconNormal,
			IconSelect = Item.IconSelect,
			ImageNormal = self.ImageNormal,
			ImageSelect = self.ImageSelect,
			ColorNormal = self.ColorNormal,
			ColorSelect = self.ColorSelect,
			ModuleID = self.ModuleIDList[i] or 0,
			RedDotType = self.RedDotType,
		}
		table.insert(ListData, Param)
	end
	return ListData
end
function CommHorTabsView:UpdateSelect(SelectedIndex, IsSelected)
	local Child = self.AdapterTabs:GetChildren(SelectedIndex)
	if nil ~= Child then
		Child:OnSelectChanged(IsSelected)
	end
end

function CommHorTabsView:SetSelectedIndex(SelectedIndex)
	local AdapterTabs = self.AdapterTabs
	if SelectedIndex and SelectedIndex > AdapterTabs:GetNum() then
		return false
	end

	local Index = self.SelectedIndex
	if Index == SelectedIndex then
		return false
	end

	if nil ~= Index then
		self:UpdateSelect(Index, false)
	end

	self:UpdateSelect(SelectedIndex, true)

	self:OnSelectChanged(SelectedIndex)

	return true
end

function CommHorTabsView:GetSelectedIndex()
	return self.SelectedIndex
end

function CommHorTabsView:CancelSelected()
	self:UpdateSelect(self.SelectedIndex, false)
	self.SelectedIndex = nil
end

--系统解锁解锁相关 初始化前要先设置一下ModuleID
function CommHorTabsView:SetModuleID( List )
	for i = 1, #List do
		if List[i] ~= nil then
			table.insert(self.ModuleIDList, List[i])
		end
	end
end

function CommHorTabsView:SetRedDotType(Type)
	self.RedDotType = Type
end

function CommHorTabsView:GetTabNum()
	return self.AdapterTabs:GetNum()
end

---外部设置TabStyle,在UpdateItem之前调用
---@param TabStyle 0:DarkBackgroundStyle 1:ColorfulBackgroundStyle 2:PaperBackgroundStyle
function CommHorTabsView:SetTabStyle(TabStyle)
	self.TabStyle = TabStyle
	if self.TabStyle == TabStyleEnum.DarkBackgroundStyle then
		self.ImageNormal = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_BG_Only_Bright.UI_Btn_3thTab_BG_Only_Bright'"
		self.ImageSelect = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_Only_Select.UI_Btn_3thTab_Only_Select'"
		self.ColorNormal = "#6c6964"
		self.ColorSelect = "#ffeebb"
		UIUtil.SetIsVisible(self.ImgBtnNormal, true)
		UIUtil.SetIsVisible(self.ImgBtnLight, false)
	elseif self.TabStyle == TabStyleEnum.ColorfulBackgroundStyle then
		self.ImageNormal = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_BG_Only_Bright.UI_Btn_3thTab_BG_Only_Bright'"
		self.ImageSelect = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_Only_Select.UI_Btn_3thTab_Only_Select'"
		self.ColorNormal = "#d5d5d5"
		self.ColorSelect = "#ffeebb"
		UIUtil.SetIsVisible(self.ImgBtnNormal, true)
		UIUtil.SetIsVisible(self.ImgBtnLight, false)
	elseif self.TabStyle == TabStyleEnum.PaperBackgroundStyle then
		self.ImageNormal = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_BG_Only_Light.UI_Btn_3thTab_BG_Only_Light'"
		self.ImageSelect = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_Only_Select_Light.UI_Btn_3thTab_Only_Select_Light'"
		self.ColorNormal = "#313131"
		self.ColorSelect = "#ffeebb"
		UIUtil.SetIsVisible(self.ImgBtnNormal, false)
		UIUtil.SetIsVisible(self.ImgBtnLight, true)
	end
end
return CommHorTabsView