--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local Log = require("Game/MagicCard/Module/Log")
local CardsSingleCardVM = require("Game/Cards/VM/CardsSingleCardVM")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local LSTR = _G.LSTR
local CardTypeEnum = LocalDef.CardItemType
local FilterBtnType = LocalDef.FilterBtnType

---@class CardsGroupCardVM : UIViewModel
local CardsGroupCardVM = LuaClass(UIViewModel)

---Ctor ParentVM 是 CardsDecksPageVM
function CardsGroupCardVM:Ctor(ParentVM, Index)
    -- self.LocalString = nil
    -- self.TextColor = nil
    -- self.ProfID = nil
    -- self.GenderID = nil
    -- self.IsVisible = nil
    self.__Index = Index
    self.__ParentVM = ParentVM
    self.GroupName = self:GetDefaultGroupName()
    self.IsAllRulePass = false -- 是否有效
    self.CheckNotify = true -- 这里是为了方便做检测的，外面的检测，没有实际显示作用
    self.IsCurrentSelect = false
    self.IsDefaultGroup = false
    self.CheckRuleCardNum = 0
    self.CheckRuleFourStarCard = 0
    self.CheckRuleFiveStarCard = 0
    local GroupCardList = {}
    -- 这里是里面的卡槽位置
    for i = 1, 5 do
        GroupCardList[i] = CardsSingleCardVM.New(self, i, CardTypeEnum.InfoShow)
    end
    self.GroupCardList = GroupCardList

    self.IsAutoGroup = false -- 是否为自动组卡
end

--- func desc
---@param TargetVM CardsSingleCardVM
function CardsGroupCardVM:CanCardClick(TargetVM)
    return self.__ParentVM:CanCardClick(TargetVM)
end

--- func desc
---@param TargetItemVM CardsSingleCardVM
function CardsGroupCardVM:OnDragEnter(TargetItemVM)
    self.__ParentVM:OnDragEnter(TargetItemVM)
end

--- func desc
---@param TargetItemVM CardsSingleCardVM
function CardsGroupCardVM:OnDragLeave(TargetItemVM)
    self.__ParentVM:OnDragLeave(TargetItemVM)
end

--- func desc
---@param TargetItemVM CardsSingleCardVM
function CardsGroupCardVM:OnDrop(TargetItemVM)
    self.__ParentVM:OnDrop(TargetItemVM)
end

function CardsGroupCardVM:ChangeCheckNotify()
    self.CheckNotify = not self.CheckNotify
end

function CardsGroupCardVM:SetIsDefaultGroup(IsDefaultGroup)
    self.IsDefaultGroup = IsDefaultGroup
end

---@param TargetValue bool
function CardsGroupCardVM:SetIsSelected(TargetValue)
    self.IsCurrentSelect = TargetValue
end

function CardsGroupCardVM:HandleCardClicked()
    -- 这里只是为了不空报错
end

--- 只拷贝 ID, index, name
function CardsGroupCardVM:SimpleCopyFromOther(OtherEditItemVm)
    if not OtherEditItemVm then
        return
    end

    self.GroupName = OtherEditItemVm.GroupName
    self.__Index = OtherEditItemVm.__Index
    self.IsDefaultGroup = OtherEditItemVm.IsDefaultGroup
    local OtherGroupCardList = {}
    for i = 1, 5 do
        OtherGroupCardList[i] = OtherEditItemVm.GroupCardList[i]:GetCardId()
    end
    self:SetGroupCardList(OtherGroupCardList)
end

function CardsGroupCardVM:SetGroupName(TargetValue)
    self.GroupName = TargetValue
end

function CardsGroupCardVM:SetIsAutoGroup(TargetValue)
    self.IsAutoGroup = TargetValue
end

function CardsGroupCardVM:SetCurrentSelectItemDefault()
    self.__ParentVM:SetItemAsDefaultGroup(self, true)
end

function CardsGroupCardVM:GetDefaultGroupName()
    return string.format(LSTR(LocalDef.UKeyConfig.CardGroupName), self.__Index)
end

---@params CardList 是个ID List
function CardsGroupCardVM:SetGroupCardList(CardList)
    if (CardList == nil or #CardList ~= LocalDef.CardCountInGroup) then
        for i = 1, LocalDef.CardCountInGroup do
            self.GroupCardList[i]:SetCardId(0)
        end
    else
        for i, CardId in ipairs(CardList) do
            self.GroupCardList[i]:SetCardId(CardId)
        end
    end

    MagicCardMgr.CheckCardGropuIsValid(self)
end

---@type 卡组是否可用 不足5张
function CardsGroupCardVM:IsGroupAvailable()
    if (self.GroupCardList == nil or #self.GroupCardList ~= LocalDef.CardCountInGroup) then
        return false
    end

    -- 有空卡牌
    for i, CardItem in ipairs(self.GroupCardList) do
        if CardItem:IsCardEmpty() then
            return false
        end
    end

    return true
end

function CardsGroupCardVM:SaveEditGroup()
    MagicCardMgr:SendGroupSaveEditReq(self)
end

function CardsGroupCardVM:GetIndex()
    return self.__Index
end

function CardsGroupCardVM:GetServerIndex()
    if (self.__Index > 0) then
        return self.__Index - 1
    else
        return self.__Index
    end
end

-- 要返回当前类
return CardsGroupCardVM
