---
--- Author: xingcaicao
--- DateTime: 2025-04-11 16:00:00
--- Description: 弹幕
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local DanmakuDefine = require("Game/Danmaku/DanmakuDefine")
local UIUtil = require("Utils/UIUtil")

local MaxCache = DanmakuDefine.MaxCache
local MsgStatus = DanmakuDefine.MsgStatus

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local TempPosition = _G.UE.FVector2D(0, 0)
local StrEmpty = ""
local Spacing = 100  -- 预留Spacing像素的间隔

---@class DanmakuVM : UIViewModel
local Class = LuaClass(UIViewModel)

---Ctor
function Class:Ctor()

end
	
function Class:OnInit()
    self:Reset()
end

function Class:OnBegin()

end

function Class:OnEnd()

end

function Class:OnShutdown()
    self:Reset()
end

function Class:Reset()
    self.LineConfig = {}
    self.ControlState = {}
    self.UIView = nil
    self.AreaWidth = 0
    self.MoveSpeed = 5 -- 每帧移动距离

    self:ClearAllMsg()
end

function Class:ClearAllMsg()
    self.MainPanelDanmakuVisible = false
    self.MsgQueue = {}
    self.ActiveMsgQueue = {} 

    for k, _ in pairs(self.ControlState) do
        self:DeactivateControl(k)
    end
end

--- 初始化控件状态
---@param View UIView
---@param LineConfig table @弹幕行配置, {{PosY = 0, Controls = {}} ...}
---@param AreaWidth number @弹幕区域宽度
function Class:InitControlsStatus(View, LineConfig, AreaWidth)
	if nil == View or not View:IsValid() then
		FLOG_ERROR("[DanmakuVM] InitControlsStatus, View is invalid")
		return false
	end

    local ControlState = self.ControlState

    for k, v in ipairs(LineConfig) do
        for _, ctrlName in ipairs(v.Controls) do
            ControlState[ctrlName] = {
                Line = k,
                IsActive = false,
                PositionX = nil,
                PositionY = v.PosY,
                MsgID = nil,
                Width = 0,
            }
        end
    end

    self.LineNum = #LineConfig
    self.UIView = View 
    self.LineConfig = LineConfig 

    local Width = math.ceil(AreaWidth)
    self.AreaWidth = Width

    return true
end

function Class:AddMessage(Text, MsgType)
    local MsgQueue = self.MsgQueue
    if nil == MsgQueue then
        return
    end

    local NewMsg = {
        ID = os.time() .. "_" .. math.random(1000),
        Text = Text,
        MsgType = MsgType,
        CtrlName = nil,
        Status = MsgStatus.Waiting,
    }

    -- 队列维护
    table.insert(MsgQueue, NewMsg)

    -- 检查上限
    local Size = #MsgQueue
    if Size > MaxCache then
        self:RemoveOldestInactiveMsg()
    end

    self.MainPanelDanmakuVisible = true
end

function Class:RemoveOldestInactiveMsg()
    local MsgQueue = self.MsgQueue
    if nil == MsgQueue then
        return
    end

    local RemoveCount = 0
    local MaxRemove = 5

    -- 移除最旧的MaxRemove数量的等待中的消息

    for i = #MsgQueue, 1, -1 do
        if RemoveCount >= MaxRemove then
            return
        end
        
        local Status = MsgQueue[i].Status
        if nil == Status or Status == MsgStatus.Waiting then
            table.remove(MsgQueue, i)
            RemoveCount = RemoveCount + 1
        end
    end
end

function Class:DeactivateControl(CtrlName)
    if string.isnilorempty(CtrlName) then
        return
    end

    local State = self.ControlState[CtrlName]
    if State then
        State.IsActive = false
        State.PositionX = nil
        State.MsgID = nil
        State.Width = 0
    end

    -- 控件状态
    local TextCtrl = self:GetTextCtrl(CtrlName)
    if TextCtrl ~= nil and TextCtrl:IsValid() then
        TextCtrl:SetText(StrEmpty)
        UIUtil.SetIsVisible(TextCtrl, false)
    end
end

function Class:GetTextCtrl(CtrlName)
    local View = self.UIView
    if View ~= nil then
        return View[CtrlName]
    end
end

local TextCtrlWidthChangedLine = {} 

function Class:Tick()
    -- 激活队列消息
    local WaitingStatus = MsgStatus.Waiting
    
    for _, v in ipairs(self.MsgQueue) do
        if v.Status == WaitingStatus then
            local Success = self:ActivateMessage(v)
            if Success then
                v.Status = MsgStatus.Displaying 
            end
        end
    end

    -- 更新位置并检测回收
    table.clear(TextCtrlWidthChangedLine)

    for _, v in ipairs(self.ActiveMsgQueue) do
        local Line = self:UpdateTextCtrlPostion(v) 
        if Line then
            TextCtrlWidthChangedLine[Line] = true
        end
    end


    for k, _ in pairs(TextCtrlWidthChangedLine) do
        self:AdjustTextCtrlPosition(k)
    end

    -- 清理已展示消息
    self:CleanDisplayedMessages()
end

function Class:ActivateMessage(Msg)
    local ID = Msg.ID
    if nil == ID then
        return false
    end

    -- 分配控件
    local CtrlName = Msg.CtrlName
    if string.isnilorempty(CtrlName) then
        CtrlName = self:AssignAvailableControl()
        if string.isnilorempty(CtrlName) then -- 无可用控件
            return false 
        end

        Msg.CtrlName = CtrlName
    end

    -- 激活显示
    local TextCtrl = self:GetTextCtrl(CtrlName)
    if nil == TextCtrl or not TextCtrl:IsValid() then
        FLOG_WARNING("[DanmakuVM] ActivateMessage, TextCtrl is invalid")
        return false
    end

    local State = self.ControlState[CtrlName]
    if nil == State then
        FLOG_WARNING("[DanmakuVM] ActivateMessage, control state is invalid, " .. tostring(CtrlName))
        return false
    end

    TextCtrl:SetText(Msg.Text)
    TempPosition.X = self.AreaWidth + 50 -- 挪到屏幕之外
    TempPosition.Y = State.PositionY or 0
    UIUtil.CanvasSlotSetPosition(TextCtrl, TempPosition)
    UIUtil.SetIsVisible(TextCtrl, true)

    -- 更新状态
    State.IsActive = true
    State.PositionX = nil 
    State.MsgID = ID 
    State.Width = 0

    table.insert(self.ActiveMsgQueue, Msg)

    return true
end

function Class:UpdateTextCtrlPostion(Msg)
    if nil == Msg then
        return
    end

    local MoveSpeed = self.MoveSpeed
    if nil == MoveSpeed or MoveSpeed <= 0 then
        return
    end

    local CtrlName = Msg.CtrlName 
    if nil == CtrlName then
        return
    end

    local ControlState = self.ControlState
    if nil == ControlState then
        return
    end

    local State = ControlState[CtrlName]
    if nil == State or not State.IsActive then
        return
    end

    local TextCtrl = self:GetTextCtrl(CtrlName)
    if nil == TextCtrl or not TextCtrl:IsValid() then
        return
    end

    local CurWidth = UIUtil.GetLocalSize(TextCtrl).X
    if CurWidth <= 0 then -- 控件大小还未刷新
        return
    end

    local CacheWidth = State.Width 
    if nil == CacheWidth or CacheWidth <= 0 then
        CacheWidth = CurWidth
    end

    State.Width = CurWidth

    local Line = State.Line
    local CurPosition = State.PositionX or self:GetTextCtrlStartX(Line)
    local X = CurPosition - MoveSpeed
    TempPosition.X = X
    TempPosition.Y = State.PositionY or 0

    UIUtil.CanvasSlotSetPosition(TextCtrl, TempPosition)
    State.PositionX = X

    if X < -CurWidth then
        self:DeactivateControl(CtrlName)
        Msg.Status = MsgStatus.Displayed 

    else
        if CurWidth ~= CacheWidth then -- 宽度有变化，需要调整行文本控件间距
            return Line
        end
    end
end

function Class:GetTextCtrlStartX(Line)
    -- 同一行最近的控件尾部X坐标
    local RecentX = 0 

    if nil == Line then
        Line = 1
    end

    for _, v in pairs(self.ControlState) do
        if v.Line == Line and v.IsActive then
            local X = v.PositionX or 0
            local Width = v.Width or 0
            if X > RecentX then
                RecentX = X + Width
            end
        end
    end

    local AreaWidth = self.AreaWidth or 0
    if RecentX < AreaWidth then
        RecentX = AreaWidth 

    else
        RecentX = RecentX + Spacing
    end

    return RecentX
end

local ActiveStates = {}

function Class:AdjustTextCtrlPosition(Line)
    local LineConfig = self.LineConfig
    if nil == LineConfig then
        return
    end

    local Controls = LineConfig[Line].Controls
    if table.is_nil_empty(Controls) then
        return
    end

    local ControlState = self.ControlState
    if table.is_nil_empty(ControlState) then
        return
    end

    table.clear(ActiveStates)

    for _, v in ipairs(Controls) do
        local State = ControlState[v]
        if nil ~= State and State.IsActive and State.PositionX then
            table.insert(ActiveStates, State)
        end
    end

    table.sort(ActiveStates, function(lhs, rhs)
        return lhs.PositionX < rhs.PositionX
    end)

    local EndPosX = nil 

    for _, v in ipairs(ActiveStates) do
        local PositionX = v.PositionX
        if EndPosX == nil then
            EndPosX = PositionX + v.Width + Spacing
        else
            if EndPosX > PositionX then
                -- print("Error: PositionX: " .. PositionX .. " EndPosX: " .. EndPosX)
                v.PositionX = EndPosX
                EndPosX = EndPosX + v.Width + Spacing
            end
        end
    end
end

function Class:AssignAvailableControl()
   local TempLine = nil 
   local CtrlName = nil

    -- 查找空闲控件，优先使用上层行控件

    for k, v in pairs(self.ControlState) do
        if not v.IsActive then
            local Line = v.Line
            if nil == TempLine or Line < TempLine then
                TempLine = Line
                CtrlName = k 
            end
        end
    end

    return CtrlName
end

function Class:CleanDisplayedMessages()
    -- 激活消息队列
    local ActiveMsgQueue = self.ActiveMsgQueue or {}

    for i = #ActiveMsgQueue, 1, -1 do
        local Msg = ActiveMsgQueue[i]
        if Msg and Msg.Status == MsgStatus.Displayed then
            table.remove(ActiveMsgQueue, i)
        end
    end

    -- 消息队列
    local MsgQueue = self.MsgQueue or {}

    for i = #MsgQueue, 1, -1 do
        local Msg = MsgQueue[i]
        if Msg.Status == MsgStatus.Displayed then
            table.remove(MsgQueue, i)
        end
    end

    if #MsgQueue <= 0 then
        self:ClearAllMsg()
    end
end

--- 移除等待中的消息
function Class:RemoveWaitingMsg(MsgType)
    local MsgQueue = self.MsgQueue or {}
    if #MsgQueue <= 0 then
        return
    end

    for i = #MsgQueue, 1, -1 do
        local Msg = MsgQueue[i]
        if Msg.Status == MsgStatus.Waiting and Msg.MsgType == MsgType then
            table.remove(MsgQueue, i)
        end
    end

    if #MsgQueue <= 0 then
        self:ClearAllMsg()
    end
end

function Class:UpdateMoveSpeed()
    local Rate = 240 -- 每秒移动240像素
    local TargetFrameRate = _G.SettingsMgr:GetMaxFPSValue()
    if TargetFrameRate <= 0 then
        FLOG_WARNING("[DanmakuVM] UpdateMoveSpeed, TargetFrameRate is invalid %s", TargetFrameRate)

        TargetFrameRate = 30 -- 默认30帧
    end

    self.MoveSpeed = math.ceil(Rate / TargetFrameRate)

    FLOG_INFO("[DanmakuVM] UpdateMoveSpeed, TargetFrameRate: %s, MoveSpeed: %s", TargetFrameRate, self.MoveSpeed)
end

return Class