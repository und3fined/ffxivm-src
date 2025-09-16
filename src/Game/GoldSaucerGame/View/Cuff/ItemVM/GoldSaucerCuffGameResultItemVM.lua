---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
---@class GoldSaucerCuffGameResultItemVM : UIViewModel

local GoldSaucerCuffGameResultItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerCuffGameResultItemVM:Ctor()
    -- Main Part
    self.VarName = ""
    self.Value = ""
    self.bIsNewRecord = false
    self.bIsPerfectChallenge = false
    self.bShowUnfinished = false 
end

function GoldSaucerCuffGameResultItemVM:IsEqualVM(_)
    return false
end

function GoldSaucerCuffGameResultItemVM:UpdateVM(Data)    
    if Data == nil then
        return
    end
    self.VarName = Data.VarName
    self.Value = Data.Value
    self.bIsNewRecord = Data.bIsNewRecord
    self.bIsPerfectChallenge = Data.bIsNewRecord
    self.bShowUnfinished = Data.bShowUnfinished
    -- if self:CheckNeedPlayAnim() then
    --     self.AnimNum = self.AnimNum + 1
    -- end

    _G.FLOG_INFO("GoldSaucerCuffGameResultItemVM:UpdateVM() VarName=%s, value=%s, record=%s", 
        self.VarName, tostring(self.Value), tostring(self.bIsNewRecord))
end

return GoldSaucerCuffGameResultItemVM