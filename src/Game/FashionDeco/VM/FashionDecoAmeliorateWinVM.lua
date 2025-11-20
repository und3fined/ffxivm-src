local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoAmeliorateCfg = require("TableCfg/FashionDecoAmeliorateCfg")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local UIUtil = require("Utils/UIUtil")

---@class FashionDecoAmeliorateWinVM : UIViewModel
local FashionDecoAmeliorateWinVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR
local MsgTipsUtil = _G.MsgTipsUtil

function FashionDecoAmeliorateWinVM:Ctor()
    self.SelectAmeliorateWingId = 1 --选中的改良翅膀

    self.TextItemName1 = nil
    self.TextItemName2 = nil
    self.TextItemName3 = nil
    self.TextNumber = nil --材料数量比 10/30
    self.ImgItemIcon1 = nil --翅膀图标
    self.ImgItemIcon2 = nil --材料图标
    self.ItemIcon = nil --改良后翅膀图标
end

function FashionDecoAmeliorateWinVM:ClearData()
end

function FashionDecoAmeliorateWinVM:SetData(SelectWindId, LastUpgradeWingId)
    self.SelectAmeliorateWingId = SelectWindId

     --前置翅膀
     local DecorateCfg = FashionDecorateCfg:FindCfgByKey(LastUpgradeWingId) --时尚配饰表
     if DecorateCfg then
         self.ImgItemIcon1 = DecorateCfg.Icon --图标
         self.TextItemName1 = DecorateCfg.Name
     end

    local AmeliorateCfg = FashionDecoAmeliorateCfg:FindCfgByKey(self.SelectAmeliorateWingId)
    if AmeliorateCfg then
        --材料数量
        local BagItemNum = _G.BagMgr:GetItemNum(AmeliorateCfg.CostID)
		BagItemNum = math.clamp(BagItemNum, 0, AmeliorateCfg.CostNum)
        self.TextNumber = string.format("%s/%s", BagItemNum, AmeliorateCfg.CostNum)

        --材料图标
        local CostItemCfg = ItemCfg:FindCfgByKey(AmeliorateCfg.CostID)
        if nil ~= CostItemCfg then
            self.ImgItemIcon2 = UIUtil.GetIconPath(CostItemCfg.IconID)
        end

         --当前改良的翅膀
         local DecorateCfg = FashionDecorateCfg:FindCfgByKey(self.SelectAmeliorateWingId) --时尚配饰表
        if DecorateCfg then
            self.ItemIcon = DecorateCfg.Icon --图标
            self.TextItemName3 = DecorateCfg.Name
        end
    end
end

return FashionDecoAmeliorateWinVM