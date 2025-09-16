---
--- Author: xingcaicao
--- DateTime: 2023-04-17 15:42
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")

local LSTR = _G.LSTR

---@class PersonInfoHeadPortraiEmoVM : UIViewModel
local PersonInfoHeadPortraiEmoVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoHeadPortraiEmoVM:Ctor( )
	self.EmoResID = nil 
    self.EmoIcon   = ""
    self.IsEmpty = nil
    self.IsSelt = false
end

function PersonInfoHeadPortraiEmoVM:IsEqualVM( Value )
    return Value ~= nil and self.EmoResID ~= nil and self.EmoResID == Value.EmoResID
end

function PersonInfoHeadPortraiEmoVM:UpdateVM( Value )
	self.EmoResID = Value.EmoID

    if self.EmoResID then
        local Cfg = EmotionCfg:FindCfgByKey(self.EmoResID) or {}
        self.EmoIcon = EmotionUtils.GetEmoActIconPath(Cfg.IconPath)
    end

    self.IsEmpty = self.EmoResID == nil
end

return PersonInfoHeadPortraiEmoVM