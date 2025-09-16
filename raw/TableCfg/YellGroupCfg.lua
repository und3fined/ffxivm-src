-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class YellGroupCfg : CfgBase
local YellGroupCfg = {
	TableName = "c_yellGroup_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(YellGroupCfg, { __index = CfgBase })

YellGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function YellGroupCfg:FindAllIDsByGroupID(GroupID)
    local YellGroup = self:FindCfgByKey(GroupID)
    if YellGroup == nil then
        return
    end
    local DisplayMode = YellGroup["DisplayMode"]
    local YellIDList = {}
    local YellID = YellGroup["YellID"]
    local Weight1 = YellGroup["Weight1"]

    local YellID2 = YellGroup["YellID2"]
    local Weight2 = Weight1 + YellGroup["Weight2"]

    local YellID3 = YellGroup["YellID3"]
    local Weight3 = Weight2 + YellGroup["Weight3"]

    local YellID4 = YellGroup["YellID4"]
    local Weight4 = Weight3 + YellGroup["Weight4"]

    local YellID5 = YellGroup["YellID5"]
    local Weight5 = Weight4 + YellGroup["Weight5"]
    if self:CanYellIDDisplay(DisplayMode, YellID, Weight1) then
        table.insert(YellIDList, {YellID = YellID, RandomWeight = Weight1})
    end
    if self:CanYellIDDisplay(DisplayMode, YellID2, Weight2) then
        table.insert(YellIDList, {YellID = YellID2, RandomWeight = Weight2})
    end
    if self:CanYellIDDisplay(DisplayMode, YellID3, Weight3) then
        table.insert(YellIDList, {YellID = YellID3, RandomWeight = Weight3})
    end
    if self:CanYellIDDisplay(DisplayMode, YellID4, Weight4) then
        table.insert(YellIDList, {YellID = YellID4, RandomWeight = Weight4})
    end
    if self:CanYellIDDisplay(DisplayMode, YellID5, Weight5) then
        table.insert(YellIDList, {YellID = YellID5, RandomWeight = Weight5})
    end

    if DisplayMode == 1 then
        return YellIDList
    elseif DisplayMode == 2 then
        return self:GetRandomIDFromList(YellIDList)
    end
end

function YellGroupCfg:CanYellIDDisplay(DisplayMode, YellID, Weight)
    if DisplayMode == 2 then
        return Weight > 0
    else
        return YellID > 0
    end
end

function YellGroupCfg:GetDisplayMode(GroupID)
    local YellGroup = self:FindCfgByKey(GroupID)
    if YellGroup == nil then
        return
    end
    return YellGroup["DisplayMode"]
end

--根据配置的权重随机一个ID
function YellGroupCfg:GetRandomIDFromList(YellIDList)
    if YellIDList == nil or next(YellIDList) == nil then
        return
    end
    local TotalWeight = YellIDList[#YellIDList].RandomWeight
    if TotalWeight == nil or TotalWeight <= 0 then
        return
    end
    local RandomID = {}
    local RandomValue = math.random(TotalWeight)
    for _, YellData in pairs(YellIDList) do
        if RandomValue <= YellData.RandomWeight then
            table.insert(RandomID, YellData)
            break
        end
    end
    return RandomID
end

return YellGroupCfg
