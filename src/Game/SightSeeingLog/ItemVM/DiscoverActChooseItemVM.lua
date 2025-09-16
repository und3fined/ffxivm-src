---
--- Author: Alex
--- DateTime: 2024-11-11 20:47:30
--- Description: 探索笔记情感动作选择Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local MapUtil = require("Game/Map/MapUtil")

---@class DiscoverActChooseItemVM : UIViewModel
local DiscoverActChooseItemVM = LuaClass(UIViewModel)

---Ctor
function DiscoverActChooseItemVM:Ctor()
    -- Main Part
    self.EmotionID = 0
    self.IconPath = ""
    self.EmotionName = ""
    self.bGot = false -- 是否获得
    self.Opacity = 1
    self.bCorrect = false -- 是否为正确动作
end

function DiscoverActChooseItemVM:IsEqualVM(_)
    return false
end

function DiscoverActChooseItemVM:UpdateVM(Value)
    local ID = Value.EmotionID
    if not ID then
        return
    end

    self.EmotionID = ID

    local Cfg = EmotionCfg:FindCfgByKey(ID)
    if not Cfg then
        return
    end
    self.IconPath = EmotionUtils.GetEmoActIconPath(Cfg.IconPath)
    self.EmotionName = Cfg.EmotionName or ""

    local bGot = Value.bGot
    self.bGot = bGot
    self.Opacity = bGot and 1 or 0.5
    self.bCorrect = Value.bCorrect
end

return DiscoverActChooseItemVM
