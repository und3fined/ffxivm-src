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

    for _, v in ipairs(Items) do
        local StartTime = v.StartTime 
        local CountDown = v.CountDown
        if StartTime and CountDown and CountDown > 0 then
            if CurTime >= (StartTime + CountDown) then
                EventMgr:SendEvent(EventID.SidebarItemTimeOut, v.Type, v.TransData)
            end
        end
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
function SidebarMgr:AddSidebarItem( Type, StartTime, CountDown, TransData, IsTryOpenWin, Tips, LoopAnimName )
    SidebarVM:AddItem(Type, StartTime or 0, CountDown or 0, TransData, Tips or "", LoopAnimName)

    local ItemNum = SidebarVM.ItemNum
    if ItemNum and ItemNum > 0 and nil == self.TimerID then
        self.TimerID = self:RegisterTimer(self.OnTimer, 0, 0.3, 0)
    end

    --打开侧边栏
    if IsTryOpenWin ~= false and ItemNum == 1 then
        self:TryOpenSidebarMainWin()
    end
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
    local IsShowing = function(VID)
        if not VID then
           return false
        end

        return UIViewMgr:IsViewVisible(VID) and (UIViewMgr:FindView(VID) or {}).IsHiding ~= true
    end

    if (SidebarVM.ItemNum or 0) <= 0 or IsShowing(UIViewID.SidebarMain) then
        return
    end

    for VID in pairs(DetailViewIDMap) do
        if IsShowing(VID) then
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

return SidebarMgr