---
--- Author: Leo
--- DateTime: 2024-2-19 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfg = require("TableCfg/ItemCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local BasketballType = ProtoCS.BasketballType

---@class GoldSaucerMonsterTossBallItemVM : UIViewModel

local GoldSaucerMonsterTossBallItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerMonsterTossBallItemVM:Ctor()
    -- Main Part
    self.ImgPath = ""
    self.Pos = 0
    self.BallType = 0

    -- 赐福球另外启用面板
    self.bBlessBall = false
end

function GoldSaucerMonsterTossBallItemVM:IsEqualVM(Value)
    return true
end

function GoldSaucerMonsterTossBallItemVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    local BallType = Value.BallType
    self.BallType = BallType
    self.bBlessBall = BallType == BasketballType.BasketballType_Star
    self.ImgPath = GoldSaucerMiniGameDefine.GetBallImgPathByType(self.BallType)
    --FLOG_INFO("GoldSaucerMonsterTossBallItemVM BallType: %s, ImgPath", self.bBlessBall)
    -- self.bBallVisible = Value.bBallVisible
    -- self.Pos = Value.Pos
end

function GoldSaucerMonsterTossBallItemVM:ResetVM()
    self.ImgPath = ""
    self.Pos = 0
    self.BallType = 0
    self.bBlessBall = false
end

function GoldSaucerMonsterTossBallItemVM:UpdatePos(Pos)
    self.Pos = Pos
end

function GoldSaucerMonsterTossBallItemVM:GetPos()
    return self.Pos
end

function GoldSaucerMonsterTossBallItemVM:GetType()
    return self.BallType
end

return GoldSaucerMonsterTossBallItemVM   