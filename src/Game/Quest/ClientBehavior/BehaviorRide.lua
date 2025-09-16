---
--- Author: sammrli
--- DateTime: 2024-7-15
--- Description:客户端行为 坐骑（陆行鸟运输）
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local EventID = require("Define/EventID")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProtoRes = require("Protocol/ProtoRes")
local TargetCfg = require("TableCfg/QuestTargetCfg")
local GameEventRegister = require("Register/GameEventRegister")
---@class BehaviorRide
local BehaviorRide = LuaClass(BehaviorBase, true)

function BehaviorRide:Ctor(_, Properties)
    self.Properties = Properties
end

function BehaviorRide:DoStartBehavior()
    local TargetCfg = self:GetCfgByTargetID()
    if TargetCfg == nil then
        return
    end

    -- find quest id
    local QuestID = nil
    if TargetCfg.ChapterID then
        local Chapter = QuestMgr.ChapterMap[TargetCfg.ChapterID]
        if Chapter then
            QuestID = Chapter.CurrQuestID
        end
    end

    -- find game id
    -- behavior ride 接完成小游戏quest target
    local GameID = 1
    if TargetCfg.Properties then
        GameID = tonumber(TargetCfg.Properties[1]) or 1
    end

    -- Cach Data
    _G.ChocoboTransportMgr:SetCurrentInteractiveNpcID(tonumber(TargetCfg.NaviObjID))
    _G.ChocoboTransportMgr:SetQuestStartMapID(TargetCfg.MapID)
    _G.ChocoboTransportMgr:InitTransportBaseData(self.Properties, GameID, QuestID)

    -- 重置跨地图条件数据
    _G.ChocoboTransportMgr:ResetAcrossMapData()

    -- 开始陆行鸟范式运输
    _G.ChocoboTransportMgr:QuestStartTrasport()
end


function BehaviorRide:GetCfgByTargetID()
    return TargetCfg:FindCfgByKey(self.TargetID)
end

function BehaviorRide:RegisterEvent(QuestEventID, Callback)
	if nil == self.GameEventRegister then
		self.GameEventRegister = GameEventRegister.New()
	end
	self.GameEventRegister:Register(QuestEventID, self, Callback)
end


return BehaviorRide