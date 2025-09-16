---
--- Author: xingcaicao
--- DateTime: 2023-03-22 16:32
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local SettingsItemVM = require("Game/Settings/VM/SettingsItemVM")
local SettingsCfg = require("TableCfg/SettingsCfg")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")

local LanguageSetCategory = SettingsDefine.LanguageSetCategory
local LanguageSubCategory = SettingsDefine.LanguageSubCategory

local SettingsItemSliderVM = require("Game/Settings/VM/SettingsItemSliderVM")
local SettingsItemHyperLinkVM = require("Game/Settings/VM/SettingsItemHyperLinkVM")
local SettingsItemDropDownListVM = require("Game/Settings/VM/SettingsItemDropDownListVM")
local SettingsItemColorVM = require("Game/Settings/VM/SettingsItemColorVM")
local SettingsItemCustomBPEmbedVM = require("Game/Settings/VM/SettingsItemCustomBPEmbedVM")

---@class SettingsSubCategoryVM : UIViewModel
local SettingsSubCategoryVM = LuaClass(UIViewModel)

---Ctor
function SettingsSubCategoryVM:Ctor( )
    self.Category = 0
    self.SubCategory = 0
    self.SubCategoryName = ""
    self.Color = "" 
    self.IsSetColor = false
    self.ColorSaveKey = nil
    self.SetColorFunc = nil
	-- self.ItemList = UIBindableList.New(SettingsItemVM)
	self.ItemList = UIBindableList.New()
    self.HID = 0
    self.ButtonFunc = nil
end

function SettingsSubCategoryVM:UpdateVM( Value )
    local Category = Value.Category or 0
    local SubCategory = Value.SubCategory or 0

    self.Category        = Category
    self.SubCategory     = SubCategory
    self.SubCategoryName = Value.SubCategoryName or ""
    self.IsSetColor      = Value.IsSetColor == 1
    self.HID             = Value.HID or 0

    self.ColorSaveKey = Value.ColorSaveKey
    self.SetColorFunc = Value.SetColorFunc
    if not string.isnilorempty(Value.ButtonFunc) then
        self.ButtonFunc = Value.ButtonFunc
    end

    if self.IsSetColor then
		local Color = SettingsUtils.GetColor(self.ColorSaveKey)
		if string.isnilorempty(Color) then
			Color = Value.DefaultColor
		end

        self.Color = Color or ""
    end

    local CfgList = SettingsCfg:GetSettingsList(Category, SubCategory)
    local Cnt = #CfgList
    if Cnt > 0 then
        -- 游戏语言选项内容不能配置在表格中，不然会被多语言给翻译了
        if Category == LanguageSetCategory and SubCategory == LanguageSubCategory then 
            local Cfg = CfgList[1] 
            local Data = table.clone(Cfg, true)
            Data.Desc = Cfg.Desc
            if Cfg.ID == 51 then
                Data.Value = {"中文"}
            else 
                Data.Value = SettingsDefine.LanguagesDesc
            end
            Data.SwitchTips = Cfg.SwitchTips

            CfgList[1] = Data
        end

        self.ItemList:EmptyItems()

        for index = 1, Cnt do
            local Cfg =  CfgList[index]
            local VM = self:CreateViewModel(Cfg)
            if VM then
                VM:UpdateByValue(Cfg, nil, false)
                self.ItemList:Add(VM)
            end
        end
        -- self.ItemList:UpdateByValues(CfgList)

        self:RefreshItems()
    end
end

function SettingsSubCategoryVM:CreateViewModel(Cfg)
    if not Cfg then
        FLOG_ERROR("Setting CreateItemVM Error")
        return nil
    end

    local Style = Cfg.DisplayStyle
    local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle
    local ItemVM = nil
	if Style == ItemDisplayStyle.Slider then
        ItemVM = SettingsItemSliderVM.New()
	elseif Style == ItemDisplayStyle.Hyperlink or Style == ItemDisplayStyle.Button then
        ItemVM = SettingsItemHyperLinkVM.New()
	elseif Style == ItemDisplayStyle.DropDownList then
        ItemVM = SettingsItemDropDownListVM.New()
	elseif Style == ItemDisplayStyle.ColorPalette then
        ItemVM = SettingsItemColorVM.New()
	elseif Style == ItemDisplayStyle.TextByCustomUI then
        ItemVM = SettingsItemHyperLinkVM.New()
	elseif Style == ItemDisplayStyle.CustonBPEmbed then
        ItemVM = SettingsItemCustomBPEmbedVM.New()
	end

    return ItemVM
end

function SettingsSubCategoryVM:RefreshItems()
    local OpenMap = _G.SettingsMgr.SettingOpenMap
    local SettingMap = _G.SettingsMgr.SettingIDMap
    --目前只处理，原来不显示，后面显示的；  应该也只有这种情况
    for ID, bShow in pairs(OpenMap) do
        local SettingCfg = SettingMap[ID]
        if SettingCfg and SettingCfg.Category == self.Category and SettingCfg.SubCategory == self.SubCategory then
            local FindVM = self.ItemList:ContainEqualVM(SettingCfg)
            if bShow and not FindVM then
                local VM = self:CreateViewModel(SettingCfg)
                VM:UpdateByValue(SettingCfg, nil, false)
                self.ItemList:Add(VM)
                -- self.ItemList:AddByValue(SettingCfg)
            elseif not bShow and FindVM then
                self.ItemList:Remove(FindVM)
            end
        end
    end
end

function SettingsSubCategoryVM:AdapterOnGetWidgetIndex()
    return 0
end

function SettingsSubCategoryVM:AdapterOnGetChildren()
    return self.ItemList:GetItems()
end

return SettingsSubCategoryVM