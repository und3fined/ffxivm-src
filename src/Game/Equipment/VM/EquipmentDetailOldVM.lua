local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local EquipmentMsgItemVM = require("Game/Equipment/VM/EquipmentMainVM")
local EquipmentAttrItemVM = require("Game/Equipment/VM/EquipmentAttrItemVM")
local EquipmentMoreFilterItemVM = require("Game/Equipment/VM/EquipmentMoreFilterItemVM")
local MagicsparInlayStatusItemVM = require("Game/Magicspar/VM/MagicsparInlayStatusItemVM")

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemDBCfg = require("TableCfg/ItemCfg")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")

local EquipmentMgr = _G.EquipmentMgr

local LSTR = _G.LSTR

---@class EquipmentDetailVM : UIViewModel
local EquipmentDetailVM = LuaClass(UIViewModel)

function EquipmentDetailVM:Ctor()
    self.ResID = nil
    self.GID = nil
    self.EquipmentName = ""
    self.EquipmentTypeName = ""
    self.ItemLevel = 0
    self.lstEquipmentAttrItemVM = {}
    self.bEquiped = false   --GID对应的装备是否已装备
    self.RightBtnText = ""
    self.Part = nil
    self.bCanEquip = true
    self.CompareLevel = 0   --和已装备的部位Level的对比值
    self.PVPText = nil
    self.IsBind = false     --是否绑定
    self.IsOnly = false     --是否唯一
    self.lstEquipmentMoreFilterItemVM = nil
	self.bIsMajor = true
	self.bIsWeapon = false
    self.ProfText = nil
    self.Grade = nil
    self.GradeColor = "FFFFFFFF"
    self.lstAttrMsg = nil
    self.bHasWeaponArmRatio = false
    self.lstMagicsparInlayStatusItemVM = nil
    self.bHasMagicspar = true       --该装备是否已经镶嵌魔晶石
    self.bCanInlayMagicspar = true
	self.bIsMasterHand = false
	self.bEnableRightBtn = true
	self.bDetailUpdated = false
end

function EquipmentDetailVM:UpdateMagicsparInfo(InItem)
    local MagicsparInlayCfg = MagicsparInlayCfg:FindCfgByPart(self.Part)
    self.bHasMagicspar = false
    self.bCanInlayMagicspar = true
    if MagicsparInlayCfg == nil or MagicsparInlayCfg.NomalCount + MagicsparInlayCfg.BanCount == 0 then
        self.lstMagicsparInlayStatusItemVM = nil
        self.bCanInlayMagicspar = false
        return
    end

    local Item = nil == InItem and EquipmentMgr:GetItemByGID(self.GID) or InItem
    local GemInfo = Item.Attr.Equip.GemInfo.CarryList
    local iCount = MagicsparInlayCfg.NomalCount + MagicsparInlayCfg.BanCount
    local lst = {}
    for i = 1, iCount do
        local magicspar_hole = MagicsparInlayCfg.Hole[i]
        local ResID = GemInfo[i]

        local ViewModel = MagicsparInlayStatusItemVM.New()
        ViewModel:InitItem(ResID, i, magicspar_hole.Type == ProtoCommon.hole_type.HOLE_TYPE_NORMAL)
        lst[#lst + 1] = ViewModel

        if ResID ~= nil then
            self.bHasMagicspar = true
        end
    end
    self.lstMagicsparInlayStatusItemVM = lst
end

function EquipmentDetailVM:GenMoreBtnList()
    if self.lstEquipmentMoreFilterItemVM ~= nil then
        return
    end
    
    local lstEquipmentMoreFilterItemVM = {}
    lstEquipmentMoreFilterItemVM[1] = EquipmentMoreFilterItemVM.New()
    lstEquipmentMoreFilterItemVM[1].Text = _G.LSTR(1050146)

    lstEquipmentMoreFilterItemVM[2] = EquipmentMoreFilterItemVM.New()
    lstEquipmentMoreFilterItemVM[2].Text = _G.LSTR(1050019)

    self.lstEquipmentMoreFilterItemVM = lstEquipmentMoreFilterItemVM;
end

function EquipmentDetailVM:UpdateDetail()
    local Item = EquipmentMgr:GetItemByGID(self.GID)
    local IsBind = Item and Item.IsBind or self.IsBind
    self:SetEquipment(self.ResID, self.GID, self.bEquiped, IsBind, self.Part)
end

function EquipmentDetailVM:SetOtherEquipment(InItem, InPart, InProfLevel)
	self.bIsMajor = false
	self:SetEquipment(InItem.ResID, InItem.GID, true, InItem.IsBind, InPart, InProfLevel, InItem)
end

function EquipmentDetailVM:SetMajorEquipment(InResID, InGID, bEquiped, IsBind, InPart)
	self.bIsMajor = true
	self:SetEquipment(InResID, InGID, bEquiped, IsBind, InPart, MajorUtil.GetMajorLevel())
end

function EquipmentDetailVM:SetEquipment(InResID, InGID, bEquiped, IsBind, InPart, InProfLevel, InItem)
    local EquipmentCfg = EquipmentCfg:FindCfgByEquipID(InResID)
    local ItemCfg = ItemDBCfg:FindCfgByKey(InResID)

	if EquipmentCfg == nil or ItemCfg == nil then
		return
	end
    self.ResID = InResID
    --self.Part = EquipmentCfg.Part
    self.EquipmentName = ItemDBCfg:GetItemName(InResID)
    self.GID = InGID
    self.IsBind = IsBind
    self.IsOnly = ItemCfg.IsUnique
    self.bCanEquip = true
	if self.bIsMajor then
		self.bCanEquip = EquipmentMgr:CanEquiped(InResID)
	end
	self.bIsMasterHand = InPart == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND

    if #ItemCfg.ProfLimit > 0 then
        self.ProfText = EquipmentMgr:GetProfName(ItemCfg.ProfLimit[1])
    else
		if ItemCfg.ClassLimit == 0 then
			self.ProfText = LSTR(1050075)
		else
        	self.ProfText = EquipmentMgr:GetProfClassName(ItemCfg.ClassLimit)
		end
    end
    self.Grade = ItemCfg.Grade
	if self.bIsMajor then
		InProfLevel = InProfLevel or MajorUtil.GetMajorLevel()
	end
	if nil ~= InProfLevel then
    	self.GradeColor = InProfLevel < ItemCfg.Grade and "B33939FF" or "FFFFFFFF"
	end

    local EquipmentTypeName = EquipmentMgr:GetEquipmentTypeName(EquipmentCfg.EquipmentType)
    self.EquipmentTypeName = EquipmentTypeName

    --该Part已装备的物品
    self.Part = InPart
    self.EquipedItemInPart = self.bIsMajor and EquipmentMgr:GetEquipedItemByPart(InPart) or InItem

    self:UpdateMagicsparInfo(InItem)

    ---属性
    local lstAttrMsg = {}
    do
        ---判断类型
        if EquipmentMgr:IsWeapon(EquipmentCfg.Part) and EquipmentCfg.ArmRatio > 0 then
            ---武器伤害倍率
            self.bHasWeaponArmRatio = true
            lstAttrMsg[#lstAttrMsg + 1] = string.format(LSTR(1050095), EquipmentCfg.ArmRatio/100.0)
        else
            self.bHasWeaponArmRatio = false
        end

        ---过滤+0的属性
        local lstAttr = {}
        for i = 1, #EquipmentCfg.Attr do
            local Attr = EquipmentCfg.Attr[i]
            if Attr.Value > 0 then
                lstAttr[#lstAttr + 1] = Attr
            end
        end

        for i = 1, #lstAttr do
            local Attr = lstAttr[i]
            lstAttrMsg[#lstAttrMsg + 1] = string.format("%s +%d", AttrDefCfg:GetAttrNameByID(Attr.Attr), Attr.Value)
        end
    end
    self.lstAttrMsg = lstAttrMsg

    local lstEquipmentAttrItemVM = {}
    ---制作&修理
    do
        local Item = self.bIsMajor and EquipmentMgr:GetItemByGID(InGID) or InItem
        --绿色"00FD2BFF" --红色f80003
        local EndureDeg = Item.Attr.Equip.EndureDeg / 100
        lstEquipmentAttrItemVM[1] = EquipmentAttrItemVM.New()
        lstEquipmentAttrItemVM[1].LeftText = LSTR(1050109)
        lstEquipmentAttrItemVM[1].LeftTextColor = EndureDeg <= 0 and "f80003ff" or "999999FF"
        lstEquipmentAttrItemVM[1].RightText = string.format("%.2f%%", EndureDeg)   --当前耐久度
        lstEquipmentAttrItemVM[1].RightTextColor = EndureDeg <= 0 and "f80003ff" or "999999FF"

        lstEquipmentAttrItemVM[2] = EquipmentAttrItemVM.New()
        lstEquipmentAttrItemVM[2].LeftText = LSTR(1050026)
        lstEquipmentAttrItemVM[2].RightText = string.format("%d", ItemCfg.RecoverNum)

        lstEquipmentAttrItemVM[3] = EquipmentAttrItemVM.New()
        lstEquipmentAttrItemVM[3].LeftText = LSTR(1050086)
        lstEquipmentAttrItemVM[3].RightText = LSTR(1050047)

    end
    self.lstEquipmentAttrItemVM = lstEquipmentAttrItemVM
    
    ---处理底部按钮数据
	if self.bIsMajor then
		if bEquiped then
			self.bEquiped = bEquiped
		else
			local Item = EquipmentMgr:GetEquipedItemByGID(InGID)
			self.bEquiped = Item and true or false
		end
	end

    if self:HasEquipedItem() then
        ---计算对比值
        local EquipedItemCfgInPart = ItemDBCfg:FindCfgByKey(self.EquipedItemInPart.ResID)
        if EquipedItemCfgInPart ~= nil then
            self.CompareLevel = ItemCfg.ItemLevel - EquipedItemCfgInPart.ItemLevel
        end
		local bIsSelectedEquip = self.EquipedItemInPart.GID == InGID
        self.RightBtnText = bIsSelectedEquip and LSTR(1050038) or LSTR(1050087)
		self.bEnableRightBtn = not (bIsSelectedEquip and self.bIsMasterHand) and self.bCanEquip -- 已穿戴的主手不可卸下
    else
        ---未装备的话，对比值=0
        self.CompareLevel = 0
        self.RightBtnText = LSTR(1050105)
		self.bEnableRightBtn = self.bCanEquip
    end
    self.ItemLevel = ItemCfg.ItemLevel

    -- 根据配置MateID判断是否支持魔晶石镶嵌
    --if EquipmentCfg.MateID > 0 then
        --self.bCanInlayMagicspar = false
    --end

	self.bDetailUpdated = true
end

--该部位是否有已经穿戴的装备
function EquipmentDetailVM:HasEquipedItem()
    return self.EquipedItemInPart ~= nil
end

--已经穿戴的装备是否镶嵌魔晶石
function EquipmentDetailVM:EquipedItemHasMagicsparInlayed()
    local CarryList = self.EquipedItemInPart.Attr.Equip.GemInfo.CarryList
    for _,_ in pairs(CarryList) do
        return true
    end
    return false
end

return EquipmentDetailVM