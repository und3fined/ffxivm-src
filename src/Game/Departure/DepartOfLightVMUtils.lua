---
--- Author: carl
--- DateTime: 2024-01-29 19:01
--- Description:
---
local UIUtil = require("Utils/UIUtil")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local DepartOfLightDescCfg = require("TableCfg/DepartOfLightDescCfg")
local DepartOfLightInteractCfg = require("TableCfg/DepartOfLightInteractCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local EActivityType = ProtoRes.Game.ActivityType

local DepartOfLightVMUtils = {}


---@type 获取光之启程活动ID列表
function DepartOfLightVMUtils.GetActivityIDList()
    local ListByIDs = {}
    local InActivityType = EActivityType.ActivityTypeLightStart
    local CfgList = ActivityCfg:FindLocalAllCfg(string.format("ActivityType = %d", InActivityType))
    if CfgList == nil or table.length(CfgList) <= 0 then
        return
    end

    for _, v in ipairs(CfgList) do
        table.insert(ListByIDs, v.ActivityID)
    end
    
    return ListByIDs
end

---@type 获取光之启程活动详情
function DepartOfLightVMUtils.GetActivityInfo(ActivityID)
    local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
    if Cfg == nil then
        return
    end

    local TempTask = {}
    TempTask.ActivityID = ActivityID
    TempTask.ActivityType = Cfg.ActivityType -- 活动类型
    TempTask.ClassifyID = Cfg.ClassifyID -- 页签ID
    TempTask.PageName = Cfg.PageName -- 页签名字
    TempTask.Title = Cfg.Title -- 标题
    TempTask.SubTitle = Cfg.SubTitle -- 副标题
    TempTask.Info = Cfg.Info or "已获得或解锁%s%s" -- 简介
    return TempTask   
end

---@type 是否光之启程活动
function DepartOfLightVMUtils.IsDepartureActivity(ActivityID)
    local ActivityInfo = DepartOfLightVMUtils.GetActivityInfo(ActivityID)
    if ActivityInfo == nil then
        return false
    end
    return ActivityInfo.ActivityType == EActivityType.ActivityTypeLightStart
end

---@type 获取光之启程活动节点详情
function DepartOfLightVMUtils.GetActivityNodeDetail(NodeID)
    local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
    if NodeCfg == nil then
        return
    end

    local NodeInfo = {}
    NodeInfo.ActivityID = NodeCfg.ActivityID
    NodeInfo.NodeID = NodeCfg.NodeID
    NodeInfo.NodeType = NodeCfg.NodeType -- 节点类型
    NodeInfo.NodeSort = NodeCfg.NodeSort -- 排序ID
    NodeInfo.NodeDesc = NodeCfg.NodeDesc -- 节点描述
    NodeInfo.Params = NodeCfg.Params -- 参数
    NodeInfo.Rewards = NodeCfg.Rewards -- 奖励
    NodeInfo.Target = NodeCfg.Target -- 目标值
    NodeInfo.JumpType = NodeCfg.JumpType -- 跳转类型
    NodeInfo.JumpParam = NodeCfg.JumpParam -- 跳转参数
    return NodeInfo   
end

---@type 获取活动玩法说明
function DepartOfLightVMUtils.GetActivityDescInfoByActivityID(ActivityID)
    if ActivityID == nil then
        return
    end
    local ActivityDescCfg = DepartOfLightDescCfg:FindCfg(string.format("ActivityID = %d", ActivityID))
    if ActivityDescCfg == nil then
        return
    end
    return DepartOfLightVMUtils.GetActivityDescInfoByGameID(ActivityDescCfg.ID)
end

---@type 获取活动玩法说明
function DepartOfLightVMUtils.GetActivityDescInfoByGameID(GameID)
    local ActivityDescCfg = DepartOfLightDescCfg:FindCfgByKey(GameID)
    if ActivityDescCfg == nil then
        return
    end

    local Info = {
        GameID = ActivityDescCfg.ID or 0,
        ModuleID = ActivityDescCfg.ModuleID,
        ActivityID = ActivityDescCfg.ActivityID or 0,
        MaxTarget = ActivityDescCfg.MaxTarget or 1,
        NodeDescLocked = ActivityDescCfg.NodeDescLocked or "",
        NodeDescUnlock = ActivityDescCfg.NodeDescUnlock or "",
        DescList = {},
    }
    local DescList = ActivityDescCfg.DescList
    if DescList then
        for _, ActivityDesc in ipairs(DescList) do
            local DescInfo = {
                Title = ActivityDesc.Title, -- 标题
                Content = ActivityDesc.Content, -- 介绍文本
                IconPath = ActivityDesc.Icon, -- 配图
                Points = ActivityDesc.Points, -- 兴趣点
                
            }
            if not string.isnilorempty(DescInfo.Title) and not string.isnilorempty(DescInfo.IconPath) then
                table.insert(Info.DescList, DescInfo)
            end
        end
    end

    return Info
end

---@type 获取活动互动玩法信息
function DepartOfLightVMUtils.GetInteractInfoByActivityID(ActivityID)
    local InteractInfoCfg = DepartOfLightInteractCfg:FindCfgByKey(ActivityID)
    if InteractInfoCfg == nil then
        return
    end

    local DescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(ActivityID)
    local Info = {
        ModuleID = DescInfo and DescInfo.ModuleID or 0,
        InteractiveDelay = InteractInfoCfg.InteractiveDelay, -- 显示交互延迟
        AutoSwitchInterval = InteractInfoCfg.AutoSwitchInterval, --自动切换交互内容间隔时长
        InteractList = {}, -- 交互信息列表（图片与对应权重）{Icon, Weight}
    }

    local InteractListTemp = InteractInfoCfg.InteractList
    if InteractListTemp then
        for _, Interact in ipairs(InteractListTemp) do
            local InteractInfo = {
                IconPaths = Interact.Icons, -- 交互图片
                Weight = Interact.Weight, -- 对应权重
            }
  
            if InteractInfo.IconPaths and #InteractInfo.IconPaths > 0 then
                table.insert(Info.InteractList, InteractInfo)
            end
        end
    end
    return Info
end

---@type 获取活动高光说明文本
function DepartOfLightVMUtils.GetActivityHighLightDesc(GameID)
    local ActivityDescCfg = DepartOfLightDescCfg:FindCfgByKey(GameID)
    if ActivityDescCfg == nil then
        return
    end

    return ActivityDescCfg.HighLightDesc
end

---@type 获取活动玩法BG
function DepartOfLightVMUtils.GetActivityBG(GameID)
    local ActivityDescCfg = DepartOfLightDescCfg:FindCfgByKey(GameID)
    if ActivityDescCfg == nil then
        return
    end

    local BGIcon = ActivityDescCfg.BG -- 背景图
    return BGIcon
end

---@type 获取活动第一个节点信息
function DepartOfLightVMUtils.GetFirstNodeInfo(ActivityID)
    local NodeCfg = ActivityNodeCfg:FindAllCfg(string.format("ActivityID = %d", ActivityID))
    if NodeCfg == nil then
        return
    end

    return DepartOfLightVMUtils.GetActivityNodeDetail(NodeCfg.NodeID)
end

---@type 获取启程玩法关闭延迟时长
function DepartOfLightVMUtils.GetDepartureCloseDelay()
    -- TODO 读表
    return  3600 * 24  -- 1天
end

---@type 获取随机交互图片
function DepartOfLightVMUtils.GetRandomInteract(InteractList, LastInteract)
    local InteractListTemp = InteractList
    if InteractListTemp == nil then
        return
    end
    
    local RandInterct = InteractListTemp[1]
    if #InteractListTemp <= 1 then
        return RandInterct
    end

    local IsSameWeight = true
    if LastInteract then
        -- 去除上次随机出来的
        for _, Interact in ipairs(InteractListTemp) do
            if Interact.Weight > 0 then
                IsSameWeight = false
            end
        end
    end

    local function RandomInteractWithWeight()
        local RandValue = math.random(10000)
        local AddValue = 0
        for Index, Interact in ipairs(InteractList) do
            AddValue = AddValue + Index * Interact.Weight
            if RandValue <= AddValue then
                RandInterct = Interact
                break
            end
        end
    end

    local function RandomInteract()
        local RandIndex = math.random(#InteractListTemp)
        RandInterct = InteractListTemp[RandIndex]
    end

    if IsSameWeight then
        if LastInteract then
            repeat
                RandomInteract()
            until RandInterct and RandInterct ~= LastInteract
        else
            RandomInteract()
        end
    else
        if LastInteract then
            repeat
                RandomInteractWithWeight()
            until RandInterct and RandInterct ~= LastInteract
        else
            RandomInteractWithWeight()
        end
    end

    return RandInterct
end

---@type 获取交互图片列表
-- function DepartOfLightVMUtils.GetInteractIconList(IconStr)
--     if string.isnilorempty(IconStr) then
--         return nil
--     end
--     local IconList = string.split(IconStr, ",")
--     return IconList
-- end

return DepartOfLightVMUtils
