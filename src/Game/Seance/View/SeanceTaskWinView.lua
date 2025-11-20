---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-08-01 11:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local SeanceScratchTaskItemVM = require("Game/Seance/View/VM/SeanceScratchTaskItemVM")

local LSTR = _G.LSTR

---@class SeanceTaskWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field PopUpBG CommonPopUpBGView
---@field TableViewList UTableView
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SeanceTaskWinView = LuaClass(UIView, true)

function SeanceTaskWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CommSidebarFrameS_UIBP = nil
    --self.PopUpBG = nil
    --self.TableViewList = nil
    --self.TextTime = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SeanceTaskWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommSidebarFrameS_UIBP)
    self:AddSubView(self.PopUpBG)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SeanceTaskWinView:OnInit()
    self.TaskVMList = UIBindableList.New(SeanceScratchTaskItemVM)
    self.AdapterTableViewGetTask = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, false)
end

function SeanceTaskWinView:OnDestroy()
end

function SeanceTaskWinView:OnShow()
    local StartTimeStr = TimeUtil.GetTimeFormat("%m/%d", self.Params.StartTimeStamp)
    local EndTimeStr = TimeUtil.GetTimeFormat("%m/%d", self.Params.EndTimeStamp)
    self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(1720003))
    local DateTimeStr = (LSTR(1720004) .. StartTimeStr .. " - " .. EndTimeStr)
    self.TextTime:SetText(DateTimeStr)
    self:UpdateTask(self.Params.DataList)
end

-- 更新任务数据
function SeanceTaskWinView:UpdateTask(InData)
    -- 这里刷新一下任务
    local DataList = InData
    self.TaskVMList:UpdateByValues(DataList)
    self.AdapterTableViewGetTask:UpdateAll(self.TaskVMList)
end

function SeanceTaskWinView:OnHide()
end

function SeanceTaskWinView:OnRegisterUIEvent()
end

function SeanceTaskWinView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnOpsActivityUpdate)
end

function SeanceTaskWinView:OnOpsActivityUpdate()
    self:UpdateTask(self.Params.DataList)
end

function SeanceTaskWinView:OnRegisterBinder()
end

function SeanceTaskWinView:UpdateInfo(InData)
    self:UpdateTask(InData.DataList)
end

return SeanceTaskWinView
