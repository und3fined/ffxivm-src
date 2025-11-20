---
--- Author: Alex
--- DateTime: 2025-06-13 19:06:31
--- Description: 仙人赐福VM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local LocalizationUtil = require("Utils/LocalizationUtil")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local FairyBlessedTimeCfg = require("TableCfg/FairyBlessedTimeCfg")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState
local BLESSED_KIND = ProtoCS.Game.FairyBlessed.BLESSED_KIND

local LSTR = _G.LSTR

local GoldSaucerBlessingVM = LuaClass(UIViewModel)

function GoldSaucerBlessingVM:Ctor()
    self.ActivityName = "" -- 活动名字
    self.ActivityDesc = "" -- 活动描述
    self.ActivityTime = "" -- 倒计时内容，目前调用的通用接口
    self.bShowCountDownTitle = false -- 是否显示倒计时
    self.KindIcon = "" -- 不同活动的图标
end

function GoldSaucerBlessingVM:OnInit()
end

function GoldSaucerBlessingVM:OnBegin()
end

function GoldSaucerBlessingVM:OnShutdown()
end

function GoldSaucerBlessingVM:OnEnd()
end

function GoldSaucerBlessingVM:SetPanelData(BlessState, BlessKind)
    self:SetNameAndCountDownTitleVisible(BlessState, BlessKind)
    -- TODO:显示描述（可能需要区分小游戏）
end

--- 设定活动信息（随状态变化啊）
function GoldSaucerBlessingVM:SetNameAndCountDownTitleVisible(BlessState, BlessKind)
    if BlessState == EBlessingState.NotBegin or BlessKind == BLESSED_KIND.BLESSED_KIND_NONE then
        return
    end

    if BlessState == EBlessingState.Prepare or BlessKind == BLESSED_KIND.BLESSED_KIND_LITTLE then
        self.ActivityName = LSTR(1660001) -- 仙人送福
        local Cfg = FairyBlessedTimeCfg:FindCfgByKey(BLESSED_KIND.BLESSED_KIND_LITTLE)
        if Cfg then
            self.KindIcon = Cfg.Icon
        end
    else
        self.ActivityName = LSTR(1660002) -- 仙人赐福
        local Cfg = FairyBlessedTimeCfg:FindCfgByKey(BLESSED_KIND.BLESSED_KIND_BIG)
        if Cfg then
            self.KindIcon = Cfg.Icon
        end
    end
    self.bShowCountDownTitle = BlessState == EBlessingState.Prepare
end

function GoldSaucerBlessingVM:UpdateTimeText(RemainSec)
    self.ActivityTime = LocalizationUtil.GetCountdownTimeForShortTime(RemainSec, "mm:ss")
end

return GoldSaucerBlessingVM
