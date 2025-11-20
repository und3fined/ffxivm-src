local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local DateTimeTools = require("Common/DateTimeTools")
local FuncCfg = require("TableCfg/FuncCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local BonusStateBuffCfg = require("TableCfg/BonusStateBuffCfg")

local FuncType = ProtoRes.FuncType
local LSTR = _G.LSTR
local ItemTipsMealVM = LuaClass(UIViewModel)

function ItemTipsMealVM:Ctor()
    self.EffectText = nil
	self.IntroText = nil

    self.DurationText = nil
	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil
end

---UpdateVM
function ItemTipsMealVM:UpdateVM(Value)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    self.EffectText = ItemCfg:GetItemEffectDesc(ItemResID)
	self.IntroText = ItemCfg:GetItemDesc(ItemResID)

    local CfgFunc = FuncCfg:FindCfgByKey(Cfg.UseFunc) -- 物品功能
    if CfgFunc ~= nil then
        if CfgFunc.Func[1].Type == FuncType.OpBonusState then
            local OpStateCfg = BonusStateBuffCfg:FindCfgByKey(CfgFunc.Func[1].Value[1])
            if OpStateCfg ~= nil then
                local LiveTime = OpStateCfg.LiveTime or 0
                if LiveTime == 0 then
                    self.DurationText = LSTR(1020002)
                else
                    self.DurationText = _G.LocalizationUtil.GetCountdownTimeForSimpleTime(LiveTime, "")
                end
            end
        else
            self.DurationText = LSTR(1020031)
        end
    end

    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)
end

return ItemTipsMealVM