---
--- Author: star
--- DateTime: 2024-01-16 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")

---@class GoldSauserMainPanelTyphonGameItemVM : UIViewModel
---@field ID number @条目ID
---@field DescriptionStr string @描述文本
---@field Num number @已完成进度
---@field MaxNum number @需要完成的数量
---@field RightWidgetIndex number @控件选择下标
local GoldSauserMainPanelTyphonGameItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelTyphonGameItemVM:Ctor()
    self.MiniGameType = nil
    self.MiniGameTime = nil
end

function GoldSauserMainPanelTyphonGameItemVM:OnInit()
    self.MiniGameType = nil
    self.MiniGameTime = 0
end

function GoldSauserMainPanelTyphonGameItemVM:SetInfo(Info)
    self.MiniGameType = Info.MiniGameType
    local StartTime = TimeUtil.GetServerTime()
    self.MiniGameTime = (StartTime + Info.MiniGameTime) * 1000
end

function GoldSauserMainPanelTyphonGameItemVM:SetMiniGameType(InMiniGameType)
    self.MiniGameType = InMiniGameType
end

function GoldSauserMainPanelTyphonGameItemVM:GetMiniGameType()
    return self.MiniGameType
end

function GoldSauserMainPanelTyphonGameItemVM:OnReset()

end

function GoldSauserMainPanelTyphonGameItemVM:OnBegin()

end

function GoldSauserMainPanelTyphonGameItemVM:OnEnd()

end

function GoldSauserMainPanelTyphonGameItemVM:OnShutdown()

end


return GoldSauserMainPanelTyphonGameItemVM
