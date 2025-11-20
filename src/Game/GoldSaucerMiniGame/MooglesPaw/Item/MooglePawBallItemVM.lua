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
    self:SetNoCheckValueChange("ShowStateChange", true)
    self.StarAnimIndex = 0 -- 星光球的随机循环动画序号
    self.HistoryShowType = MogulBallType.MogulBallTypeInvalid
end

function MooglePawBallItemVM:IsEqualVM(_)
    return false
end

function MooglePawBallItemVM:UpdateVM(Value)
    self.BallID = Value.BallID
    self.StarAnimIndex = Value.StarAnimIndex
    local BallType = Value.BallType
    self.BallType = BallType
    self.HistoryShowType = BallType
    local PosX = Value.PosX or 0
    local PosY = Value.PosY or 0
    self.Position:SetValue(PosX, PosY)
    
end

-- 修改球的显示状态
function MooglePawBallItemVM:DeleteTheCaughtBall(BallID)
    if BallID == self.BallID then
        self.BallType = MogulBallType.MogulBallTypeInvalid
    end
end

return MooglePawBallItemVM
