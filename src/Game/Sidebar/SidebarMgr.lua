---
--- Author: xingcaicao
--- DateTime: 2023-06-30 19:58:01
--- Description: 侧边栏
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarVM = require("Game/Sidebar/VM/SidebarVM")
local TimeUtil = require("Utils/TimeUtil")
local SidebarCfg = require("TableCfg/SidebarCfg")

local FLOG_WARNING = _G.FLOG_WARNING
local DetailViewIDMap = SidebarDefine.DetailViewIDMap

local SidebarMgr = LuaClass(MgrBase)

function SidebarMgr:OnInit()
	self.TimerID = nil
end

function SidebarMgr:OnBegin()

end

function SidebarMgr:OnEnd()

end

function SidebarMgr:OnShutdown()
	self.TimerID = nil
end

function SidebarMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
    self:RegisterGameEvent(EventID.HideUI, self.OnGameEventHideUI)
end

function SidebarMgr:OnGameEventPWorldEnter( )
    local bOpenSidebarMain = true
    local View = UIViewMgr:FindVisibleView(UIViewID.PWorldVoteBest)
    if View and View.Params then
       local TeamDefine = require("Game/Team/TeamDefine") 
       if self:GetSidebarItemVM(SidebarDefine.SidebarType.PWorldQuestMVP) and View.Params.ShowType == TeamDefine.VoteType.BEST_PLAYER then
            bOpenSidebarMain = false
       end
    end
    
    if bOpenSidebarMain then
        self:TryOpenSidebarMainWin()
    end
end

function SidebarMgr:OnGameEventHideUI( ViewID )
    if ViewID and DetailViewIDMap[ViewID] then
        self:TryOpenSidebarMainWin()
    end
end

function SidebarMgr:OnTimer()
    local ItemVMList = SidebarVM.SidebarItemVMList
    if nil == ItemVMList or ItemVMList:Length() <= 0 then
        return
    end

    local CurTime = TimeUtil.GetServerTime()
    local Items = ItemVMList:GetItems()
    local ItemsToRemove = {}

    for _, v in ipairs(Items) do
        local StartTime = v.StartTime 
        local CountDown = v.CountDown
        if StartTime and CountDown and CountDown > 0 then
            if CurTime >= (StartTime + CountDown) then
                if not v.bNotNotifyTimeout then
                    EventMgr:SendEvent(EventID.SidebarItemTimeOut, v.Type, v.TransData)
                end
                if v.bTimeoutAutoRemove then
                    table.insert(ItemsToRemove, v)
                end
            end
        end
    end


    for _, v in  ipairs(ItemsToRemove) do
        self:RemoveSidebarItem(v.Type)
    end
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---添加侧边栏项 
---@param Type SidebarType @侧边栏类型
---@param StartTime number @展示开始时间，单位秒，默认 0
---@param CountDown number @倒计时，单位秒，nil 或小于0时，使用 C侧边栏表.xlsx 中的ShowTime字段值
---@param TransData table @透传数据
---@param IsTryOpenWin boolean @是否尝试打开侧边栏界面
---@param Tips string @提示信息，默认 ""
---@param LoopAnimName string @待循环播放的动效名
---@param Desc string 第二行描述文本，默认""
function SidebarMgr:AddSidebarItem( Type, StartTime, CountDown, TransData, IsTryOpenWin, Tips, LoopAnimName, Desc )
    local Item = SidebarVM:AddItem(Type, StartTime or 0, CountDown or 0, TransData, Tips or "", LoopAnimName, Desc)

    local ItemNum = SidebarVM.ItemNum
    if ItemNum and ItemNum > 0 and nil == self.TimerID then
        self.TimerID = self:RegisterTimer(self.OnTimer, 0, 0.3, 0)
    end

    --打开侧边栏
    if IsTryOpenWin ~= false and ItemNum == 1 then
        self:TryOpenSidebarMainWin()
    end

    return Item
end

---添加侧边栏项 (新)
---@param Params SidebarItemParam
function SidebarMgr:AddOrUpdateSidebarItem(Params)
    local Item = self:GetSidebarItemVM(Params.Type)
    if Item == nil then
       Item = self:AddSidebarItem(Params.Type,Params.StartTime, Params.CountDown, Params.TransData, false, Params.Tips, Params.LoopAnimName, Params.Desc) 
    else
        Item:UpdateVM(Params)
    end

    Item:SetTimeoutAutoRemove(Params.bTimeoutAutoRemove)
    Item:SetNotNotifyTimeout(Params.bNotNotifyTimeout)

    if Params.IsTryOpenWin then
       self:TryOpenSidebarMainWin() 
    end

    return Item
end

--删除侧边栏项
---@param Type SidebarType @侧边栏类型
function SidebarMgr:RemoveSidebarItem( Type )
    SidebarVM:RemoveItem(Type)

    local ItemNum = SidebarVM.ItemNum
    if ItemNum and ItemNum <= 0 then
        UIViewMgr:HideView(UIViewID.SidebarMain)

        if self.TimerID then
            self:UnRegisterTimer(self.TimerID)
            self.TimerID = nil
        end
    end

    EventMgr:SendEvent(EventID.SidebarRemoveItem, Type)
end

---获取侧边栏项VM
---@param Type SidebarType @侧边栏类型
---@return table SidebarItemVM @查询类型的侧边栏项VM
function SidebarMgr:GetSidebarItemVM( Type )
    local Ret = SidebarVM:GetItem(Type)
    return Ret
end

--根据指定参数删除侧边栏项
---@param Param  侧边栏透传参数
---@param ParamName string @侧边栏透传参数名
function SidebarMgr:RemoveSidebarItemByParam( Param, ParamName)
    SidebarVM:RemoveItemByParam(Param, ParamName)

    local ItemNum = SidebarVM.ItemNum
    if ItemNum and ItemNum <= 0 then
        UIViewMgr:HideView(UIViewID.SidebarMain)

        if self.TimerID then
            self:UnRegisterTimer(self.TimerID)
            self.TimerID = nil
        end
    end

    EventMgr:SendEvent(EventID.SidebarRemoveItemByParam, Param, ParamName)
end

--删除所有同类型侧边栏项
---@param Type SidebarType @侧边栏类型
function SidebarMgr:RemoveSidebarAllItem( Type )
    SidebarVM:RemoveAllItem(Type)

    local ItemNum = SidebarVM.ItemNum
    if ItemNum and ItemNum <= 0 then
        UIViewMgr:HideView(UIViewID.SidebarMain)

        if self.TimerID then
            self:UnRegisterTimer(self.TimerID)
            self.TimerID = nil
        end
    end

    EventMgr:SendEvent(EventID.SidebarRemoveItem, Type)
end

---尝试打开侧边栏主界面
function SidebarMgr:TryOpenSidebarMainWin( )
    if (SidebarVM.ItemNum or 0) <= 0 or UIViewMgr:IsViewVisible(UIViewID.SidebarMain) then
        return
    end

    for VID in pairs(DetailViewIDMap) do
        if UIViewMgr:IsViewVisible(VID) then
            return
        end
    end

    UIViewMgr:ShowView(UIViewID.SidebarMain)
end

---获取配表展示时间
---@param Type SidebarType @侧边栏类型
function SidebarMgr:GetShowTimeByType(Type)
	local Cfg = SidebarCfg:FindCfgByKey(Type)
    if Cfg then
        return Cfg.ShowTime
    end
end

--- 显示通用侧边栏界面
---@param Params table @透传参数
function SidebarMgr:ShowCommonSidebarWin(Params)
    if nil == Params then
        return
    end

	local StartTime = Params.StartTime or 0
	local CountDown = Params.CountDown or 0
    local CurTime = TimeUtil.GetServerTime()
	if (CurTime - StartTime) >= CountDown then
		FLOG_WARNING("[SidebarMgr] ShowCommonSidebarWin, the countdown has ended.")
        return
    end

    UIViewMgr:ShowView(UIViewID.SidebarCommon, Params)
end

---显示私聊侧边栏界面
---@param Params table @透传参数
function SidebarMgr:ShowPrivateChatSidebarWin(Params)
    if nil == Params then
        return
    end

	local StartTime = Params.StartTime or 0
	local CountDown = Params.CountDown or 0
    local CurTime = TimeUtil.GetServerTime()
	if (CurTime - StartTime) >= CountDown then
		FLOG_WARNING("[SidebarMgr] ShowPrivateChatSidebarWin, the countdown has ended.")
        return
    end

    UIViewMgr:ShowView(UIViewID.SidebarPrivateChat, Params)
end

return SidebarMgr