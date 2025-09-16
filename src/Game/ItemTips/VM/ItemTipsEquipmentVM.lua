local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local LSTR = _G.LSTR
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local MajorUtil = require("Utils/MajorUtil")

local ItemTipsEquipmentVM = LuaClass(UIViewModel)

function ItemTipsEquipmentVM:Ctor()
    self.ProfDetailColor = nil
    self.ProfText = nil
    self.GradeText = nil

    --属性
    self.LongAttriNum = 2	--长文字属性
    self.LongAttriText1 = nil
	self.LongAttriValue1 = nil
	self.LongAttriText2 = nil
	self.LongAttriValue2 = nil

    self.ShortAttriNum = 4	--短文字属性
	self.ShortAttriText1 = nil
	self.ShortAttriValue1 = nil
	self.ShortAttriText2 = nil
	self.ShortAttriValue2 = nil
	self.ShortAttriText3 = nil
	self.ShortAttriValue3 = nil
	self.ShortAttriText4 = nil
	self.ShortAttriValue4 = nil

    self.LongAttriVisible1 = nil
    self.LongAttriVisible2 = nil
    self.ShortAttriVisible1 = nil
    self.ShortAttriVisible2 = nil
    self.ShortAttriVisible3 = nil
	self.ShortAttriVisible4 = nil

    --魔晶石数量
    self.MagicsparInlayNum = 5
    self.InlayMainPanelVisible = true
	self.InlayNameText1 = nil
	self.InlayNameText2 = nil
	self.InlayNameText3 = nil
	self.InlayNameText4 = nil
	self.InlayNameText5 = nil

    self.InlayNameColor1 = nil
	self.InlayNameColor2 = nil
	self.InlayNameColor3 = nil
	self.InlayNameColor4 = nil
	self.InlayNameColor5 = nil

    self.InlayAttriText1 = nil
	self.InlayAttriText2 = nil
	self.InlayAttriText3 = nil
	self.InlayAttriText4 = nil
	self.InlayAttriText5 = nil

    self.CanInlayVisible = nil
    self.InlayVisible = nil
    self.InlayDetailVisible = nil
    self.CantInlayVisible = nil

    --幻化染色
    self.ShadowNameText = nil
    self.DyeNameText = nil
    self.DyeTextVisible = nil
    self.DyeNameTextVisible = nil

    self.GlamoursText = nil
    self.EndureDegValue = nil
    self.EndureDegColor = "D5D5D5"
    self.EndureDiscountCondition = nil
    self.BuyPriceText = nil
    self.SellPriceText = nil
    self.MakerNameText = nil
	self.MakerNameVisible = nil

    self.BuyPriceIconVisible = false
    self.SellPriceIconVisible = false

	--底部按钮
	self.Part = -1
	self.bShowPanelMore = false
	self.RightBtnText = ""
	self.bRightBtnEnabled = false

    self.IsCanImproved = false

    self.ImgXColor = "89bd88"
    self.ImgXVisible = true
    
end

---UpdateVM
function ItemTipsEquipmentVM:UpdateVM(Value, CanWearable, OtherProfWearable)
    local ItemResID = Value.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end
    self:UpdateProfDetail(Cfg, CanWearable, OtherProfWearable)

    local ECfg = EquipmentCfg:FindCfgByKey(ItemResID)
    if ECfg == nil then
		return
	end
    self:UpdateAttriInfo(ECfg)

    --魔晶石
    self.Item = Value
    self:UpdateMagicsparInfo(ECfg)

    if self.Item and self.Item.Attr and self.Item.Attr.Equip then
        local EndureDeg = self.Item.Attr.Equip.EndureDeg or 10000

        self.EndureDegValue = string.format("%.2f%%", EndureDeg / 100)   --当前耐久度
        if EndureDeg <= 0 then
            self.EndureDegColor = "dc5868"
        else
            self.EndureDegColor = "D5D5D5"
        end
    else
        self.EndureDegValue = "100.00%"
    end

    local RepairProfName = RoleInitCfg:FindRoleInitProfName(ECfg.RepairProf)
    if RepairProfName == nil then
        RepairProfName = ""
    end
    self.EndureDiscountCondition = string.format(LSTR(1020015), RepairProfName, ECfg.RepairProfLevel)

    local DyeEnable = ECfg.CanBeDyed
    local AppearanceID = ECfg.AppearanceID
    self.DyeNameText = DyeEnable == 1 and LSTR(1020016) or LSTR(1020017)
    self.DyeNameTextVisible = AppearanceID ~= 0 
    self.DyeTextVisible = AppearanceID ~= 0 

    if AppearanceID ~= 0 then
        -- self.ShadowNameText = AppearanceID == 0
        local IsUnlock = WardrobeMgr:GetIsUnlock(AppearanceID)
        self.ShadowNameText = IsUnlock and LSTR(1020018) or LSTR(1020019)
    else
        self.DyeTextVisible = false
        self.DyeNameTextVisible = false
        self.ShadowNameText = LSTR(1020020)
    end

    self.BuyPriceText, self.BuyPriceIconVisible = ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
    self.SellPriceText, self.SellPriceIconVisible  = ItemTipsUtil.GetItemCfgSellPrice(Cfg)

    if Value.Maker == nil or Value.Maker.Name == nil then
	    self.MakerNameVisible = false
    else 
        self.MakerNameText = Value.Maker.Name
	    self.MakerNameVisible = true
    end

	--底部按钮
	local EquipedItemInPart = EquipmentMgr:GetEquipedItemByPart(self.Part)
	local bCanEquiped = EquipmentMgr:CanEquiped(Value.ResID)
	if nil ~= EquipedItemInPart then
		local bIsSelectedEquip = EquipedItemInPart.GID == Value.GID
		local bIsMasterHand = self.Part == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND
        self.RightBtnText = bIsSelectedEquip and LSTR(1020021) or LSTR(1020022)
		self.bRightBtnEnabled = not (bIsSelectedEquip and bIsMasterHand) and bCanEquiped -- 已穿戴的主手不可卸下
    else
        self.RightBtnText = LSTR(1020023)
		self.bRightBtnEnabled = bCanEquiped
	end

    self.IsCanImproved = _G.EquipmentMgr:CheckCanImprove(ItemResID)
end

function ItemTipsEquipmentVM:UpdateProfDetail(Cfg, CanWearable, OtherProfWearable)
    if CanWearable then
        self.ImgXVisible = false
        self.ProfDetailColor = "89bd88"
        self.ImgXColor = "89bd88"
    else
        self.ImgXVisible = true
        if OtherProfWearable then
            self.ImgXColor = "FFFFFF"
            self.ProfDetailColor = "FFFFFF"
        else
            self.ImgXColor = "dc5868"
            self.ProfDetailColor = "dc5868"
        end
    end

    if #Cfg.ProfLimit > 0 then
        local ProfNames = {}
        for i = 1, #Cfg.ProfLimit do
            local ProfLimitName = EquipmentMgr:GetProfName(Cfg.ProfLimit[i])
            if not string.isnilorempty(ProfLimitName) then
                table.insert(ProfNames, ProfLimitName)
            end
        end
        local ProfNames = table.concat(ProfNames, "  ", 1, #ProfNames)
        self.ProfText = ProfNames
    else
		if Cfg.ClassLimit == 0 then
			self.ProfText = LSTR(1020004)
		else
            self.ProfText = EquipmentMgr:GetProfClassName(Cfg.ClassLimit)
		end
    end

    self.GradeText = string.format(LSTR(1020025), Cfg.Grade)

end


function ItemTipsEquipmentVM:UpdateAttriInfo(ECfg)
    local LAttrMsg = {}
    local SAttrMsg = {}
    do
        if EquipmentMgr:IsWeapon(ECfg.Part) and ECfg.ArmRatio > 0 then
            local AttrText = string.format(LSTR(1020026))
            local AttrValue = string.format("%.2f%%", ECfg.ArmRatio/100.0)
            table.insert(LAttrMsg, {Attr = AttrText, Value = AttrValue })
        end

        ---过滤+0的属性
        for i = 1, #ECfg.Attr do
            local Attr = ECfg.Attr[i]
            local Attr_Value = Attr.value or Attr.Value
            local Attr_Attr = Attr.attr or Attr.Attr
            if Attr_Value and Attr_Value > 0 then
                local AttrTipsType = AttrDefCfg:GetAttrTipsShowTypeByID(Attr_Attr)
                local ProfID = MajorUtil.GetMajorProfID()
                local RealAttrKey = EquipmentMgr:GetAttributeRealType(Attr_Attr, ProfID)
                local AttrText = AttrDefCfg:GetAttrNameByID(RealAttrKey)
                if not string.isnilorempty(AttrText) then
                    local AttrValue = string.format("+%d", Attr_Value)
                    if AttrTipsType == 1 then
                        table.insert(LAttrMsg, {Attr = AttrText, Value = AttrValue })
                    elseif AttrTipsType == 2 then
                        table.insert(SAttrMsg, {Attr = AttrText, Value = AttrValue })
                    end
                end
                
            end
        end

        --显示长属性
        local LAtttiUINum = self.LongAttriNum
        local LAttrLen = #LAttrMsg
        for i = 1, LAtttiUINum do
            local LAtttiName = string.format("LongAttriText%d", i)
            local LAtttiValue = string.format("LongAttriValue%d", i)
            local LAtttiVisible = string.format("LongAttriVisible%d", i)
            if i  > LAttrLen then
                self[LAtttiVisible] = false
            else
                self[LAtttiVisible] = true
                self[LAtttiName] = LAttrMsg[i].Attr
                self[LAtttiValue] = LAttrMsg[i].Value
            end
        end

        --显示短属性
        local SAtSttiUINum = self.ShortAttriNum
        local SAttrLen = #SAttrMsg
        for i = 1, SAtSttiUINum do
            local SAtttiName = string.format("ShortAttriText%d", i)
            local SAtttiValue = string.format("ShortAttriValue%d", i)
            local SAtttiVisible = string.format("ShortAttriVisible%d", i)
            if i  > SAttrLen then
                self[SAtttiVisible] = false
            else
                self[SAtttiVisible] = true
                self[SAtttiName] = SAttrMsg[i].Attr
                self[SAtttiValue] = SAttrMsg[i].Value
            end
        end
    end
end


function ItemTipsEquipmentVM:UpdateMagicsparInfo(ECfg)
    local ResID = self.Item.ResID
    self.InlayMainPanelVisible = EquipmentMgr:CheckCanMosic(ResID)
    self.MagicsparCfg = MagicsparInlayCfg:FindCfgByPart(ECfg.Part)
    if self.MagicsparCfg == nil or self.MagicsparCfg.NomalCount + self.MagicsparCfg.BanCount == 0 or ECfg.MateID == 0  then
        self.CantInlayVisible = true

        self.CanInlayVisible = false
        self.InlayVisible = false
        return
    end
    self.CantInlayVisible = false

    self.CanInlayVisible = true
    self.InlayVisible = true
    self.InlayDetailVisible = false

    local CarryList = {}
    if self.Item and self.Item.Attr and self.Item.Attr.Equip and self.Item.Attr.Equip.GemInfo then
		CarryList = self.Item.Attr.Equip.GemInfo.CarryList or {}
	end

    local MagicsparInlayNum = self.MagicsparInlayNum
    for i = 1, MagicsparInlayNum do
        local MagicsparInlayName = string.format("InlayNameText%d", i)
        local InlayNameColor = string.format("InlayNameColor%d", i)
        local MagicsparInlayAttr = string.format("InlayAttriText%d", i)
        if CarryList[i] == nil then
            self[InlayNameColor] = "828282FF"
            self[MagicsparInlayName] = LSTR(1020027)
            self[MagicsparInlayAttr] = ""
        else
            local c_item_cfg = ItemCfg:FindCfgByKey(CarryList[i])
            if c_item_cfg == nil then
                self[InlayNameColor] = "828282FF"
                self[MagicsparInlayName] = LSTR(1020027)
                self[MagicsparInlayAttr] = ""
            else
                self[InlayNameColor] = "AAAAAAFF"
                self[MagicsparInlayName] = ItemCfg:GetItemName(CarryList[i])
                self[MagicsparInlayAttr] = ItemCfg:GetItemEffectDesc(CarryList[i])
            end
        end
    end

end

return ItemTipsEquipmentVM