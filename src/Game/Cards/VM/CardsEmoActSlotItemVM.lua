--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local EmotionCfg = require("TableCfg/EmotionCfg")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

---@class CardsEmoActSlotItemVM : UIViewModel
local CardsEmoActSlotItemVM = LuaClass(UIViewModel)

--- func desc
---@param : IsGetted bool 是否已经获得了
---@param : EmoClassifyTable table 里面包含了在哪些动作中显示
function CardsEmoActSlotItemVM:Ctor(EmoTableID, EmoClassifyID, IsGetted, EmoClassifyTable)
    self.IsSelected = false
    self.EmotionTableID = EmoTableID
    self.EmoClassifyID = EmoClassifyID
    self.IsSelected = false
    self.IsUsed = false
    self.IsDisabled = false
    self.IsGetted = false
    self.IsContain = true
    self.EmoClassifyTable = EmoClassifyTable
    self.UIPriority = -1 -- 读取表的
end

--- 是否在输入的类型中显示，比如该动作是否为敬礼动作
---@param TargetEmoType MagicCardLocalDef.EmotionClassifyType
function CardsEmoActSlotItemVM:IsShowWithEmoType(TargetEmoType)
    for k,v in ipairs(self.EmoClassifyTable) do
        if (self.EmoClassifyTable == v) then
            return true
        end
    end

    return false
end

function UIViewModel:IsEqualVM(Value)
    return true
    --return self.EmoClassifyID == Value.EmoClassifyID
end

function CardsEmoActSlotItemVM:UpdateVM(Value)
    self.EmotionTableID = Value.EmotionTableID
    self.EmoClassifyID = Value.EmoClassifyTableID
    self.IsGetted = Value.IsGetted
    self.EmoClassifyTable = Value.ShowEmoTypeTable
    self.UIPriority = Value.UIPriority
    self.IsDisabled = Value.IsDisabled
end

function CardsEmoActSlotItemVM:GetEmoID()
    return self.EmotionTableID
end

function CardsEmoActSlotItemVM:SetIsSelected(TargetValue)
    self.IsSelected = TargetValue
end

function CardsEmoActSlotItemVM:SetIsUsed(TargetValue)
    self.IsUsed = TargetValue
end

function CardsEmoActSlotItemVM:GetIsUsed()
    return self.IsUsed
end

function CardsEmoActSlotItemVM:GetIsGetted()
    return self.IsGetted
end

--- 通过输入的动作类型来判断是否disable
---@param EmoType MagicCardLocalDef.EmotionClassifyType
function CardsEmoActSlotItemVM:GetIsDisabledByEmoType(EmoType)
    if (not self.IsGetted) then
        return true
    end

    -- 判断一下是否包含目标动作类型
    for k,v in ipairs(self.EmoClassifyTable) do
        if (self.EmoClassifyTable == v) then
            return false
        end
    end

    return true
end

--- 通过输入的动作类型来设置 IsDisabled
---@param EmoType MagicCardLocalDef.EmotionClassifyType
function CardsEmoActSlotItemVM:SetIsDisabledByEmoType(EmoType)
    self.IsDisabled = self:GetIsDisabledByEmoType(EmoType)
end

-- 要返回当前类
return CardsEmoActSlotItemVM
