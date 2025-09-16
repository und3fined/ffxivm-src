--
-- Author: alex
-- Date: 2022-10-24 14:55
-- Description:
--


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MapVM = require("Game/Map/VM/MapVM")
local MapUtil = require("Game/Map/MapUtil")


local MapUICfg = require("TableCfg/MapUICfg")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")
local MapIconMappingCfg = require("TableCfg/MapIconMappingCfg")
local UIViewMgr
local FLOG_INFO


---@class EasyTraceMapMgr : MgrBase
local EasyTraceMapMgr = LuaClass(MgrBase)

function EasyTraceMapMgr:OnInit()

end

function EasyTraceMapMgr:OnBegin()
	UIViewMgr = _G.UIViewMgr
end

function EasyTraceMapMgr:OnEnd()

end

function EasyTraceMapMgr:OnShutdown()

end

function EasyTraceMapMgr:OnRegisterNetMsg()

end

function EasyTraceMapMgr:OnRegisterGameEvent()

end

function EasyTraceMapMgr:OnRegisterTimer()
	
end

--- 通用模块简单地图切换地图接口
---@param MapID number@地图ID
---@param MapTitle string@便捷追踪标题
---@param CenterMarkerParams table@地图中心标记参数
---@param TraceMarkerParams table@追踪标记参数
---@param bCloseTelepo boolean@是否为最近传送点逻辑
---@param UIMapID number@有些地图没有对应的MapID
--- CenterMarkerID 为水晶的情况下执行判断是否需要打开传送Tips
function EasyTraceMapMgr:ShowEasyTraceMap(MapID, MapTitle, CenterMarkerParams, TraceMarkerParams, bCloseTelepo, UIMapID)
    local Params = {
        Data = {
            MapID = MapID,
            UIMapID = UIMapID,
            MapTitle = MapTitle,
            CenterMarkerParams = CenterMarkerParams,
            TraceMarkerParams = TraceMarkerParams,
            bCloseTelepo = bCloseTelepo
        }
    }
    UIViewMgr:ShowView(UIViewID.PlayStyleMapWin, Params)
end

return EasyTraceMapMgr