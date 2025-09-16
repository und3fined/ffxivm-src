local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local BuddyMgr = require("Game/Buddy/BuddyMgr")
local BuddyFeedCfg = require("TableCfg/BuddyFeedCfg")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local ItemTipsBuddyVM = LuaClass(UIViewModel)

function ItemTipsBuddyVM:Ctor()
	self.IntroText = nil

	self.BuyPriceText = nil
	self.SellPriceText = nil
	self.BuyPriceIconVisible = nil
	self.SellPriceIconVisible = nil

	self.EffectText = nil
	self.BuffImg = nil
	self.BuffTitle = nil
end

---UpdateVM
function ItemTipsBuddyVM:UpdateVM(Value)
    local ItemResID = Value.ResID
	self.BuffTitle = ItemResID == BuddyMgr:GetBuddyFavFood()  and _G.LSTR(1020011) or _G.LSTR(1020012)
	
    local SearchConditions = string.format("ItemID = %d", ItemResID)
	local Cfg = BuddyFeedCfg:FindCfg(SearchConditions)
    if Cfg and #Cfg.Func > 1 and Cfg.Func[2] then
        if Cfg.Func[2].Type == ProtoRes.BuddyFuncType.BuddyFuncTypeBonusState and #Cfg.Func[2].Value > 1 then
            local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(Cfg.Func[2].Value[2])
            if StateShowCfg ~= nil then
                self.EffectText = string.format("%s,%s",StateShowCfg.EffectName, StateShowCfg.Desc)
                self.BuffImg = StateShowCfg.EffectIcon
            end
        end
    end

    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    self.IntroText = ItemCfg:GetItemDesc(ItemResID)

    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)

end

return ItemTipsBuddyVM