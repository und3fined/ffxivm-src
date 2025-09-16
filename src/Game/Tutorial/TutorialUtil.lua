---
---@Author: ZhengJanChuan
---@Date: 2023-05-26 17:15:40
---@Description: 教程功能类
---
local UIUtil = require("Utils/UIUtil")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local ProtoRes = require("Protocol/ProtoRes")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")

local TutorialUtil = {
}

function TutorialUtil:GetTutorialWidget(View, Path)
    if View == nil or Path == nil or Path == "" then
        return View
    end

    local ResTable = string.split(Path, "/")
    for _, v in ipairs(ResTable) do
        if View[v] then
            View = View[v]
        end
    end
    return View
end

function TutorialUtil:GetTutorialWidgetWithAdapter(View,Path,Index)
    if View == nil or Path == nil or Path == "" then
        return View
    end

    local ResTable = string.split(Path, "/")
    local Widget = nil
    local IsFindWidget = false
    local RealPath = nil

    for _, v in ipairs(ResTable) do
        if IsFindWidget then
            if RealPath == nil then
                RealPath = v
            else
                RealPath = RealPath .."/" .. v
            end
        end

        if View[v] and not IsFindWidget then
            View = View[v]
        end

        if string.find(v,"Adapter")  then
            if View ~= nil then
                if View["GetChildWidget"] ~= nil then
                    Widget = View:GetChildWidget(Index)
                    IsFindWidget = true
                else
                    FLOG_ERROR("Error View Name is: %s",v)
                end
            end
        end
    end

    if Widget ~= nil then
       return self:GetTutorialWidget(Widget,RealPath)
    end

    return View
end

function TutorialUtil:CalcMapViewPos(Map)
    local WidgetLocPos  = UIUtil.CanvasSlotGetPosition(Map)
	local WidgetSize = UIUtil.CanvasSlotGetSize(Map)
	local WidgetPosX = WidgetLocPos.X - WidgetSize.X + 30
	local WidgetPosY = WidgetLocPos.Y - WidgetSize.Y - 40

    return {X = WidgetPosX, Y  = WidgetPosY}
end

function TutorialUtil:GetMapItemAndParent(View, WidgetPath, ID)
    local MapMarkers = TutorialUtil:GetTutorialWidget(View, WidgetPath)

    if MapMarkers == nil then
        return
    end

    local MapMarker = nil 
    for _, v in pairs(MapMarkers) do
        if v.ViewModel.MapMarker.ID == ID then
            MapMarker = v.View
        end
    end

    if MapMarker == nil then
        return
    end

    return MapMarker, MapMarker:GetParent()
end

function TutorialUtil:HandleClickGuideWidget(Cfg, Widget)
    local Params = {}
    Params.FuncName = Cfg.EndFuncName
    Params.TutorialID = Cfg.TutorialID

    if Widget == nil then
        FLOG_ERROR("HandleClickGuideWidget Widget is nil")
        _G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)
        return
    end

    if Cfg.Type == TutorialDefine.TutorialType.NoFuncForce or Cfg.Type == TutorialDefine.TutorialType.NoFuncSoft then
        _G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)
        return
    end

    local Type = Cfg.HandleType
    local StartParam = Cfg.StartParam

    _G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)

    FLOG_INFO("Widget Name is %s",Widget:GetName())

    --特殊处理职业功能按扭
    if Cfg.WidgetPath == "ControlPanel/SkillGenAttackBtn_UIBP/Btn_Attack" then
        EventMgr:SendEvent(EventID.InputActionSkillPressed, 0)
        EventMgr:SendEvent(EventID.InputActionSkillReleased, 0)
    elseif Cfg.WidgetPath == "MountPanel/BtnRideMask_Control" then
        Widget["OnPressed"]:Broadcast()
        Widget["OnClicked"]:Broadcast()
        Widget["OnReleased"]:Broadcast()
    elseif Cfg.WidgetPath == "MountPanel/BtnFlighting" then
        Widget["OnPressed"]:Broadcast()
    elseif Cfg.WidgetPath == "MountPanel/SkillSprintMountDownBtn/BtnRun" then
        Widget:OnMountDownClick()
    else
        if Type == ProtoRes.TutorialClickedType.NormalButton then
            if Widget["OnClicked"] ~= nil then
                Widget["OnClicked"]:Broadcast()
            end
        elseif Type == ProtoRes.TutorialClickedType.TableViewButton then
            --这里的widget一定要填那个Adapter不是那个直接的Tableview控件
            local ChildWidget = Widget:GetChildWidget(StartParam)

            if ChildWidget ~= nil then
                Widget:OnItemClicked(ChildWidget, StartParam)
            else
                FLOG_ERROR("Error StartParam is %d",StartParam)
            end

        elseif Type == ProtoRes.TutorialClickedType.ToggleButton then
            if StartParam == 0 then
                Widget:SetChecked(true, nil)
            else
                Widget:SetCheckedIndex(StartParam - 1, true)
            end

        elseif Type == ProtoRes.TutorialClickedType.MapButton then
            if Widget == nil then
                return
            end

            local MapMarker
            for _, v in pairs(Widget) do
                if v.ViewModel.MapMarker.ID == tonumber(StartParam) then
                    MapMarker = v.ViewModel.MapMarker
                end
            end

            if MapMarker ~= nil then
                local CrystalID = MapMarker:GetEventArg()
                local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
                CrystalMgr:TransferByMap(CrystalID)
            end

        elseif Type == ProtoRes.TutorialClickedType.SkillButton then
            --_G.SkillLogicMgr:MajorPlaySkill(StartParam)
            if Widget == nil then
                return
            end

            Widget:OnCastSkill()
        end
    end
end

function TutorialUtil:GetContentDir(Dir)
    if Dir == nil then
        return TutorialDefine.TutorialArrowDir.Left
    end

    if Dir == 1 then
        return TutorialDefine.TutorialArrowDir.Top
    elseif Dir == 2 then
        return TutorialDefine.TutorialArrowDir.Bottom
    elseif Dir == 3 then
        return TutorialDefine.TutorialArrowDir.Left
    elseif Dir == 4 then
        return TutorialDefine.TutorialArrowDir.Right
    end
end

return TutorialUtil