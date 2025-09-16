local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local SidepopupCfg = require("TableCfg/SidepopupCfg")
local TimeUtil = require("Utils/TimeUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemUtil = require("Utils/ItemUtil")

local SidePopUpMgr = _G.SidePopUpMgr
local UIType = ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE
---@class SidePopUpMainBagVM : UIViewModel
local SidePopUpMainBagVM = LuaClass(UIViewModel)

---Ctor
function SidePopUpMainBagVM:Ctor()
    self.CDProgressPercent = nil
    self.ItemName = nil
    self.bShowEquipInfo = nil
    self.bLock = nil
    self.PromoteValue = nil
    self.ActionName = nil
    self.CanntEquip = nil

    self.BagSlotVM = BagSlotVM.New()
end
	
function SidePopUpMainBagVM:OnInit()
end

function SidePopUpMainBagVM:OnBegin()

end

function SidePopUpMainBagVM:OnEnd()

end

function SidePopUpMainBagVM:OnShutdown()
end

function SidePopUpMainBagVM:UpdateVM(Item)
    if self.BagSlotVM ~= nil then
        self.BagSlotVM:UpdateVM(Item, {IsShowNum = false, IsShowNewFlag = false})
        self.ItemName = self.BagSlotVM.Name
    end

    self.bLock = Item.IsBind

    self:SetEquipInfo(Item)
    self.CDProgressPercent = 1
end

function SidePopUpMainBagVM:SetEquipInfo(Item)
    local ResID = Item.ResID
    self.bShowEquipInfo = ItemUtil.CheckIsEquipmentByResID(ResID)
    self.ActionName = _G.LSTR(1020076)
    if self.bShowEquipInfo then
        self.PromoteValue = _G.BagMgr:DiffQualityWithEquipment(ResID)
        self.ActionName = _G.LSTR(1020058)
        self:UpdateCanEquip(ResID)
    end
end

function SidePopUpMainBagVM:UpdateCDProgressPercent()
    local EndTime = SidePopUpMgr:GetDisplayedEndTime(UIType)
    local CDTime = SidepopupCfg:FindCfgByKey(UIType).ShowTime

    if CDTime == 0 or EndTime == 0 then
        return
    end

    self.CDProgressPercent = (EndTime - TimeUtil.GetServerTime())/CDTime
end

function SidePopUpMainBagVM:UpdateCanEquip(ResID)
    self.CanntEquip = _G.EquipmentMgr:CanEquiped(ResID) == false
end



return SidePopUpMainBagVM