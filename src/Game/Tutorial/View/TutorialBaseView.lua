---
--- Author: ZhengJanChuan
--- DateTime: 2024-07-09 15:45
--- Description:新手引导界面基类
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local TutorialGameHandleType = ProtoRes.TutoriaEndHandleType
local UIViewMgr = require("UI/UIViewMgr")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local LogMgr = require("Log/LogMgr")
local UE = _G.UE

local TutorialBaseView = LuaClass(UIView, true)

function TutorialBaseView:Ctor()
    self.TutorialID = 0
    self.TutorialTime = 0
    self.TutorialTimerID = nil
end

function TutorialBaseView:OnRegisterSubView()
end

function TutorialBaseView:OnInit()
end

function TutorialBaseView:OnDestroy()
end

function TutorialBaseView:OnShow()
    
end

function TutorialBaseView:OnHide()
    if self.TutorialTimerID ~= nil then
        self:UnRegisterTimer(self.TutorialTimerID)
        self.TutorialTimerID = nil
    end
    self.TutorialTime = 0
    self.TutorialID = 0
end

function TutorialBaseView:OnRegisterUIEvent()
end

function TutorialBaseView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.TutorialRemoveGuideView, self.OnTutorialRemoveGuideView)
end

function TutorialBaseView:SetTutorialParams()
    local Params = self.Params

    if Params == nil then
        return
    end

    local TutorialID = Params.TutorialID

    self.TutorialID = TutorialID

    local Cfg = _G.NewTutorialMgr:GetRunningCfg(TutorialID)

    if Cfg ~= nil then
        local Time = Cfg.Time
        -- 定时器
        if Time > 0 then
            self.TutorialTime = 0
            self.TutorialTimerID = self:RegisterTimer(self.OnTutorialTimer, 0, 0.05, 0, {Time = Time, TutorialID = TutorialID} )
        end
    else
        LogMgr.Info(string.format("找不到对应的引导行 %d", TutorialID))
    end
end

--- 设置引导层的size
function TutorialBaseView:SetGuidePanelSize(ParentView,Cfg)
    local TutorialID = self.TutorialID
    local WidgetPath = Cfg.WidgetPath
    local Widget = TutorialUtil:GetTutorialWidget(ParentView, WidgetPath)
    local HandleType = Cfg.HandleType
    local StartParam = tonumber(Cfg.StartParam)

    --- 原控件
    local UIBPName = Cfg.BPName
    local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
    local View = UIViewMgr:FindVisibleView(ViewID)

    --- 引导层
    local GuideBPName = Cfg.GuideBPName
    local GuideViewID =  UIViewMgr:GetViewIDByName(GuideBPName)

    local Top = TutorialCfg:GetTutorialTop(TutorialID)
    local Left = TutorialCfg:GetTutorialLeft(TutorialID)

    local Pos = UE.FVector2D(0, 0)
    local WidgetZOrder = 0

    if HandleType == TutorialDefine.TutorialHandleType.TableView then
        Pos = TutorialUtil:CalcTableViewPos(Widget, StartParam, 20)
        UIUtil.CanvasSlotSetAutoSize(self, true)
        UIUtil.CanvasSlotSetAlignment(self, UE.FVector2D(0.5, 0.5))
    elseif HandleType == TutorialDefine.TutorialHandleType.Map then
        local MapMarker, ParentView = TutorialUtil:GetMapItemAndParent(View, WidgetPath, EndParam)
        WidgetZOrder =  UIUtil.CanvasSlotGetZOrder(MapMarker)
        Pos = TutorialUtil:CalcMapViewPos(MapMarker, ParentView) 
        UIUtil.CanvasSlotSetAlignment(self, UE.FVector2D(0, 0))
    else
        if GuideViewID == UIViewID.TutorialGestureMainPanel then
            Pos = UE.FVector2D(0, 0)
        else
            Pos = UIUtil.GetLocalTopLeft(Widget)
        end
        local ParentSize = UIUtil.GetWidgetSize(ParentView)
        UIUtil.CanvasSlotSetSize(self, UE.FVector2D(ParentSize.X, ParentSize.Y))
        UIUtil.CanvasSlotSetAlignment(self, UE.FVector2D(0, 0))
    end
    UIUtil.CanvasSlotSetZOrder(self, WidgetZOrder + 1)
    UIUtil.CanvasSlotSetPosition(self, UE.FVector2D(Pos.X + Left, Pos.Y + Top))
end

--- 引导层倒计时定时器
function TutorialBaseView:OnTutorialTimer(Params)
    local Time = Params.Time
    local TutorialID = Params.TutorialID
    local TotalTime = self.TutorialTime

    if TotalTime >= Time then
        if self.TutorialTimerID ~= nil then
            self:UnRegisterTimer(self.TutorialTimerID)
            self.TutorialTimerID = nil
            self.TutorialTime = 0
        end

        _G.EventMgr:SendEvent(_G.EventID.TutorialTimerEnd, {TutorialID = TutorialID})
        return
    end

    TotalTime = TotalTime + 0.05
    self.TutorialTime = TotalTime
end

--- 监听移除界面
function TutorialBaseView:OnTutorialRemoveGuideView(Params)
    if Params.TutorialID == self.TutorialID then
        self:RemoveFromParent()
        UIViewMgr:RecycleView(self)
    end
end

function TutorialBaseView:RegisterTutorialEvent(HandleType)
    if HandleType == TutorialGameHandleType.PlayerMove then
        self:RegisterGameEvent(EventID.MajorFirstMove, self.OnHandleTutorialEvent)
    elseif HandleType == TutorialGameHandleType.CameraRotate then
        self:RegisterGameEvent(EventID.CameraManualRotate, self.OnHandleTutorialEvent)
    elseif HandleType == TutorialGameHandleType.CameraZoom then
        self:RegisterGameEvent(EventID.CameraManualZoom, self.OnHandleTutorialEvent)
    elseif HandleType == TutorialGameHandleType.Clicked then
    elseif HandleType == TutorialGameHandleType.MajorPlaySkill then
    elseif HandleType == TutorialGameHandleType.Pressed then
    elseif HandleType == TutorialGameHandleType.ItemClicked then
    end
end

function TutorialBaseView:OnHandleTutorialEvent()
    local Params = {}
    Params.TutorialID = self.TutorialID
    EventMgr:SendEvent(EventID.TutorialEnd, Params)
end

function TutorialBaseView:EndFuncCallback()
	TutorialUtil:HandleClickGuideWidget(self.TutorialID, self.Widget)
end

return TutorialBaseView