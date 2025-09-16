---
--- Author: Alex
--- DateTime: 2025-01-09 10:41
--- Description:拯救雏鸟炸弹ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local BirdBombState = GoldSauserMainPanelDefine.BirdBombState


---@class GoldSauserMainPanelBombItemVM : UIViewModel
local GoldSauserMainPanelBombItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSauserMainPanelBombItemVM:Ctor()
    self.PosIndex = nil -- 炸弹位置序号
    self.BombState = BirdBombState.Default -- 默认不显示
    self:SetNoCheckValueChange("BombState", true)
end

function GoldSauserMainPanelBombItemVM:IsEqualVM(_)
	return false
end

function GoldSauserMainPanelBombItemVM:UpdateVM(Value)
    self.PosIndex = Value.Index
    self.BombState = Value.State
end

function GoldSauserMainPanelBombItemVM:GetTheBombState()
    return self.BombState
end

function GoldSauserMainPanelBombItemVM:SetTheBombState(State)
    self.BombState = State
end

return GoldSauserMainPanelBombItemVM
