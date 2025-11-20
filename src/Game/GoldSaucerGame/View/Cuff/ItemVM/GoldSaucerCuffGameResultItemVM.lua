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
    -- 赐福显示
    self.bBless = false
    self.BlessTitle = "" -- 赐福条目文本
    self.BlessTitleIcon = "" --赐福标题Icon路径
    self.BlessBg = "" -- 赐福背景图片路径
    self.bShowNumOrCheckIcon = true -- 显示为交互数量文本还是是否达成图标
    self.CheckIconPath = "" -- CheckIcon路径
    self.GetRewardNumText = "" -- 条目获取奖励数量
    self.ScoreGotNumText = "" -- 获取货币奖励数量
    self.bPlayBlessSuccessAnim = false -- 是否播放赐福挑战成功动画
    self.bBigBless = false -- 是否为赐福模式（false 送福，true 赐福）
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
    self.bBless = Data.bBless
    self.BlessTitle = Data.BlessTitle
    self.BlessTitleIcon = Data.BlessTitleIcon
    self.BlessBg = Data.BlessBg
    self.bShowNumOrCheckIcon = Data.bShowNumOrCheckIcon
    self.CheckIconPath = Data.CheckIconPath
    self.GetRewardNumText = Data.GetRewardNumText
    self.ScoreGotNumText = Data.ScoreGotNumText
    self.bPlayBlessSuccessAnim = Data.bPlayBlessSuccessAnim
    self.bBigBless = Data.bBigBless
    -- if self:CheckNeedPlayAnim() then
    --     self.AnimNum = self.AnimNum + 1
    -- end

    _G.FLOG_INFO("GoldSaucerCuffGameResultItemVM:UpdateVM() VarName=%s, value=%s, record=%s", 
        self.VarName, tostring(self.Value), tostring(self.bIsNewRecord))
end

return GoldSaucerCuffGameResultItemVM