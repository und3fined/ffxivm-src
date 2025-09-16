local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateTextCfgTable = require("TableCfg/FateTextCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local FateDefine = require("Game/Fate/FateDefine")
local NpcCfgTable = require("TableCfg/NpcCfg")
local BindableVector2D = require("UI/BindableObject/BindableVector2D")
local FateHighRiskCfg = require("TableCfg/FateHighRiskCfg")
local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerFate
local MapMarkerFate = LuaClass(MapMarker)

function MapMarkerFate:Ctor()
    self.FateID = nil
    self.StartTimeMS = nil
    self.Progress = nil
    self.Radius = 0
    self.IsSpecial = false
    self.ImgIconFateNpcVisible = false
    self.ImgIconFateNpcPath = ""
    self.FateNpcPosX = 0
    self.FateNpcPosY = 0
    self.IsEnterArea = false
end

function MapMarkerFate:GetType()
    return MapMarkerType.Fate
end

function MapMarkerFate:GetBPType()
    return MapMarkerBPType.Fate
end

function MapMarkerFate:GetAreaMapPos()
    if self.WorldPosX and self.WorldPosY then
        local Point = {}
        Point.X = self.WorldPosX
        Point.Y = self.WorldPosY
        return MapUtil.GetUIPosByLocation(Point, self.UIMapID)
        --return MapUtil.ConvertMapPos2UI(self.WorldPosX, self.WorldPosY, 0, 0, 100, true)
    else
        return 0, 0
    end
end

function MapMarkerFate:GetFateNpcMapPos()
    if self.FateNpcPosX ~= 0 and self.FateNpcPosY ~= 0 then
        local Point = {}
        Point.X = self.FateNpcPosX
        Point.Y = self.FateNpcPosY
        return MapUtil.GetUIPosByLocation(Point, self.UIMapID)
        --return MapUtil.ConvertMapPos2UI(self.FateNpcPosX, self.FateNpcPosY, 0, 0, 100, true)
    else
        return 0, 0
    end
end

function MapMarkerFate:GetImgIconFateNpcVisible()
    return self.ImgIconFateNpcVisible
end

function MapMarkerFate:GetImgIconFateNpcPath()
    return self.ImgIconFateNpcPath
end

function MapMarkerFate:OnTriggerMapEvent(EventParams)
    local Params = {
        MapMarker = self,
        ScreenPosition = EventParams.ScreenPosition,
        FateID = self.FateID,
        StartTimeMS = self.StartTimeMS,
        Progress = self.Progress,
        State = self.State,
        IsSpecial = self.IsSpecial,
        ItemTimeMS = self.ItemTimeMS,
        bHighRisk = self.bHighRisk,
        EndTimeMS = self.EndTimeMS
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.WorldMapMarkerFateStageInfoPanel, Params)
end

function MapMarkerFate:GetTipsName()
    return self.Name
end

function MapMarkerFate:GetRadius()
	return self.Radius
end

function MapMarkerFate:InitMarker(Params)
    self:UpdateMarker(Params)
end

function MapMarkerFate:UpdateMarker(Params)
    if (Params == nil) then
        _G.FLOG_ERROR("传入的 Params 为空，请检查")
        return
    end
    self.FateID = Params.ID
    self.StartTimeMS = Params.StartTime
    self.Progress = Params.Progress
    self.State = Params.State
    self.IsSpecial = Params.IsSpecial
    self.ItemTimeMS = Params.ItemTime
    self.IsEnterArea = Params.IsEnterArea
    self.bHighRisk = Params.HighRiskState and Params.HighRiskState > 0
    self.EndTimeMS = Params.EndTime
    local NpcCfgCfg = nil
    local Level = 0
    local FateMainCfg = FateMainCfgTable:FindCfgByKey(self.FateID)
    if FateMainCfg then
        local RangeString = FateMainCfg.Range
        local NPCLocationString = FateMainCfg.TriggerNPCLocation
        NpcCfgCfg = NpcCfgTable:FindCfgByKey(FateMainCfg.TriggerNPC)
        Level = FateMainCfg.Level
        local bWaitTrigger = self.State == ProtoCS.FateState.FateState_WaitNPCTrigger

        if (bWaitTrigger) then
            if (NPCLocationString ~= "") then
                local NPCLocParams = string.split(NPCLocationString, ",")
                self:SetWorldPos(tonumber(NPCLocParams[1]), tonumber(NPCLocParams[2]), tonumber(NPCLocParams[3]))
            elseif (RangeString ~= "") then
                local RangeParams = string.split(RangeString, ",")
                self:SetWorldPos(tonumber(RangeParams[1]), tonumber(RangeParams[2]), tonumber(RangeParams[3]))
            else
                self:SetWorldPos(Params.FateCenter.X, Params.FateCenter.Y, Params.FateCenter.Z)
            end

            self.IconPath = FateDefine.GetIcon(ProtoRes.FateIconType.ICON_NPC_WAIT)
        elseif (RangeString ~= "") then
            if self.IsSpecial then
                -- 这里从图鉴跳转需要从配置里读位置
                local RangeParams = string.split(RangeString, ",")
                self:SetWorldPos(tonumber(RangeParams[1]), tonumber(RangeParams[2]), tonumber(RangeParams[3]))
                self.Radius = tonumber(RangeParams[5])
                self.IconPath = FateDefine.GetIconByFateID(self.FateID)
            else
                -- 这里以前是去取表格里面的，其实传过来的就是实际的位置了，不用再取拿表格里面的
                self:SetWorldPos(Params.FateCenter.X, Params.FateCenter.Y, Params.FateCenter.Z)
                self.Radius = Params.FateRadius
                self.IconPath = FateDefine.GetIconByFateID(self.FateID)
            end
        else
            _G.FLOG_ERROR("没有合适的显示方式，FATEID:" .. Params.ID)
        end

        if (bWaitTrigger) then
            self.Radius = 0 -- 等待触发的话，其范围是0，显示NPC的位置就行，不用显示范围
        else
            -- 如果不是在进行中，并且不是在完成提交阶段，并且有NPC的位置，那么只显示NPC的位置，不显示范围了
            local bInProgress = self.State == ProtoCS.FateState.FateState_InProgress
            local bEndSubmit = self.State == ProtoCS.FateState.FateState_EndSubmitItem
            if (not bInProgress and not bEndSubmit and NPCLocationString ~= "") then
                self.Radius = 0
            end
        end

        local bCollectFate = FateMainCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT
        local bInProgress = self.State == ProtoCS.FateState.FateState_InProgress
        local bEndSubmit = self.State == ProtoCS.FateState.FateState_EndSubmitItem
        if bCollectFate and (bInProgress or bEndSubmit) and self.IsEnterArea then
            self.ImgIconFateNpcVisible = true
            self.ImgIconFateNpcPath = FateDefine.GetIconByFateID(self.FateID)
            local NPCLocParams = string.split(NPCLocationString, ",")
            self.FateNpcPosX = tonumber(NPCLocParams[1])
            self.FateNpcPosY = tonumber(NPCLocParams[2])
        else
            self.ImgIconFateNpcVisible = false
        end
    else
        _G.FLOG_ERROR("FateID = %s not configured!", Params.ID)
    end

    local FateTextCfg = FateTextCfgTable:FindCfgByKey(Params.ID)
    if FateTextCfg then
        local NameStr = FateTextCfg.NameCh
        local levelStr = string.format(LSTR(10031), Level)
        if (self.bHighRisk) then
            local ShortName = ""
            local TableData = FateHighRiskCfg:FindCfgByKey(Params.HighRiskState)
            if (TableData ~= nil) then
                ShortName = TableData.ShortTitle or ""
            else
                _G.FLOG_ERROR("无法找到高危词条表格数据，ID是：%s", Params.HighRiskState)
            end

            local FinalName = levelStr .. " " .. string.format(LSTR(190138), ShortName, NameStr) -- %s·%s 2字词条名字加怪物名字
            self.Name = FinalName
        else
            self.Name = levelStr .. " " .. NameStr
        end
    else
        _G.FLOG_ERROR("无法获取 FateTextCfgTable 数据，请检查，ID是：" .. tostring(Params.ID))
        self.Name = LSTR(190115)
    end

    self:UpdateFollow()
end

function MapMarkerFate:IsCanShowInDiscovery()
    if _G.FogMgr:IsAllActivate(self.MapID) then
        return true
    end

    local InDiscovery =
        _G.MapAreaMgr:GetDiscoveryIDByLocation(self.WorldPosX, self.WorldPosY, self.WorldPosZ, self.MapID)
    if InDiscovery and InDiscovery > 0 then
        return _G.FogMgr:IsInFlag(self.MapID, InDiscovery)
    end

    return true
end

function MapMarkerFate:IsControlByFog()
    return true
end

return MapMarkerFate
