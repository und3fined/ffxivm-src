---
--- Author: Alex
--- DateTime: 2025-07-24 11:34
--- Description:保镖游戏竹子轮次标志ItemVM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local BodyGuardEnumStage = GoldSauserMainPanelDefine.BodyGuardEnumStage


---@class BanbooStageItemVM : UIViewModel
local BanbooStageItemVM = LuaClass(UIViewModel)

function BanbooStageItemVM:Ctor()
    self.Index = 0
    self.State = BodyGuardEnumStage.NotStart
end

function BanbooStageItemVM:UpdateVM(Value)
    self.Index = Value.Index
end

function BanbooStageItemVM:IsEqualVM(Value)
	return self.Index == Value.Index
end

--- 切换轮次状态
function BanbooStageItemVM:SetState(State)
    self.State = State
end

return BanbooStageItemVM


