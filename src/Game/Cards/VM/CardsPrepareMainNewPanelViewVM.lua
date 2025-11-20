--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local Log = require("Game/MagicCard/Module/Log")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local CardsEditDecksPanelVM = require("Game/Cards/VM/CardsEditDecksPanelVM")
local CardsPrepareRuleItemVM = require("Game/Cards/VM/CardsPrepareRuleItemVM")
local CardsDecksPageVM = require("Game/Cards/VM/CardsDecksPageVM")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

---@class CardsPrepareMainNewPanelViewVM : UIViewModel
local CardsPrepareMainNewPanelViewVM = LuaClass(UIViewModel)

---Ctor
function CardsPrepareMainNewPanelViewVM:Ctor()
    -- self.LocalString = nil
    -- self.TextColor = nil
    -- self.ProfID = nil
    -- self.GenderID = nil
    -- self.IsVisible = nil
    local LeftTablIconList = {} -- 左边的Icon list
    local IconPath1 = "/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Magic_Magic_Cards_Normal.UI_Icon_Tab_Magic_Magic_Cards_Normal"
    local SelectPath1 = "/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Magic_Cards_Select.UI_Icon_Tab_Magic_Cards_Select"
    table.insert(LeftTablIconList, {IconPath = IconPath1, SelectIcon = SelectPath1})
    local IconPath2 = "/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Magic_Action_Normal.UI_Icon_Tab_Magic_Action_Normal"
    local SelectPath2 = "/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Magic_Action_Select.UI_Icon_Tab_Magic_Action_Select"
    table.insert(LeftTablIconList, {IconPath = IconPath2, SelectIcon = SelectPath2})
    local IconPath3 = "/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Magic_Rules_Normal.UI_Icon_Tab_Magic_Rules_Normal"
    local SelectPath3 = "/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Magic_Rules_Select.UI_Icon_Tab_Magic_Rules_Select"
    table.insert(LeftTablIconList, {IconPath = IconPath3, SelectIcon = SelectPath3})
    self.LeftTablIconList = LeftTablIconList
    self.LeftTabSelectIndex = 1
    self.CardsEditDecksPanelVM = CardsEditDecksPanelVM.New(self)
    self.CardsDecksPageVM = CardsDecksPageVM.New(self)
    self.CanDragCard = false
    
    self.AllRuleVMList = UIBindableList.New(CardsPrepareRuleItemVM)
end

function CardsPrepareMainNewPanelViewVM:SetLeftTabSelectIndex(IndexValue)
    self.LeftTabSelectIndex = IndexValue
end

--- func desc
---@param TargetCardVM CardsSingleCardVM
function CardsPrepareMainNewPanelViewVM:CanDrag(TargetCardVM)
    return self.CanDragCard
end

function CardsPrepareMainNewPanelViewVM:CanCardClick(TargetCardVM)
    return self.CanDragCard
end

function CardsPrepareMainNewPanelViewVM:OnRefresh()
    self.CardsDecksPageVM:OnRefresh()
end

function CardsPrepareMainNewPanelViewVM:SetItemSelected(ItemVM)
    self.CardsDecksPageVM:SetItemSelected(ItemVM)
    self.CardsEditDecksPanelVM:SetEditGroupCardVM(ItemVM)
end

function CardsPrepareMainNewPanelViewVM:SetCurrentSelectItemDefault()
    self.CardsDecksPageVM:SetCurrentSelectItemDefault()
end

function CardsPrepareMainNewPanelViewVM:UpdateRuleVMList()
    self.AllRuleList = MagicCardVMUtils.GetAllRuleInfoList()
    self.AllRuleVMList:UpdateByValues(self.AllRuleList, nil, false)
end

--要返回当前类
return CardsPrepareMainNewPanelViewVM
