local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local DateTimeTools = require("Common/DateTimeTools")
local FuncCfg = require("TableCfg/FuncCfg")
local ProtoRes = require("Protocol/ProtoRes")
local BuffCfg = require("TableCfg/BuffCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local FuncType = ProtoRes.FuncType
local LSTR = _G.LSTR
local ItemTipsMedicineVM = LuaClass(UIViewModel)

function ItemTipsMedicineVM:Ctor()
    self.RecastTimeText = nil

	self.EffectText = nil
	self.IntroText = nil

    self.DurationText = nil
	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil
end

---UpdateVM
function ItemTipsMedicineVM:UpdateVM(Value)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end
    self.RecastTimeText = _G.LocalizationUtil.GetCountdownTimeForSimpleTime(Cfg.FreezeTime,"")

    self.EffectText = ItemCfg:GetItemEffectDesc(ItemResID)
	self.IntroText = ItemCfg:GetItemDesc(ItemResID)

    local CfgFunc = FuncCfg:FindCfgByKey(Cfg.UseFunc) -- 物品功能
    if CfgFunc ~= nil then
        if CfgFunc.Func[1].Type == FuncType.OpBuff then
            local OpBuffCfg = BuffCfg:FindCfgByKey(CfgFunc.Func[1].Value[1])
            if OpBuffCfg ~= nil then
                local LiveTime = OpBuffCfg.LiveTime
                if LiveTime == 0 then
                    self.DurationText = LSTR(1020002)
                else
                    self.DurationText = DateTimeTools.TimeFormat(LiveTime/1000, "smart-h-m-s", true)
                end
            end
        else
            self.DurationText = LSTR(1020031)
        end
    end

    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)

end

return ItemTipsMedicineVM