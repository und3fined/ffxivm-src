
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FLinearColor = _G.UE.FLinearColor

local function ProcessElements(List, Index, Action)
	for i, Element in ipairs(List) do
		if i ~= Index then
			Action(Element)
		end
	end
end

---@class CommTabsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field BtnItem2 UFButton
---@field BtnItem3 UFButton
---@field FHorizontalSlot UFHorizontalBox
---@field ImgBrightBG UFImage
---@field ImgBtnSelect UFImage
---@field ImgBtnSelect2 UFImage
---@field ImgBtnSelect3 UFImage
---@field ImgBtnSelectBright UFImage
---@field ImgBtnSelectBright2 UFImage
---@field ImgBtnSelectBright3 UFImage
---@field ImgIconNormal UFImage
---@field ImgIconNormal2 UFImage
---@field ImgIconNormal3 UFImage
---@field ImgIconSelect UFImage
---@field ImgIconSelect2 UFImage
---@field ImgIconSelect3 UFImage
---@field ImgLightBG UFImage
---@field PanelNormal UFCanvasPanel
---@field PanelNormal2 UFCanvasPanel
---@field PanelNormal3 UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field PanelSelect2 UFCanvasPanel
---@field PanelSelect3 UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field PanelSlot2 UFCanvasPanel
---@field PanelSlot3 UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field PanelTab2 UFCanvasPanel
---@field PanelTab3 UFCanvasPanel
---@field RedDotSlot CommonRedDotView
---@field RedDotSlot2 CommonRedDotView
---@field RedDotSlot3 CommonRedDotView
---@field TextTabName UFTextBlock
---@field TextTabName2 UFTextBlock
---@field TextTabName3 UFTextBlock
---@field TypeToggleBtn UFCanvasPanel
---@field ParamShowIcon bool
---@field ParamShowText bool
---@field ParamShowRedDot bool
---@field ParamItems CommTabItem
---@field ItemTextArray FTextBlock
---@field ItemNormalArray FImage
---@field ItemSelectArray FImage
---@field bHasInit bool
---@field IsSetTitle bool
---@field TabStyle CommHorTabStyleEnum
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommTabsView = LuaClass(UIView, true)
local TabStyleEnum = {
	DarkBackgroundStyle = 0,
	ColorfulBackgroundStyle = 1,
	PaperBackgroundStyle = 2,
}
function CommTabsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.BtnItem2 = nil
	--self.BtnItem3 = nil
	--self.FHorizontalSlot = nil
	--self.ImgBrightBG = nil
	--self.ImgBtnSelect = nil
	--self.ImgBtnSelect2 = nil
	--self.ImgBtnSelect3 = nil
	--self.ImgBtnSelectBright = nil
	--self.ImgBtnSelectBright2 = nil
	--self.ImgBtnSelectBright3 = nil
	--self.ImgIconNormal = nil
	--self.ImgIconNormal2 = nil
	--self.ImgIconNormal3 = nil
	--self.ImgIconSelect = nil
	--self.ImgIconSelect2 = nil
	--self.ImgIconSelect3 = nil
	--self.ImgLightBG = nil
	--self.PanelNormal = nil
	--self.PanelNormal2 = nil
	--self.PanelNormal3 = nil
	--self.PanelSelect = nil
	--self.PanelSelect2 = nil
	--self.PanelSelect3 = nil
	--self.PanelSlot = nil
	--self.PanelSlot2 = nil
	--self.PanelSlot3 = nil
	--self.PanelTab = nil
	--self.PanelTab2 = nil
	--self.PanelTab3 = nil
	--self.RedDotSlot = nil
	--self.RedDotSlot2 = nil
	--self.RedDotSlot3 = nil
	--self.TextTabName = nil
	--self.TextTabName2 = nil
	--self.TextTabName3 = nil
	--self.TypeToggleBtn = nil
	--self.ParamShowIcon = nil
	--self.ParamShowText = nil
	--self.ParamShowRedDot = nil
	--self.ParamItems = nil
	--self.ItemTextArray = nil
	--self.ItemNormalArray = nil
	--self.ItemSelectArray = nil
	--self.bHasInit = nil
	--self.IsSetTitle = nil
	--self.TabStyle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommTabsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDotSlot)
	self:AddSubView(self.RedDotSlot2)
	self:AddSubView(self.RedDotSlot3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommTabsView:OnInit()
	self.SelectIndex = nil
	self.ImageNormal = nil
	self.ImageSelect = nil
	self.ColorNormal = nil
	self.ColorSelect = nil
	self:SetTabStyle(self.TabStyle)
	self.ImgBtnSelectList = {[1] = self.ImgBtnSelect, [2] = self.ImgBtnSelect2, [3] = self.ImgBtnSelect3}
	self.ImgIconNormalList = {[1] = self.ImgIconNormal, [2] = self.ImgIconNormal2, [3] = self.ImgIconNormal3}
	self.ImgIconSelectList = {[1] = self.ImgIconSelect, [2] = self.ImgIconSelect2, [3] = self.ImgIconSelect3}

	self.TextlList = {[1] = self.TextTabName, [2] = self.TextTabName2, [3] = self.TextTabName3}
	self.PanelTabList = {[1] = self.PanelTab, [2] = self.PanelTab2, [3] = self.PanelTab3}
	self:InitViewWithIcon()
end

function CommTabsView:InitViewWithIcon()
	---根据蓝图中的参数默认显示图标
	local ListData = {}
	for i=1, self.ParamItems:Length() do
		local ParamItem = self.ParamItems[i]
		if ParamItem then
			local IconPath = {}
			IconPath.IconPathNormal = ParamItem.Normal
			IconPath.IconPathSelect = ParamItem.Select
			table.insert(ListData, IconPath)
		end
	end
	if #ListData >= 3 then
		UIUtil.SetIsVisible(self.PanelSlot3, true)
	else
		UIUtil.SetIsVisible(self.PanelSlot3, false)
	end
	for i = 1, #ListData do
		if i > 3 then
			return
		end
		local ItemData = ListData[i]
		if ItemData == nil then
			return
		end
		UIUtil.SetIsVisible(self.PanelTabList[i], true)
		UIUtil.SetIsVisible(self.TextlList[i], false)
		self.ImgIconNormalList[i]:SetBrush(ItemData.IconPathNormal)
		self.ImgIconSelectList[i]:SetBrush(ItemData.IconPathSelect)
		UIUtil.SetIsVisible(self.ImgIconNormalList[i], true)
		UIUtil.SetIsVisible(self.ImgIconSelectList[i], true)
	end
	for i = #ListData + 1, 3 do
		UIUtil.SetIsVisible(self.PanelTabList[i], false)
	end
end
function CommTabsView:OnShow()
	---若SelectIndex存在则说明在显示时已经设置过选中项，不需要设置默认值
	if nil == self.SelectIndex then
		self:SetSelectedIndex(self.Params and self.Params.CommTabIndex or 1)
		return
	end
	UIUtil.SetIsVisible(self.PanelSlot2, true)
end

function CommTabsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.SetSelectedIndex, 1)
	UIUtil.AddOnClickedEvent(self, self.BtnItem2, self.SetSelectedIndex, 2)
	UIUtil.AddOnClickedEvent(self, self.BtnItem3, self.SetSelectedIndex, 3)
end

function CommTabsView:SetSelectedIndex(Index)
	--该处逻辑为所有未选中Tab的选中节点都设置未false.蓝图侧已经修改，只保留了一个节点用于在选中和未选中状态间切换
	ProcessElements(self.ImgBtnSelectList, Index, function(Element)	
		UIUtil.ImageSetBrushFromAssetPath(Element, self.ImageNormal) 
		UIUtil.SetIsVisible(Element, false)
		end)
	ProcessElements(self.ImgIconSelectList, Index, function(Element) UIUtil.SetIsVisible(Element, false) end)
	ProcessElements(self.TextlList, Index, function(Element) Element:SetColorAndOpacity(FLinearColor.FromHex(self.ColorNormal)) end)
	local LinearColor = FLinearColor.FromHex(self.ColorSelect)
	self.TextlList[Index]:SetColorAndOpacity(LinearColor)
	UIUtil.SetIsVisible(self.ImgIconSelectList[Index], self.ParamShowIcon)
	UIUtil.SetIsVisible(self.ImgIconNormalList[Index], self.ParamShowIcon)
	UIUtil.SetIsVisible(self.TextlList[Index], self.ParamShowText)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBtnSelectList[Index], self.ImageSelect)
	UIUtil.SetIsVisible(self.ImgBtnSelectList[Index], true)
	local bSelectChanged = Index ~= self.SelectIndex
	self.SelectIndex = Index
	if self.CallBack ~= nil and  bSelectChanged then
		self.CallBack(self.View, Index)
	end
end

function CommTabsView:UpdateItemsByValue(ListData)
	if nil == ListData then
		return
	end
	if #ListData >= 3 then
		UIUtil.SetIsVisible(self.PanelSlot3, true)
	else
		UIUtil.SetIsVisible(self.PanelSlot3, false)
	end
	for i = 1, #ListData do
		if i > 3 then
			return
		end
		local ItemData = ListData[i]
		if ItemData == nil then
			return
		end
		UIUtil.SetIsVisible(self.PanelTabList[i], true)
		local Name = ItemData.Name
		if Name ~= nil then
			self.TextlList[i]:SetText(Name)
			UIUtil.SetIsVisible(self.TextlList[i], true)
		else 
			UIUtil.SetIsVisible(self.TextlList[i], false)
		end

		local IconPathNormal = ItemData.IconPathNormal
		if IconPathNormal ~= nil then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgIconNormalList[i], IconPathNormal)
			UIUtil.SetIsVisible(self.ImgIconNormalList[i], true)
		else
			UIUtil.SetIsVisible(self.ImgIconNormalList[i], false)
		end

		local IconPathSelect = ItemData.IconPathSelect
		if IconPathSelect ~= nil then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgIconSelectList[i], IconPathSelect)
			UIUtil.SetIsVisible(self.ImgIconSelectList[i], true)
		else
			UIUtil.SetIsVisible(self.ImgIconSelectList[i], false)
		end
	end
	for i = #ListData + 1, 3 do
		UIUtil.SetIsVisible(self.PanelTabList[i], false)
	end
end

---UpdateItems
---@param ListData table @ 显示文字时：{ { Name = "Item1" }, { Name = "Item2" }} 显示图标时： { { IconPathNormal = "IconPathNormal1", IconPathSelect = "IconPathSelect1" }, { IconPathNormal = "IconPathNormal2", IconPathSelect = "IconPathSelect2" } }
---@private SelectedIndex number @当前选中索引 从 1 开始
function CommTabsView:UpdateItems(ListData, SelectedIndex)
	self:UpdateItemsByValue(ListData)
	self:SetSelectedIndex(SelectedIndex or 1)
end

function CommTabsView:OnDestroy()
	self.SelectIndex = nil
	self.ImgBtnSelectList = nil
	self.ImgIconNormalList = nil
	self.ImgIconSelectList = nil
	self.TextlList = nil
end

function CommTabsView:OnHide()

end

function CommTabsView:GetSelectedIndex()
	return self.SelectIndex
end

function CommTabsView:SetCallBack(View, CallBack)
	self.View = View
	self.CallBack = CallBack
end

---外部设置TabStyle,在UpdateItem之前调用
---@param TabStyle 0:DarkBackgroundStyle 1:ColorfulBackgroundStyle 2:PaperBackgroundStyle
function CommTabsView:SetTabStyle(TabStyle)
	self.TabStyle = TabStyle
	if self.TabStyle == TabStyleEnum.DarkBackgroundStyle then
		self.ImageNormal = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_BG_Only_Small_Bright.UI_Btn_3thTab_BG_Only_Small_Bright'"
		self.ImageSelect = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_Only_Select_Small_Bright.UI_Btn_3thTab_Only_Select_Small_Bright'"
		self.ColorNormal = "#6c6964"
		self.ColorSelect = "#ffeebb"
		UIUtil.SetIsVisible(self.ImgBrightBG, true)
		UIUtil.SetIsVisible(self.ImgLightBG, false)
	elseif self.TabStyle == TabStyleEnum.ColorfulBackgroundStyle then
		self.ImageNormal = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_BG_Only_Small_Bright.UI_Btn_3thTab_BG_Only_Small_Bright'"
		self.ImageSelect = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_Only_Select_Small_Bright.UI_Btn_3thTab_Only_Select_Small_Bright'"
		self.ColorNormal = "#d5d5d5"
		self.ColorSelect = "#ffeebb"
		UIUtil.SetIsVisible(self.ImgBrightBG, true)
		UIUtil.SetIsVisible(self.ImgLightBG, false)
	elseif self.TabStyle == TabStyleEnum.PaperBackgroundStyle then
		self.ImageNormal = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_Only_Select_Small_Light.UI_Btn_3thTab_Only_Select_Small_Light'"
		self.ImageSelect = "Texture2D'/Game/UI/Texture/Button/UI_Btn_3thTab_BG_Only_Small_Light.UI_Btn_3thTab_BG_Only_Small_Light'"
		self.ColorNormal = "#313131"
		self.ColorSelect = "#ffeebb"
		UIUtil.SetIsVisible(self.ImgBrightBG, false)
		UIUtil.SetIsVisible(self.ImgLightBG, true)
	end
end

return CommTabsView