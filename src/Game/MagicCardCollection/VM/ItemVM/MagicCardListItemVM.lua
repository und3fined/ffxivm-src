--
-- Author: Carl
-- Date: 2023-09-08 16:57:14
-- Description:幻卡图鉴列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MagicCardListItemVM : UIViewModel
local MagicCardListItemVM = LuaClass(UIViewModel)

function MagicCardListItemVM:Ctor()
    --self.CardIcon = 0
    self.IsUnLock = false
    self.CardID = 0
    self.FrameType = 0
    self.IsNewUnlock = false
    --self.bIconVisible = true
    --self.bUnOwnVisible = false
    --self.IsNewlyObtained = false
end


function MagicCardListItemVM:IsEqualVM(Value)
    return Value.CardID == self.CardID
end

function MagicCardListItemVM:GetKey()
	return self.CardID
end

function MagicCardListItemVM:UpdateVM(Value)
    --self.CardIcon = Value.Icon
    self.IsUnLock = Value.IsUnLock
    self.CardID = Value.CardID
    self.FrameType = Value.FrameType
    self.IsNewUnlock = Value.IsNewUnlock
    --self.bIconVisible = not self.IsLock
    --self.IsNewlyObtained = Value.IsNewlyObtained
end

return MagicCardListItemVM