---本Adapter使用ArrayItems的时候，暂未考虑Category机制，请注意

local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local BuffDefine = require("Game/Buff/BuffDefine")

---@class UIAdapterTableViewEx : UIAdapterTableView
local UIAdapterTableViewEx = LuaClass(UIAdapterTableView, true)

function UIAdapterTableViewEx:Ctor()
    self.MaxDisplayNum = 999
    self.OnUpdate = nil
	self.bItemRemoveSelectFirst = false
    self.bIgnoreCombatBuff = false
    self.bIgnoreLifeSkillBuff = false
    self.bIgnoreBonusState = false
end

---@return UIAdapterTableViewEx
function UIAdapterTableViewEx.CreateAdapter(...)
	local Adapter = UIAdapterTableViewEx.New()  ---@type UIAdapterTableViewEx
	Adapter:InitAdapter(...)
    return Adapter
end

---@param OnUpdate function function(IsEmpty, IsLimited) IsLimited:显示的数量是否受到MaxDisplayNum的限制
---@param bItemRemoveSelectFirst bool 当选中Item被移除时，自动尝试选中第一个Item
function UIAdapterTableViewEx:UpdateSettings(MaxDisplayNum, OnUpdate, bItemRemoveSelectFirst, bIgnoreCombatBuff, bIgnoreLifeSkillBuff, bIgnoreBonusState)
    self.MaxDisplayNum = MaxDisplayNum or 999
    self.OnUpdate = OnUpdate
	self.bItemRemoveSelectFirst = bItemRemoveSelectFirst or false
    self.bIgnoreCombatBuff = bIgnoreCombatBuff or false
    self.bIgnoreLifeSkillBuff = bIgnoreLifeSkillBuff or false
    self.bIgnoreBonusState = bIgnoreBonusState or false
end

function UIAdapterTableViewEx:UpdateChildren()
    self.Super:UpdateChildren()

    -- 如果选中的Buff被移除，则尝试选中第一个
    if self.bItemRemoveSelectFirst and self.SelectedItem and not self:GetSelectedIndex() then
        self:SelectFirstItem()
	end

    local DisplayNum = self:GetItemDataDisplayNum()
    if self.OnUpdate then
        local IsEmpty = (DisplayNum <= 0)
        local IsLimited = false

        local DataNum = self:GetNum()
        if DisplayNum > 0 and DataNum > DisplayNum then
            local ItemHash = self.ArrayItems:Get(DisplayNum)
            local LastDisplayDataIndex = self:GetItemIndex(ItemHash)
            for i = LastDisplayDataIndex + 1, DataNum do
                local ItemData = self.BindableList:Get(i)
                if self:IsItemVisible(ItemData) then
                    IsLimited = true
                    break
                end
            end
        end

        self.OnUpdate(IsEmpty, IsLimited)
    end
end

function UIAdapterTableViewEx:GetMaxItemDataDisplayNum()
    return math.min(self:GetNum(), self.MaxDisplayNum)
end

---@param ItemData ActorBufferVM
function UIAdapterTableViewEx:IsItemVisible(ItemData)
    if (ItemData.BuffSkillType == BuffDefine.BuffSkillType.BonusState and self.bIgnoreBonusState) or
       (ItemData.BuffSkillType == BuffDefine.BuffSkillType.Combat and self.bIgnoreCombatBuff) or
       (ItemData.BuffSkillType == BuffDefine.BuffSkillType.Life and self.bIgnoreLifeSkillBuff) then
        return false
    end

    return self.Super:IsItemVisible(ItemData)
end

function UIAdapterTableViewEx:SelectFirstItem()
    local DisplayNum = self:GetItemDataDisplayNum()
    if DisplayNum > 0 then
        local ItemHash = self.ArrayItems:Get(1)
        local FirstDisplayDataIndex = self:GetItemIndex(ItemHash)
        self:SetSelectedIndex(FirstDisplayDataIndex)
    end
end

function UIAdapterTableViewEx:SelectLastItem()
    local DisplayNum = self:GetItemDataDisplayNum()
    if DisplayNum > 0 then
        local ItemHash = self.ArrayItems:Get(DisplayNum)
        local LastDisplayDataIndex = self:GetItemIndex(ItemHash)
        self:SetSelectedIndex(LastDisplayDataIndex)
    end
end

function UIAdapterTableView:GetItemDataDisplayNum()
    -- loiafeng: 暂不考虑Category的情况
	return self.ArrayItems:Length()
end

return UIAdapterTableViewEx
