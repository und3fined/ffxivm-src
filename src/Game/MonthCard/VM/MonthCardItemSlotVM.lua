--
-- Author: ZhengJanChuan
-- Date: 2023-11-16 16:09
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local TradeMarketSystemParamCfg = require("TableCfg/TradeMarketSystemParamCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")
local ItemVM = require("Game/Item/ItemVM")

---@class MonthCardItemSlotVM : UIViewModel
local MonthCardItemSlotVM = LuaClass(UIViewModel)

---Ctor
function MonthCardItemSlotVM:Ctor()
    self.ItemVM = ItemVM.New()
    self.RichTextNum = 0
    self.RichTextNumVisible = true
end

function MonthCardItemSlotVM:OnInit()
end

function MonthCardItemSlotVM:OnBegin()
end

function MonthCardItemSlotVM:OnEnd()
end

function MonthCardItemSlotVM:OnShutdown()
end

function MonthCardItemSlotVM:UpdateVM(Value)
    local GainItem = ItemUtil.CreateItem(Value.ID, Value.RewardNum)
    self.ItemVM:UpdateVM(GainItem, {IsShowNum = true})
    -- self.RichTextNum = Value.RewardNum
    self.RichTextNumVisible = Value.ItemNumVisible
end

--要返回当前类
return MonthCardItemSlotVM