---
--- Author: Alex
--- DateTime: 2024-02-29 19:41:30
--- Description: 莫古抓球机球体VM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local MogulBallType = ProtoRes.Game.MogulBallType
local BindableVector2D = require("UI/BindableObject/BindableVector2D")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MoogleBallShowState = GoldSaucerMiniGameDefine.MoogleBallShowState
--local UIUtil = require("Utils/UIUtil")

---@class MooglePawBallItemVM : UIViewModel

local MooglePawBallItemVM = LuaClass(UIViewModel)

---Ctor
function MooglePawBallItemVM:Ctor()
    -- Main Part
    self.BallID = 0
    self.BallType = MogulBallType.MogulBallTypeInvalid
    self.Position = BindableVector2D.New()
    self.ShowStateChange = MoogleBallShowState.Normal
    self:SetNoCheckValueChange("ShowStateChange", true)
end

function MooglePawBallItemVM:IsEqualVM(Value)
    return false
end

function MooglePawBallItemVM:UpdateVM(Value)
    self.BallID = Value.BallID
    local BallType = Value.BallType
    self.BallType = BallType
    local PosX = Value.PosX or 0
    local PosY = Value.PosY or 0
    self.Position:SetValue(PosX, PosY)
end

-- 显示结果时不考虑不存在的球
function MooglePawBallItemVM:ChangeShowState(MoogleBallShowState)
    if self.BallID == 0 then
        return
    end
    self.ShowStateChange = MoogleBallShowState
end

return MooglePawBallItemVM
