--@author daniel
--@date 2023-03-14

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoCS = require("Protocol/ProtoCS")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local RichTextUtil = require("Utils/RichTextUtil")
--local LogsTabs = ArmyDefine.LogsTabs
local ArmyMgr = require("Game/Army/ArmyMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local GroupStoreIconCfg = require("TableCfg/GroupStoreIconCfg")
local GroupLogCfg = require("TableCfg/GroupLogCfg")

local GroupLogType = ProtoCS.GroupLogType

---@class ArmyInfoTrendsItemVM : UIViewModel
---@field LogContent string @日志内容
---@field LogTime string @日志发布时间
---@field LogIcon string @日志Icon
local ArmyInfoTrendsItemVM = LuaClass(UIViewModel)

function ArmyInfoTrendsItemVM:Ctor()
    self.LogContent = nil
    self.LogTime = nil
    self.LogIcon = nil
    self.IsShowBG = nil
end

function ArmyInfoTrendsItemVM:OnInit()
    self.ID = 0
end

function ArmyInfoTrendsItemVM:OnBegin()
end

function ArmyInfoTrendsItemVM:OnEnd()
end

function ArmyInfoTrendsItemVM:OnShutdown()
    self.ID = nil
end

function ArmyInfoTrendsItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyInfoTrendsItemVM:UpdateVM(Data)
    self.ID = Data.ID
    self.LogTime = _G.ArmyMgr:GetPassTimeStr(Data.Time)
    --local LogsTab = LogsTabs[Data.Type]
    --if nil == LogsTab then
        --return
    --end
    local Type = Data.LogType
    self.IsCloseBG = Data.IsCloseBG
    self.LogIcon = ArmyMgr:GetArmyLogIconByLogType(Type)
    ArmyMgr:GetArmyLogTextByLogData(Data,function(Text)
        self.LogContent = Text
    end )
end

function ArmyInfoTrendsItemVM:AdapterOnGetCanBeSelected()
    return false
end

function ArmyInfoTrendsItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

return ArmyInfoTrendsItemVM