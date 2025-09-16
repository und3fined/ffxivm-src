---
--- Author: star
--- DateTime: 2024-01-16 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local BodyGuardSquareAnimState = GoldSauserMainPanelDefine.BodyGuardSquareAnimState

---@class GoldSauserMainPanelBodyguardGameItemVM : UIViewModel
---@field ID number @条目ID
---@field DescriptionStr string @描述文本
---@field Num number @已完成进度
---@field MaxNum number @需要完成的数量
---@field RightWidgetIndex number @控件选择下标
local GoldSauserMainPanelBodyguardGameItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelBodyguardGameItemVM:Ctor()
    self.MiniGameType = nil
    self.MiniGameTime = nil
    self.PerActCountTimeText = "" --- 每轮出手计时显示
    self.RandomBambooWithSignIndex = nil --- 随机到的竹子刻痕方案Index
    self.SquareAnimState = BodyGuardSquareAnimState.Idle --- Square界面播放动画的状态
end

function GoldSauserMainPanelBodyguardGameItemVM:OnInit()
    self.MiniGameType = nil
    self.MiniGameTime = 0
end

function GoldSauserMainPanelBodyguardGameItemVM:SetInfo(Info)
    self.MiniGameType = Info.MiniGameType
    local StartTime = TimeUtil.GetServerTime()
    self.MiniGameTime = (StartTime + Info.MiniGameTime) * 1000
end

function GoldSauserMainPanelBodyguardGameItemVM:SetMiniGameType(InMiniGameType)
    self.MiniGameType = InMiniGameType
end

function GoldSauserMainPanelBodyguardGameItemVM:GetMiniGameType()
    return self.MiniGameType
end

function GoldSauserMainPanelBodyguardGameItemVM:OnReset()

end

function GoldSauserMainPanelBodyguardGameItemVM:OnBegin()

end

function GoldSauserMainPanelBodyguardGameItemVM:OnEnd()

end

function GoldSauserMainPanelBodyguardGameItemVM:OnShutdown()

end

function GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(AnimState)
    self.SquareAnimState = AnimState
end

return GoldSauserMainPanelBodyguardGameItemVM
