---
--- Author: xingcaicao
--- DateTime: 2023-09-11 17:30
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapUtil = require("Game/Map/MapUtil")

local LSTR = _G.LSTR

---@class ChatHyperlinkLocationItemVM : UIViewModel
local ChatHyperlinkLocationItemVM = LuaClass(UIViewModel)

function ChatHyperlinkLocationItemVM:Ctor()
    self.Type       = nil
    self.MapID      = nil
    self.MapDesc    = nil
    self.Tips       = nil
    self.NormalIcon = nil

    self.Position = nil
    self.PositionDesc = nil
end

function ChatHyperlinkLocationItemVM:IsEqualVM( Value )
    return false
end

function ChatHyperlinkLocationItemVM:UpdateVM( Value )
    self.Type       = Value.Type 
    self.NormalIcon = Value.NormalIcon 

    local MapDescUkey = Value.MapDescUkey
    self.MapDesc = MapDescUkey and LSTR(MapDescUkey) or ""

    local TipsUkey = Value.TipsUkey
    self.Tips = TipsUkey and LSTR(TipsUkey) or ""

    self.MapID = nil
    self.Position = nil
    self.PositionDesc = nil
end

function ChatHyperlinkLocationItemVM:UpdateByCurLocation()
    local MapID, Pos = MapUtil.GetMajorMapIDAndPosition()
    self.MapID = MapID
    self.Position = Pos

    -- 地图名
    self.MapDesc =  MapUtil.GetChatHyperlinkMapName(MapID)

    -- 位置描述
    self.PositionDesc = string.format("(%.1f,%.1f)", Pos.X or "", Pos.Y or "")
end

return ChatHyperlinkLocationItemVM