---
--- Author: Leo
--- DateTime: 2024-2-19 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")

---@class GoldSaucerMonsterTossBallItemVM : UIViewModel

local GoldSaucerMonsterTossBallItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerMonsterTossBallItemVM:Ctor()
    -- Main Part
    self.ImgPath = ""
    self.Pos = 0
    self.BallType = 0
end

function GoldSaucerMonsterTossBallItemVM:IsEqualVM(Value)
    return true
end

function GoldSaucerMonsterTossBallItemVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    self.BallType = Value.BallType
    self.ImgPath = GoldSaucerMiniGameDefine.GetBallImgPathByType(self.BallType)
    -- self.bBallVisible = Value.bBallVisible
    -- self.Pos = Value.Pos
end

function GoldSaucerMonsterTossBallItemVM:ResetVM()
    self.ImgPath = ""
    self.Pos = 0
    self.BallType = 0
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