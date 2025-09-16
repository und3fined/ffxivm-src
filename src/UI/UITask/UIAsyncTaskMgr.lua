
---
--- Author:
--- DateTime:
--- Description: 协程
--- UIAsyncTaskMgr与SlicingMgr不同的是，前者确保每个task每次更新时至少被执行一次，后者按队列先后顺序执行
---                 


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local UIViewMgr

local FTickHelper

---@class UIAsyncTaskMgr : MgrBase
local UIAsyncTaskMgr = LuaClass(MgrBase)

local GlobalTaskID = 0
local FinishStatus = "dead"

local AsyncTaskList = {}
local RequireTaskList = {}
local RequireStopList = {}

local bTickEnable = false

function UIAsyncTaskMgr:OnInit()
    AsyncTaskList = {}
    RequireTaskList = {}
    RequireStopList = {}

    self.UIViewShowTaskID = {}
    self.UIViewHideTaskID = {}
end

function UIAsyncTaskMgr:OnBegin()
    UIViewMgr = _G.UIViewMgr
    FTickHelper = _G.UE.FTickHelper.GetInst()
    FTickHelper:SetTickDisable(self.TickTimerID)
    bTickEnable = false
end

function UIAsyncTaskMgr:OnEnd()

end

function UIAsyncTaskMgr:OnShutdown()
end

function UIAsyncTaskMgr.OnTick(DeltaTime)
    local _ <close> = CommonUtil.MakeProfileTag("UIAsyncTaskMgr.OnTick")
    local self = UIAsyncTaskMgr

    for i = #AsyncTaskList, 1, -1 do
        local Task = AsyncTaskList[i]
        if Task then
            local TaskID = Task.TaskID
            if not RequireStopList[TaskID] then
                local Co = Task.Co
                local Status, ErrorMsg = coroutine.resume(Co, table.unpack(Task.Params))
                if not Status then
                    xpcall(error, CommonUtil.XPCallLog, ErrorMsg)
                end
                if FinishStatus == coroutine.status(Co) then
                    RequireStopList[TaskID] = true
                end
            end

            if RequireStopList[TaskID] then
                table.remove(AsyncTaskList, i)
                RequireStopList[TaskID] = nil
            end
        end
    end

    table.move(RequireTaskList, 1, #RequireTaskList, #AsyncTaskList + 1, AsyncTaskList)
    RequireTaskList = {}

    if #AsyncTaskList == 0 then
        RequireStopList = {}
        FTickHelper:SetTickDisable(self.TickTimerID)
        bTickEnable = false
        self.UIViewShowTaskID = {}
        self.UIViewHideTaskID = {}
    end
end


function UIAsyncTaskMgr:RegisterTask(Co, ...)
    local _ <close> = CommonUtil.MakeProfileTag("UIAsyncTaskMgr.RegisterTask")
    GlobalTaskID = GlobalTaskID + 1

    table.insert(RequireTaskList, {TaskID = GlobalTaskID, Co = Co, Params = {...}})
    if bTickEnable == false then
        FTickHelper:SetTickEnable(self.TickTimerID)
        bTickEnable = true
    end
    
    return GlobalTaskID
end
 
function UIAsyncTaskMgr:UnRegisterTask(TaskID)
    if TaskID and TaskID > 0 then
        RequireStopList[TaskID] = true
    end
end

--与UIViewConfig 异步不同，该接口同步加载UIView，延迟执行ShowView逻辑
function UIAsyncTaskMgr:ShowViewAsync(ViewID, Params)
    local Co = coroutine.create(self.ShowViewInternal)
    local TaskID = self:RegisterTask(Co, self, ViewID, Params)
    self.UIViewShowTaskID[ViewID] = TaskID

    local HideTaskID = self.UIViewHideTaskID[ViewID]
    if HideTaskID then
        self:UnRegisterTask(HideTaskID)
        self.UIViewHideTaskID[ViewID] = nil
    end
    return TaskID
end

function UIAsyncTaskMgr:HideView(ViewID, bImmediatelyHide, Params)
    local ExistUIViewTaskID = self.UIViewShowTaskID[ViewID]
    if ExistUIViewTaskID then
        self:UnRegisterTask(ExistUIViewTaskID)
        self.UIViewShowTaskID[ViewID] = nil
    else
        UIViewMgr:HideView(ViewID, bImmediatelyHide, Params)
    end
end

function UIAsyncTaskMgr:HideViewAsync(ViewID, bImmediatelyHide, Params)
    local ExistUIViewTaskID = self.UIViewShowTaskID[ViewID]
    if ExistUIViewTaskID then
        self:UnRegisterTask(ExistUIViewTaskID)
        self.UIViewShowTaskID[ViewID] = nil
    else
        local Co = coroutine.create(self.HideViewInternal)
        local TaskID = self:RegisterTask(Co, self, ViewID, bImmediatelyHide, Params)
        self.UIViewHideTaskID[ViewID] = TaskID
    end
end

function UIAsyncTaskMgr:ShowViewInternal(ViewID, Params)
    UIViewMgr:ShowView(ViewID, Params)
    self.UIViewShowTaskID[ViewID] = nil
end

function UIAsyncTaskMgr:HideViewInternal(ViewID, bImmediatelyHide, Params)
    UIViewMgr:HideView(ViewID, bImmediatelyHide, Params)
    self.UIViewHideTaskID[ViewID] = nil
end

return UIAsyncTaskMgr