local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemDBCfg = require("TableCfg/ItemCfg")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
--local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")

--local ItemUtil = require("Utils/ItemUtil")

local EquipmentMgr = _G.EquipmentMgr

---@class MagicsparSwitchItemVM : UIViewModel
local MagicsparSwitchItemVM = LuaClass(UIViewModel)

function MagicsparSwitchItemVM:Ctor()
    self.bSelect = false
    self.ResID = nil
    self.GID = nil
    self.Name = nil
    self.Level = nil
    self.Part = nil
    self.bCanInlay = false
    self.bEquiped = false
    self.bHasMagicspar = false
end

function MagicsparSwitchItemVM:InitItem(InResID, InGID, InPart, bSelect)

    local ItemCfg = ItemDBCfg:FindCfgByKey(InResID)
    local EquipCfg = EquipmentCfg:FindCfgByEquipID(InResID)
    self.Name = ItemDBCfg:GetItemName(InResID)
    self.Level = ItemCfg ~=nil and ItemCfg.ItemLevel or nil

    self.Item = EquipmentMgr:GetItemByGID(InGID)
    if InPart then
        self.Part = InPart
    elseif (self.Item) then
        self.Part = self.Item.Attr.Equip.Part
    else
        self.Part = EquipCfg ~= nil and EquipCfg.Part or nil
    end
    if EquipCfg ~= nil then
		local MateID = EquipCfg.MateID
        self.bCanInlay = MateID > 0
	end

    self.bEquiped = InGID ~= nil and _G.EquipmentMgr:IsEquiped(InGID)
    self.ResID = InResID
    self.GID = InGID
    self.bSelect = bSelect
    local GIDItem = EquipmentMgr:GetItemByGID(InGID)
    if GIDItem ~= nil then
        local CarryList = GIDItem.Attr.Equip.GemInfo.CarryList
        if CarryList ~= nil and table.size(CarryList) > 0 then
            self.bHasMagicspar = true
        end
    end
end

function MagicsparSwitchItemVM:CheckCanSelect()
    if self.bSelect == false then
        if self.bEquiped == false then
           -- local View = UIViewMgr:ShowView(UIViewID.CommonTips)
            --View:ShowTips(_G.LSTR(1060044), nil, 1)
            MsgTipsUtil.ShowTips(_G.LSTR(1060044))
            return
         elseif self.bCanInlay == false then
            --local View = UIViewMgr:ShowView(UIViewID.CommonTips)
            --View:ShowTips(_G.LSTR(1060045), nil, 1)
            MsgTipsUtil.ShowTips(_G.LSTR(1060045))
            return
         end
         local EventParams = {GID = self.GID, ResID = self.ResID, Part = self.Part}
         _G.EventMgr:SendEvent(EventID.MagicsparSwitchEquip, EventParams)
         self.bSelect = true
    end
end

function MagicsparSwitchItemVM:OnSelectedChange(bSelect)
    -- if bSelect == self.bSelect then return end
    -- if bSelect then
    --    if self.bCanInlay == false then
    --       local View = UIViewMgr:ShowView(UIViewID.CommonTips)
	-- 	  View:ShowTips(_G.LSTR(1060045), nil, 1)
    --       return
    --    elseif self.bEquiped == false then
    --       local View = UIViewMgr:ShowView(UIViewID.CommonTips)
    --       View:ShowTips(_G.LSTR(1060044), nil, 1)
    --       return
    --    end
    --    local EventParams = {GID = self.GID, ResID = self.ResID, Part = self.Part}
    --    _G.EventMgr:SendEvent(EventID.MagicsparSwitchEquip, EventParams)
    -- end
    self.bSelect = bSelect
end

return MagicsparSwitchItemVM