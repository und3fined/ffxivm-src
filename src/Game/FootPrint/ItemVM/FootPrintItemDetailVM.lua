--
-- Author: anypkvcai
-- Date: 2023-04-06 16:47
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FootPrintItemCfg = require("TableCfg/FootMarkRecordCfg")
local FootPrintTypeCfg = require("TableCfg/FootPrintTypeCfg")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local LSTR = _G.LSTR

---@class FootPrintItemDetailVM : UIViewModel
local FootPrintItemDetailVM = LuaClass(UIViewModel)

---Ctor
function FootPrintItemDetailVM:Ctor()
	self.Key = nil
    self.ItemID = 0
	self.ItemCompleteName = ""
    self.CompleteNum = 0
	self.Score = ""
	self.IsUnLock = false
    self.bComplete = false
    self.AccomplishTime = ""
end

function FootPrintItemDetailVM:IsEqualVM(Value)
	return false
end

---UpdateVM
---@param Value table
function FootPrintItemDetailVM:UpdateVM(Value)
    local Key = Value.Key
    local StringKey = Value.StrKey
	self.Key = Key
    local ItemID = Value.ItemID
    self.ItemID = ItemID
    local ItemCfg = FootPrintItemCfg:FindCfgByKey(ItemID)
    if not ItemCfg then
        return
    end
	
    local StringList = string.split(StringKey, "C")
    local CfgIndex = tonumber(StringList[#StringList])
    if not CfgIndex then
        return
    end
    local TargetsCfg = ItemCfg.Targets
    local TargetCfg = TargetsCfg[CfgIndex]
    if not TargetCfg then
        return
    end
    self.Score = tostring(TargetCfg.Score)

    local NumComplete = Value.NumComplete
    self.CompleteNum = NumComplete

    local CompleteNeedNum = Value.TargetNum
	
    local IsUnLock = false
    local UnlockPercents = ItemCfg.UnlockPercents
    if UnlockPercents then
        local ItemUnlockPercent = UnlockPercents[CfgIndex] or 0
        IsUnLock = (NumComplete / CompleteNeedNum) * 100 >= ItemUnlockPercent 
    end
 
    --local ValueText = string.format(ItemCfg.CountName, CompleteNeedNum)
    local DetailName = string.format(ItemCfg.DetailText, CompleteNeedNum)
    self.ItemCompleteName = IsUnLock and DetailName or "? ? ? ?"
	self.IsUnLock = IsUnLock

    local bComplete = NumComplete >= CompleteNeedNum
    self.bComplete = bComplete
    if bComplete then
        local CompleteTime = Value.AccomplishTime
        if CompleteTime and CompleteTime > 0 then
            local TimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d", CompleteTime)
            local TimeStrLocalLang = LocalizationUtil.GetTimeForFixedFormat(TimeStr)
            self.AccomplishTime = TimeStrLocalLang
        end
    end
end

function FootPrintItemDetailVM:GetKey()
	return self.Key
end

function FootPrintItemDetailVM:AdapterOnGetCanBeSelected()
	return false
end

function FootPrintItemDetailVM:AdapterOnGetWidgetIndex()
	return 1
end

function FootPrintItemDetailVM:AdapterOnGetIsCanExpand()
	return true
end

function FootPrintItemDetailVM:AdapterOnGetChildren()

end

function FootPrintItemDetailVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

return FootPrintItemDetailVM

