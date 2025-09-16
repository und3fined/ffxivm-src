--
-- Author: ZhengJianChuan
-- Date: 2024-06-19 18:11
-- Description: 委托任务交纳设置界面VM
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EToggleButtonState = _G.UE.EToggleButtonState

local LSTR

---@class LeveQuestPaySettingsWinVM : UIViewModel
local LeveQuestPaySettingsWinVM = LuaClass(UIViewModel)


---Ctor
function LeveQuestPaySettingsWinVM:Ctor()
    self.PaySingle = false
    self.PayMost = false
end

function LeveQuestPaySettingsWinVM:OnInit()
end

function LeveQuestPaySettingsWinVM:OnBegin()
end

function LeveQuestPaySettingsWinVM:OnEnd()
end

function LeveQuestPaySettingsWinVM:OnShutdown()
end

function LeveQuestPaySettingsWinVM:UpdateToggleState(PaySingleState, PayMostState)
    self.PaySingle = PaySingleState
    self.PayMost = PayMostState
end

--要返回当前类
return LeveQuestPaySettingsWinVM