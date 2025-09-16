local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")


local LSTR = _G.LSTR
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ItemTipsBaitVM = LuaClass(UIViewModel)

function ItemTipsBaitVM:Ctor()
    self.ProfDetailColor = nil
    self.ProfText = nil
    self.GradeText = nil

    self.IntroText = nil

	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil
end

---UpdateVM
function ItemTipsBaitVM:UpdateVM(Value, CanWearable, OtherProfWearable)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    if CanWearable then
        self.ProfDetailColor = "89bd88"
    else
        if OtherProfWearable then
            self.ProfDetailColor = "FFFFFF"
        else
            self.ProfDetailColor = "dc5868"
        end
    end

    if #Cfg.ProfLimit > 0 then
        self.ProfText = EquipmentMgr:GetProfName(Cfg.ProfLimit[1])
    else
		if Cfg.ClassLimit == 0 then
			self.ProfText = LSTR(1020004)
		else
            self.ProfText = EquipmentMgr:GetProfClassName(Cfg.ClassLimit)
		end
    end

    self.GradeText = string.format(LSTR(1020005), Cfg.Grade) 

    self.IntroText = ItemCfg:GetItemDesc(ItemResID)

    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)
end

return ItemTipsBaitVM