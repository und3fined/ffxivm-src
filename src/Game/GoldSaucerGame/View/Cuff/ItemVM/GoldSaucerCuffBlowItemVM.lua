---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local GoldSaucerCuffBlowResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffBlowResultItemVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")

local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine

local TimerMgr = _G.TimerMgr

---@class GoldSaucerCuffBlowItemVM : UIViewModel

local GoldSaucerCuffBlowItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerCuffBlowItemVM:Ctor()
    self.ID = 0
    -- self.Type = 0
    -- self.Pos = 0
    -- self.bVisible = false
    -- self.BlowStyle = ""
    -- self.Scale = CuffDefine.BlowDefaultSize
    -- self.ExplosionStyle = ""
    -- self.ShrinkSp = 0
    -- self.DelayShowTime = 0
    -- self.DelayShrinkTime = 0
    -- self.bZoneVisible = true
    -- self.bExplosionVisible = false
    -- self.bBtnVisible = true
    -- self.bBlowResultVisible = false
    -- self.CuffBlowResultItemVM = GoldSaucerCuffBlowResultItemVM.New()
    
end

function GoldSaucerCuffBlowItemVM:IsEqualVM(Value)
    return true
end

function GoldSaucerCuffBlowItemVM:UpdateVM(Value)
    -- self.bVisible = false
 
    -- self.bVisible = Value.Pos == self.ID
    -- if not self.bVisible then
    --     return
    -- end
    if Value == nil then
        return
    end
    self.Type = Value.Type
    self.Pos = Value.Pos
    -- self.BlowStyle = Value.BlowStyle
    -- self.ExplosionStyle = Value.ExplosionStyle
    self.DelayShowTime = Value.DelayShowTime / 1000
    _G.FLOG_WARNING("%s", self.DelayShowTime)
    self.DelayShrinkTime = Value.DelayShrinkTime / 1000
    self.ShrinkSp = Value.ShrinkSp

    self.Scale = CuffDefine.BlowDefaultSize * (1 - (Value.Scale - 1))   -- _G.UE.FVector2D(DefaultSize * (2 - Value.Scale) , DefaultSize * (2 - Value.Scale) )
    -- self.bZoneVisible = Value.bZoneVisible
    -- self.bExplosionVisible = Value.bExplosionVisible
    -- self.bBtnVisible = Value.bZoneVisible
    self.bBlowResultVisible = Value.bBlowResultVisible

    if Value.ResultData ~= nil then
        self.CuffBlowResultItemVM:UpdateVM(Value.ResultData)
    end
end

function GoldSaucerCuffBlowItemVM:UpdateID(ID)
    self.ID = ID
end

function GoldSaucerCuffBlowItemVM:GetID()
    return self.ID
end

function GoldSaucerCuffBlowItemVM:GetBlowResultItemVM()
    return self.CuffBlowResultItemVM
end


function GoldSaucerCuffBlowItemVM:ResetVM()
    -- self.ID = 0
    -- self.Type = 0
    -- self.Pos = 0
    -- self.bVisible = false
    -- self.BlowStyle = ""
    self.Scale = _G.UE.FVector2D(300, 300)
    -- self.ExplosionStyle = ""
    self.ShrinkSp = 0
    self.DelayShowTime = 0
    self.DelayShrinkTime = 0
    -- self.bZoneVisible = true
    -- self.bExplosionVisible = false
    -- self.bBtnVisible = true
    self.bBlowResultVisible = false
    self.CuffBlowResultItemVM:ResetVM()
end

return GoldSaucerCuffBlowItemVM