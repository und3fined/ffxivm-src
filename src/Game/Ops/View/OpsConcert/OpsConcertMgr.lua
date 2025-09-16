---
--- Author: usakizhang
--- DateTime: 2025--3--12
--- Description: 拉回流活动
---
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsID = require("Define/MsgTipsID")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local MsgTipsUtil = _G.MsgTipsUtil
---@class OpsConcertMgr : MgrBase
local OpsConcertMgr = LuaClass(MgrBase)

function OpsConcertMgr:OnInit()

end

function OpsConcertMgr:OnBegin()

end

function OpsConcertMgr:OnEnd()

end

function OpsConcertMgr:OnShutdown()

end

function OpsConcertMgr:OnRegisterNetMsg()

end


function OpsConcertMgr:OnRegisterGameEvent()

end

return OpsConcertMgr