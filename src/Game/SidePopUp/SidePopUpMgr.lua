local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local SidepopupCfg = require("TableCfg/SidepopupCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local SidePopUpMgr = LuaClass(MgrBase)
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")

function SidePopUpMgr:OnInit()
    self.CurDisplayed = nil
    self.PauseCount = 0
    self.ToBeDisplayedList = {}
    self.PauseStorageList = {}
    self.TimerID = nil
end

function SidePopUpMgr:OnBegin()

end

function SidePopUpMgr:OnEnd()
    self.CurDisplayed = nil
    self.PauseCount = 0
    self.ToBeDisplayedList = {}
    self.PauseStorageList = {}
    self.TimerID = nil
end

function SidePopUpMgr:OnShutdown()
    self.TimerID = nil
end

function SidePopUpMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.NetStateUpdate, 				self.OnCombatStateUpdate)
    self:RegisterGameEvent(EventID.PWorldMapEnter, 				self.OnPWorldMapEnter)
end

function SidePopUpMgr:GetCurDisplayed()
    return self.CurDisplayed
end

function SidePopUpMgr:GetCurToBeDisplayed()
    local ToBeDisplayedNum = #self.ToBeDisplayedList 
    if ToBeDisplayedNum > 0 then
        return self.ToBeDisplayedList[1]
    end

    return nil
end

function SidePopUpMgr:UpdateUIShowTime()

    EventMgr:SendEvent(EventID.SidePopUpUpdateTime) --发送侧边弹出框时间事件

    local CurTime = TimeUtil.GetServerTime()
    if self.CurDisplayed and self.CurDisplayed.EndTime > 0 and self.CurDisplayed.EndTime <= CurTime then
        self:RemoveSidePopUp(self.CurDisplayed.UIID)
    end
end

function SidePopUpMgr:ForceRemoveCurDisplayed()
    if self.CurDisplayed ~= nil then
        local UIID = self.CurDisplayed.UIID
        UIViewMgr:HideView(UIID)
        self.CurDisplayed = nil
    end
end

function SidePopUpMgr:OnCombatStateUpdate(Params)
	if MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
		self:Pause(SidePopUpDefine.Pause_Type.CombatState ,Params.BoolParam1)
	end
end

function SidePopUpMgr:OnPWorldMapEnter(Params)
    self.PauseCount = 0
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---添加侧边弹出框
function SidePopUpMgr:AddSidePopUp(Type, UIID, Param, ShowConditional)
    --FLOG_INFO("SidePopUpMgr AddSidePopUp Type = %d, UIID = %d, addItem = %d", Type, UIID, Param and Param.ResID or 0)
    local Cfg = SidepopupCfg:FindCfgByKey(Type)
    if Cfg == nil then
        return false
    end

    if self.PauseCount > 0 then
        table.insert(self.PauseStorageList, {Type = Type, UIID = UIID, Param = Param, ShowConditional = ShowConditional})
        --FLOG_INFO("AddSidePopUp self.PauseCoun > 0 add PauseStorageList UIID = %d", UIID)
        return false
    end


    local CurDisplayed = self:GetCurDisplayed()
    if CurDisplayed then
        local CurCfg = SidepopupCfg:FindCfgByKey(CurDisplayed.Type)
        if Cfg.Priority <= CurCfg.Priority then
            table.insert(self.ToBeDisplayedList, {Type = Type, UIID = UIID, Param = Param, ShowConditional = ShowConditional})
            --FLOG_INFO("AddSidePopUp add ToBeDisplayedList Cfg.Priority <= CurCfg.Priority UIID = %d", UIID)
            return false
        end
    elseif self.ShowToBeDisplayedHandle then
        table.insert(self.ToBeDisplayedList, {Type = Type, UIID = UIID, Param = Param, ShowConditional = ShowConditional})
        --FLOG_INFO("AddSidePopUp add self.ShowToBeDisplayedHandle not nill ToBeDisplayedList UIID = %d", UIID)
        return false
    end

    --显示
    if ShowConditional and  ShowConditional(Param) == false then
        FLOG_INFO("SidePopUpMgr AddSidePopUp ShowConditional = false, Type = %d, UIID = %d, addItem = %d", Type, UIID, Param and Param.ResID or 0)
        return false
    end

    --有优先级更高的界面，则关闭当前显示的提示
    self:ForceRemoveCurDisplayed()

    local EndTime = 0
    if Cfg.ShowTime and Cfg.ShowTime > 0 then
        EndTime = TimeUtil.GetServerTime() + Cfg.ShowTime
    end

    self.CurDisplayed = {Type = Type, UIID = UIID, EndTime = EndTime, Param = Param, ShowConditional = ShowConditional}
    UIViewMgr:ShowView(UIID, Param)


    if  nil == self.TimerID then
        self.TimerID = self:RegisterTimer(self.UpdateUIShowTime, 0, 0.1, 0)
    end

    return true
end

function SidePopUpMgr:Pause(PauseType, bPause)
    if bPause == true then
        local mask = (1 << PauseType)
        self.PauseCount = self.PauseCount | mask
        
        if self.PauseCount > 0 then
            local CurDisplayed = self:GetCurDisplayed()
            if CurDisplayed then
                table.insert(self.PauseStorageList, {Type = CurDisplayed.Type, UIID = CurDisplayed.UIID, Param = CurDisplayed.Param, ShowConditional = CurDisplayed.ShowConditional})
                self:ForceRemoveCurDisplayed()
            end
        end
    else
        local mask = ~(1 << PauseType)
        self.PauseCount = self.PauseCount & mask
        
        if self.PauseCount < 1 then
            for _, Value in ipairs(self.PauseStorageList) do
                self:AddSidePopUp(Value.Type, Value.UIID, Value.Param, Value.ShowConditional)
            end
            self.PauseStorageList = {}
        end
    end
    FLOG_INFO("SidePopUpMgr :Pause end self.PauseCount =%d, PauseType = %d", self.PauseCount, PauseType or 0)
end


--删除侧边弹出框
function SidePopUpMgr:RemoveSidePopUp(UIID)
    local CurUIID = self.CurDisplayed and self.CurDisplayed.UIID or nil
    if CurUIID == UIID then
        self:ForceRemoveCurDisplayed()
    else
        return
    end
 
    if self.ShowToBeDisplayedHandle then
        return
    end

    self.ShowToBeDisplayedHandle = self:RegisterTimer(function()
        self:ShowToBeDisplayed()
    end, 0.2, 0, 1)
   
end

function SidePopUpMgr:RemoveToBeDisplayed(UIID)
    local Num = #self.ToBeDisplayedList
    for i=Num, 1, -1 do
        local ToBeDisplayed = self.ToBeDisplayedList[i]
        if ToBeDisplayed.UIID == UIID then
            table.remove(self.ToBeDisplayedList, i)
        end
    end
end

function SidePopUpMgr:ShowToBeDisplayed()
    self:UnRegisterTimer(self.ShowToBeDisplayedHandle)
    self.ShowToBeDisplayedHandle = nil
     --没有任何需要显示的弹窗则关闭定时器
     if #self.ToBeDisplayedList == 0 then
        if self.TimerID then
            self:UnRegisterTimer(self.TimerID)
            self.TimerID = nil
        end
        return
    end

    table.sort(self.ToBeDisplayedList, function(A, B) 
        local LeftCfg = SidepopupCfg:FindCfgByKey(A.Type)
        local RightCfg = SidepopupCfg:FindCfgByKey(B.Type)
        if RightCfg == nil then
            return true
        end

        if LeftCfg == nil then
            return false
        end

        return LeftCfg.Priority > RightCfg.Priority end)

    local CurToBeDisplayed = self:GetCurToBeDisplayed()
    while(CurToBeDisplayed)
    do
        --FLOG_INFO("RemoveSidePopUp CurToBeDisplayed addItem: %s", ItemUtil.GetItemName(CurToBeDisplayed.Param.ResID))
        if self:AddSidePopUp(CurToBeDisplayed.Type, CurToBeDisplayed.UIID, CurToBeDisplayed.Param, CurToBeDisplayed.ShowConditional) == true then
            table.remove(self.ToBeDisplayedList, 1)
            CurToBeDisplayed = nil
        else
            table.remove(self.ToBeDisplayedList, 1)
            CurToBeDisplayed = self:GetCurToBeDisplayed()
        end
    end

end


function SidePopUpMgr:GetDisplayedEndTime(Type)
    if self.CurDisplayed.Type == Type then
        return self.CurDisplayed.EndTime
    end

    return 0
end


return SidePopUpMgr