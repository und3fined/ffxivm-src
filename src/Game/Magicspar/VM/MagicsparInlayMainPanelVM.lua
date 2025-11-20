local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentMgr = _G.EquipmentMgr
local UVersionMgr = _G.UE.UVersionMgr

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local MagicsparRuleCfg = require("TableCfg/MagicsparRuleCfg")
local MagicsparLimitCfg = require("TableCfg/MagicsparLimitCfg")

local ItemCfg = require("TableCfg/ItemCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")
local MagicsparInlayStatusItemVM = require("Game/Magicspar/VM/MagicsparInlayStatusItemVM")
local MagicsparInlayRecomItemVM = require("Game/Magicspar/VM/MagicsparInlayRecomItemVM")
local MagicsparAttributeDisplayItemVM = require("Game/Magicspar/VM/MagicsparAttributeDisplayItemVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local FuncCfg = require("TableCfg/FuncCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class MagicsparInlayMainPanelVM : UIViewModel
local MagicsparInlayMainPanelVM = LuaClass(UIViewModel)

-- 系统类型
MagicsparInlayMainPanelVM.ProfType = MagicsparInlayMainPanelVM.ProfType or
{
	Combat = 1,  -- 战斗类职业
	Gather = 2,  -- 采集类职业
    Produce = 3, -- 生产类职业
}

function MagicsparInlayMainPanelVM:Ctor()
    self.GID = nil
    self.Title = _G.LSTR(1060002)--"魔晶石一览"
    self.IconPath = nil
    self.EquipmentName = nil
    self.EquipmentLevel = nil
    self.EquipmentIconPath = nil
    self.CurSelect = nil
    self.bSelect = false
    self.bSelectNomal = false
    self.CurRatio = 0
    self.RateBackgroundIcon = nil
    self.RatioColor = "#89bd88"
    self.bMagicsparItemEmpty = false
    self.EquipmentInUse = false
    self.bListSelectUse = false --魔晶石列表是否选中已镶嵌的魔晶石
    self.bShowTips = false
    self.bShowRemove = false
    --self.bShowMagicValue = false
    self.bRateUse = false
    self.bRedRate = false
    self.bYellowRate = false
    self.bGreenRate = false
    self.bShowInform = false -- 数值面板的提示
    self.bShowExceed = false -- 超出提示
    --self.ExceedText = nil
    -- 属性数值
    self.BeliefNumText = "0/0" -- 信念
    self.AttackNumText = "0/0" -- 直击
    self.HasteNumText = "0/0"  -- 急速
    self.CritNumText = "0/0"   --暴击
    self.BeliefLimitNum = 0
    self.AttackLimitNum = 0
    self.HasteLimitNum = 0
    self.CritLimitNum = 0
    self.bWarningBelief = false
    self.bWarningAttack = false
    self.bWarningHaste = false
    self.bWarningCrit = false

    self.lstMagicsparInlayStatusItemVM = nil
    self.lstMagicsparInlayRecomItemVM = nil
    self.lstMagicsparAttributeDisplayItemVM = nil
    self.SelectSlotIconPath = nil
    self.PreViewIconPath = nil

    self.RemoveButtonText = _G.LSTR(1060016) --"卸下"
    self.StartButtonText  = _G.LSTR(1060017) --"开始镶嵌"
    self.NormalButtonText  = _G.LSTR(1060018) --"普通镶嵌"
    self.BanButtonText  = _G.LSTR(1060019) --"禁忌镶嵌"

    self.SelectGemResID = nil

    self.EquipProfType = 1
    -- 获取方式
    --self.bShowGetWay = false
end

function MagicsparInlayMainPanelVM:InitEquipProfType()
    if nil == self.ItemCfg then return end
    local ClassLimit = self.ItemCfg.ClassLimit
    if ClassLimit == ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER or ClassLimit == ProtoCommon.class_type.CLASS_TYPE_GATHER then
        self.EquipProfType = self.ProfType.Gather
    elseif ClassLimit == ProtoCommon.class_type.CLASS_TYPE_CARPENTER or ClassLimit == ProtoCommon.class_type.CLASS_TYPE_PRODUCTION then
        self.EquipProfType = self.ProfType.Produce
    elseif ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL then
        self.EquipProfType = self.ProfType.Combat
    else
        local ProfLimit = self.ItemCfg.ProfLimit
        if type(ProfLimit) == "table" and table.size(ProfLimit) > 0 then
            local ProfLimitType = ProfLimit[1]
            if ProfLimitType ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
                if ProfUtil.IsGpProf(ProfLimitType) then
                    self.EquipProfType = self.ProfType.Gather
                elseif ProfUtil.IsCrafterProf(ProfLimitType) then
                    self.EquipProfType = self.ProfType.Produce
                else
                    self.EquipProfType = self.ProfType.Combat
                end
            end
        end
    end
end

function MagicsparInlayMainPanelVM:InitMagicsparByGID(InGID, Item)
    self.GID = InGID
    if Item == nil then
        Item = EquipmentMgr:GetItemByGID(InGID)
    end
    if Item == nil then
        FLOG_WARNING("InitMagicsparByGID Item is error GID=%d", InGID)
        return
    end
    self.GemInfo = Item.Attr.Equip.GemInfo.CarryList
    self.EquipmentPart = Item.Attr.Equip.Part

    local EquipedItemInPart = EquipmentMgr:GetEquipedItemByPart(self.EquipmentPart)
    self.EquipmentInUse = EquipedItemInPart ~= nil and (EquipedItemInPart.GID == Item.GID) or false

    self.EquipmentCfg = EquipmentCfg:FindCfgByEquipID(Item.ResID)
    self.ItemCfg = ItemCfg:FindCfgByKey(Item.ResID)

    self:InitEquipProfType()

    if self.EquipmentCfg and self.ItemCfg then
        self.MagicsparInlayCfg = MagicsparInlayCfg:FindCfgByPart(Item.Attr.Equip.Part)
        self.EquipmentName = self.EquipmentCfg.Name
        self.EquipmentLevel = self.ItemCfg.ItemLevel
        if self.MagicsparInlayCfg then 
            self.NomalCount = self.MagicsparInlayCfg.NomalCount
            self.BanCount = self.MagicsparInlayCfg.BanCount
        end
    end
    

    self:InitInlayList()
    self:InitMagicLimit()
end

--初始化已镶嵌信息列表
function MagicsparInlayMainPanelVM:InitInlayList()
    local GemInfo = self.GemInfo
    local lst = {}
    for i = 1, self.NomalCount do
        lst[#lst + 1] = self:GenMagicsparInlayStatusItemVM(GemInfo[i], i, true)
    end
    for i = 1, self.BanCount do
        lst[#lst + 1] = self:GenMagicsparInlayStatusItemVM(GemInfo[i + self.NomalCount], i + self.NomalCount, false)
    end
    self.lstMagicsparInlayStatusItemVM = lst
end

function MagicsparInlayMainPanelVM:GenMagicsparInlayStatusItemVM(InResID, Index, bNomal)
    local ViewModel = MagicsparInlayStatusItemVM.New()
    ViewModel:InitItem(InResID, Index, bNomal)
    return ViewModel
end

function MagicsparInlayMainPanelVM:InitInlayAttrList()
    local ListNum = self.EquipProfType == self.ProfType.Combat and 4 or 3
    local lst = {}
    for i = 1, ListNum do
        lst[#lst + 1] = self:GenMagicsparMagicsparAttributeItemVM(i)
    end
    self.lstMagicsparAttributeDisplayItemVM = lst
end

function MagicsparInlayMainPanelVM:GenMagicsparMagicsparAttributeItemVM(Index)
    local ViewModel = MagicsparAttributeDisplayItemVM.New()
    local NameText = ""
    local ValueText = ""
    local bShowWarning = false
    local LimitValue = 0;

    if self.EquipProfType == self.ProfType.Gather then
		-- self.Text_Belief:SetText(_G.LSTR(1060047)) -- "采集力"
		-- self.Text_Attack:SetText(_G.LSTR(1060048)) -- "获得力"
		-- self.Text_Haste:SetText(_G.LSTR(1060049))  -- "鉴别力"
		-- self.Text_Crit:SetText("")
        NameText = _G.LSTR(1060046+Index)
	elseif self.EquipProfType == self.ProfType.Produce then
		-- self.Text_Belief:SetText(_G.LSTR(1060050)) -- "制作力"
		-- self.Text_Attack:SetText(_G.LSTR(1060051)) -- "作业精度"
		-- self.Text_Haste:SetText(_G.LSTR(1060052))  -- "加工精度"
		-- self.Text_Crit:SetText("")
        NameText = _G.LSTR(1060049+Index)
	else
		-- self.Text_Belief:SetText(_G.LSTR(1060023)) -- "信念"
		-- self.Text_Attack:SetText(_G.LSTR(1060024)) -- "直击"
		-- self.Text_Haste:SetText(_G.LSTR(1060025))  -- "急速"
		-- self.Text_Crit:SetText(_G.LSTR(1060026))   -- "暴击"
        NameText = _G.LSTR(1060022+Index)
	end

    if Index == 1 then
        ValueText = self.BeliefNumText
        LimitValue = self.BeliefLimitNum
        bShowWarning = self.bWarningBelief
    elseif Index == 2 then
        ValueText = self.AttackNumText
        LimitValue = self.AttackLimitNum
        bShowWarning = self.bWarningAttack
    elseif Index == 3 then
        ValueText = self.HasteNumText
        LimitValue = self.HasteLimitNum
        bShowWarning = self.bWarningHaste
    else
        ValueText = self.CritNumText
        LimitValue = self.CritLimitNum
        bShowWarning = self.bWarningCrit
    end
    ViewModel:InitItem(Index, NameText, ValueText, LimitValue, bShowWarning)
    return ViewModel
end

function MagicsparInlayMainPanelVM:InitMagicLimit()
    --local Prof = MajorUtil.GetMajorProfID()
    --self.bCombatProf = ProfUtil.IsCombatProf(Prof)
    if self.EquipProfType ~= self.ProfType.Combat or (not EquipmentMgr:IsEquiped(self.GID)) then
        return
    end
    -- 获取最大值
    --local VersionType = "2.0.0" -- 版本号后续由策划配置，默认为2.0.0
    --local GameVersion = UVersionMgr.GetGameVersion()
    --local SearchConditions = string.format("Version = \"%s\"", VersionType)
    --local LimitCfg = MagicsparLimitCfg:FindCfg(SearchConditions)
    local function CompareVersion(Version1, Version2)
        if Version1 == nil then
            return true
        elseif Version2 == nil then
            return false
        else
            local DataValue = string.gsub(Version1, '%.', '')
	        local GameValue = string.gsub(Version2, '%.', '')
	        return tonumber(DataValue) <= tonumber(GameValue)
        end
    end
   
    local LimitList = MagicsparLimitCfg:FindAllCfg()
    local LimitCfg = nil
    for _, Cfg in pairs(LimitList) do
        if UVersionMgr.IsBelowOrEqualGameVersion(Cfg.Version) and
           (LimitCfg == nil or CompareVersion(LimitCfg.Version, Cfg.Version)) then
            LimitCfg = Cfg
        end
    end
    if LimitCfg == nil then return end
    self.BeliefLimitNum = LimitCfg.BeliefLimit
    self.AttackLimitNum = LimitCfg.AttackLimit
    self.HasteLimitNum = LimitCfg.HasteLimit
    self.CritLimitNum = LimitCfg.CritLimit
end

--更新魔晶石属性显示文本 --一废弃
function MagicsparInlayMainPanelVM:UpdateMagicText(Index)
    self.BeliefNumText = "0/0" -- 信念
    self.AttackNumText = "0/0" -- 直击
    self.HasteNumText = "0/0"  -- 急速
    self.CritNumText = "0/0"   --暴击
    local ResID = self.GemInfo[Index]   --已装备的魔晶石id
    local GemAttrKey = EquipmentMgr:GetMagicsparsAttrKey(ResID)
    local GemAttrValue = EquipmentMgr:GetMagicsparsAttrValue(ResID)
    if GemAttrKey == nil or tonumber(GemAttrKey) == 0  or GemAttrValue == nil then
        return false
    end
    if GemAttrKey == ProtoCommon.attr_type.attr_belief then
        if GemAttrValue > self.BeliefLimitNum then
            --GemAttrValue = self.BeliefLimitNum
            self.bWarningBelief = true
        else
            self.bWarningBelief = false
        end
        self.BeliefNumText = string.format("%d/%d", GemAttrValue, self.BeliefLimitNum)
    elseif GemAttrKey == ProtoCommon.attr_type.attr_direct_atk then
        if GemAttrValue > self.AttackLimitNum then
            --GemAttrValue = self.AttackLimitNum
            self.bWarningAttack = true
        else
            self.bWarningAttack = false
        end
        self.AttackNumText = string.format("%d/%d", GemAttrValue, self.AttackLimitNum)
    elseif GemAttrKey == ProtoCommon.attr_type.attr_quick then
        if GemAttrValue > self.HasteLimitNum then
            --GemAttrValue = self.HasteLimitNum
            self.bWarningHaste = true
        else
            self.bWarningHaste = false
        end
        self.HasteNumText = string.format("%d/%d", GemAttrValue, self.HasteLimitNum)
    elseif GemAttrKey == ProtoCommon.attr_type.attr_critical then
        if GemAttrValue > self.CritLimitNum then
            --GemAttrValue = self.CritLimitNum
            self.bWarningCrit = true
        else
            self.bWarningCrit = false
        end
        self.CritNumText = string.format("%d/%d", GemAttrValue, self.CritLimitNum)
    else
        return
    end
end

-- 预览魔晶石变化
function MagicsparInlayMainPanelVM:GetPreviewText(InKey, OldKey, OldValue, NewKey, NewValue)
    if self.bMagicsparItemEmpty or self.bListSelectUse or self.bSelect == false then
        -- 魔晶石列表为空或选中已镶嵌的
        return ""
    end
    local CalValue = 0;
    if InKey == OldKey then
        CalValue = CalValue - OldValue
    end
    if InKey == NewKey then
        CalValue = CalValue + NewValue
    end
    local PreviewText = ""
    if CalValue < 0 then
        PreviewText = string.format("<span color=\"#dc5868\">(%d)</>", CalValue)
    elseif CalValue > 0 then
        PreviewText = string.format("<span color=\"#89bd88\">(+%d)</>", CalValue)
    end
    return PreviewText
end

function MagicsparInlayMainPanelVM:UpdateAllMagicText()
    if EquipmentMgr:IsEquiped(self.GID) then
        self:UpdateEquipMagicText()
    else
        self:UpdateNoEquipMagicText()
    end
    self:InitInlayAttrList()
end

--更新已穿戴所有装备已镶嵌魔晶石数值属性显示文本
function MagicsparInlayMainPanelVM:UpdateEquipMagicText()
    -- 生产职业不显示数值面板
    --self.bShowMagicValue =  self.bShowMagicValue and (not (MajorUtil.IsGpProf() or MajorUtil.IsGatherProf() or MajorUtil.IsCrafterProf()))
    --if self.bShowMagicValue == false then return end
    local BeliefNum = 0
    local AttackNum = 0
    local HasteNum = 0
    local CritNum = 0
    local MagicValueText = ""
    local PreviewText = ""
    local MagicLimitText = ""
    -- 已镶嵌和预览镶嵌的数值
    local OldResID = self.GemInfo ~= nil and self.GemInfo[self.CurSelect] or nil
    local OldAttrKey = 0
    local OldAttrValue = 0
    local NewResID = self.SelectGemResID
    local NewAttrKey = 0
    local NewAttrValue = 0
    if OldResID ~= nil and OldResID > 0 then
        OldAttrKey = EquipmentMgr:GetMagicsparsAttrKey(OldResID) or 0
        OldAttrValue = OldResID ~= nil and EquipmentMgr:GetMagicsparsAttrValue(OldResID) or 0
    end
    if NewResID ~= nil and NewResID > 0 then
        NewAttrKey = EquipmentMgr:GetMagicsparsAttrKey(NewResID) or 0
        NewAttrValue = NewResID ~= nil and EquipmentMgr:GetMagicsparsAttrValue(NewResID) or 0
    end
    --文本更新
    --self.BeliefNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", BeliefNum, self.BeliefLimitNum)
    --self.AttackNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", AttackNum, self.AttackLimitNum)
    --self.HasteNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", HasteNum, self.HasteLimitNum)
    --self.CritNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", CritNum, self.CritLimitNum)

    -- 获取所有穿戴装备
    for key, _ in pairs(EquipmentMgr:GetEquipPartName()) do
        -- 获取装备的镶嵌魔晶石
        local EquipItem = EquipmentMgr:GetEquipedItemByPart(key)
        if EquipItem ~= nil then
            local GemInfoList = EquipItem.Attr.Equip.GemInfo.CarryList
            for _, StoneResID in pairs(GemInfoList) do
                if StoneResID ~= nil then
                    --local ResID = self.GemInfo[Index]   --已装备的魔晶石id
                    local GemAttrKey = EquipmentMgr:GetMagicsparsAttrKey(StoneResID)
                    local GemAttrValue = EquipmentMgr:GetMagicsparsAttrValue(StoneResID) or 0
                    if GemAttrKey == ProtoCommon.attr_type.attr_belief
                        or GemAttrKey == ProtoCommon.attr_type.attr_gp_max
                        or GemAttrKey == ProtoCommon.attr_type.attr_mk_max then
                        BeliefNum = BeliefNum + GemAttrValue
                    elseif GemAttrKey == ProtoCommon.attr_type.attr_direct_atk
                        or GemAttrKey == ProtoCommon.attr_type.attr_gathering
                        or GemAttrKey == ProtoCommon.attr_type.attr_work_precision then
                        AttackNum = AttackNum + GemAttrValue
                    elseif GemAttrKey == ProtoCommon.attr_type.attr_quick
                        or GemAttrKey == ProtoCommon.attr_type.attr_perception
                        or GemAttrKey == ProtoCommon.attr_type.attr_produce_precision then
                        HasteNum = HasteNum + GemAttrValue
                    elseif GemAttrKey == ProtoCommon.attr_type.attr_critical then
                        CritNum = CritNum + GemAttrValue
                    end
                end
            end
        end
    end
    local GemAttrKeyList = {}
    if self.EquipProfType == self.ProfType.Combat then
        GemAttrKeyList[1] = ProtoCommon.attr_type.attr_belief
        GemAttrKeyList[2] = ProtoCommon.attr_type.attr_direct_atk
        GemAttrKeyList[3] = ProtoCommon.attr_type.attr_quick
        GemAttrKeyList[4] = ProtoCommon.attr_type.attr_critical
    elseif self.EquipProfType == self.ProfType.Gather then
        GemAttrKeyList[1] = ProtoCommon.attr_type.attr_gp_max
        GemAttrKeyList[2] = ProtoCommon.attr_type.attr_gathering
        GemAttrKeyList[3] = ProtoCommon.attr_type.attr_perception
        self.CritNumText = ""
    elseif self.EquipProfType == self.ProfType.Produce then
        GemAttrKeyList[1] = ProtoCommon.attr_type.attr_mk_max
        GemAttrKeyList[2] = ProtoCommon.attr_type.attr_work_precision
        GemAttrKeyList[3] = ProtoCommon.attr_type.attr_produce_precision
        self.CritNumText = ""
    end

    for index, value in ipairs(GemAttrKeyList) do
        if index == 1 then
            if self.BeliefLimitNum == 0 then
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", BeliefNum)
                MagicLimitText = ""
            elseif BeliefNum > self.BeliefLimitNum then
                self.bWarningBelief = true
                MagicValueText =  string.format("<span color=\"#dc5868\">%d</>", BeliefNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.BeliefLimitNum)
            else
                self.bWarningBelief = false
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", BeliefNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.BeliefLimitNum)
            end
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.BeliefNumText = MagicValueText..PreviewText..MagicLimitText
        elseif index == 2 then
            if self.AttackLimitNum == 0 then
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", AttackNum)
                MagicLimitText = ""
            elseif AttackNum > self.AttackLimitNum then
                self.bWarningAttack = true
                MagicValueText =  string.format("<span color=\"#dc5868\">%d</>", AttackNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.AttackLimitNum)
            else
                self.bWarningAttack = false
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", AttackNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.AttackLimitNum)
            end
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.AttackNumText = MagicValueText..PreviewText..MagicLimitText
        elseif index == 3 then
            if self.HasteLimitNum == 0 then
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", HasteNum)
                MagicLimitText = ""
            elseif HasteNum > self.HasteLimitNum then
                --HasteNum = self.HasteLimitNum
                self.bWarningHaste = true
                MagicValueText =  string.format("<span color=\"#dc5868\">%d</>", HasteNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.HasteLimitNum)
            else
                self.bWarningHaste = false
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", HasteNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.HasteLimitNum)
            end
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.HasteNumText = MagicValueText..PreviewText..MagicLimitText
        else
            if self.CritLimitNum == 0 then
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", CritNum)
                MagicLimitText = ""
            elseif CritNum > self.CritLimitNum then
                --CritNum = self.CritLimitNum
                self.bWarningCrit = true
                MagicValueText =  string.format("<span color=\"#dc5868\">%d</>", CritNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.CritLimitNum)
            else
                self.bWarningCrit = false
                MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", CritNum)
                MagicLimitText =  string.format("/<span color=\"#d5d5d5\">%d</>", self.CritLimitNum)
            end
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.CritNumText = MagicValueText..PreviewText..MagicLimitText
        end
    end
end

--更新当前未穿戴装备镶嵌魔晶石数值属性显示文本
function MagicsparInlayMainPanelVM:UpdateNoEquipMagicText()
    local BeliefNum = 0
    local AttackNum = 0
    local HasteNum = 0
    local CritNum = 0
    local MagicValueText = ""
    local PreviewText = ""
    local MagicLimitText = ""
    -- 已镶嵌和预览镶嵌的数值
    local OldResID = self.GemInfo ~= nil and self.GemInfo[self.CurSelect] or nil
    local OldAttrKey = 0
    local OldAttrValue = 0
    local NewResID = self.SelectGemResID
    local NewAttrKey = 0
    local NewAttrValue = 0
    if OldResID ~= nil and OldResID > 0 then
        OldAttrKey = EquipmentMgr:GetMagicsparsAttrKey(OldResID) or 0
        OldAttrValue = OldResID ~= nil and EquipmentMgr:GetMagicsparsAttrValue(OldResID) or 0
    end
    if NewResID ~= nil and NewResID > 0 then
        NewAttrKey = EquipmentMgr:GetMagicsparsAttrKey(NewResID) or 0
        NewAttrValue = NewResID ~= nil and EquipmentMgr:GetMagicsparsAttrValue(NewResID) or 0
    end
    --文本更新
    --self.BeliefNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", BeliefNum, self.BeliefLimitNum)
    --self.AttackNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", AttackNum, self.AttackLimitNum)
    --self.HasteNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", HasteNum, self.HasteLimitNum)
    --self.CritNumText = string.format("<span color=\"#dlba8e\">%d</>/<span color=\"#d5d5d5\">%d</>", CritNum, self.CritLimitNum)

    -- 获取当前装备的镶嵌魔晶石
    local GemInfoList = self.GemInfo
    if GemInfoList ~= nil then
        for _, StoneResID in pairs(GemInfoList) do
            if StoneResID ~= nil then
                --local ResID = self.GemInfo[Index]   --已装备的魔晶石id
                local GemAttrKey = EquipmentMgr:GetMagicsparsAttrKey(StoneResID)
                local GemAttrValue = EquipmentMgr:GetMagicsparsAttrValue(StoneResID) or 0
                if GemAttrKey == ProtoCommon.attr_type.attr_belief
                    or GemAttrKey == ProtoCommon.attr_type.attr_gp_max
                    or GemAttrKey == ProtoCommon.attr_type.attr_mk_max then
                    BeliefNum = BeliefNum + GemAttrValue
                elseif GemAttrKey == ProtoCommon.attr_type.attr_direct_atk
                    or GemAttrKey == ProtoCommon.attr_type.attr_gathering
                    or GemAttrKey == ProtoCommon.attr_type.attr_work_precision then
                    AttackNum = AttackNum + GemAttrValue
                elseif GemAttrKey == ProtoCommon.attr_type.attr_quick
                    or GemAttrKey == ProtoCommon.attr_type.attr_perception
                    or GemAttrKey == ProtoCommon.attr_type.attr_produce_precision then
                    HasteNum = HasteNum + GemAttrValue
                elseif GemAttrKey == ProtoCommon.attr_type.attr_critical then
                    CritNum = CritNum + GemAttrValue
                end
            end
        end
    end
    local GemAttrKeyList = {}
    if self.EquipProfType == self.ProfType.Combat then
        GemAttrKeyList[1] = ProtoCommon.attr_type.attr_belief
        GemAttrKeyList[2] = ProtoCommon.attr_type.attr_direct_atk
        GemAttrKeyList[3] = ProtoCommon.attr_type.attr_quick
        GemAttrKeyList[4] = ProtoCommon.attr_type.attr_critical
    elseif self.EquipProfType == self.ProfType.Gather then
        GemAttrKeyList[1] = ProtoCommon.attr_type.attr_gp_max
        GemAttrKeyList[2] = ProtoCommon.attr_type.attr_gathering
        GemAttrKeyList[3] = ProtoCommon.attr_type.attr_perception
        self.CritNumText = ""
    elseif self.EquipProfType == self.ProfType.Produce then
        GemAttrKeyList[1] = ProtoCommon.attr_type.attr_mk_max
        GemAttrKeyList[2] = ProtoCommon.attr_type.attr_work_precision
        GemAttrKeyList[3] = ProtoCommon.attr_type.attr_produce_precision
        self.CritNumText = ""
    end

    for index, value in ipairs(GemAttrKeyList) do
        if index == 1 then
            MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", BeliefNum)
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.BeliefNumText = MagicValueText..PreviewText..MagicLimitText
        elseif index == 2 then
            MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", AttackNum)
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.AttackNumText = MagicValueText..PreviewText..MagicLimitText
        elseif index == 3 then
            MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", HasteNum)
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.HasteNumText = MagicValueText..PreviewText
        else
            MagicValueText =  string.format("<span color=\"#dlba8e\">%d</>", CritNum)
            PreviewText = self:GetPreviewText(value, OldAttrKey, OldAttrValue, NewAttrKey, NewAttrValue)
            self.CritNumText = MagicValueText..PreviewText
        end
    end
end



-- function MagicsparInlayMainPanelVM:UpdateExceedInform(AttrIndex)
--     if AttrIndex == 1 then
--         self.ExceedText = string.format(_G.LSTR(1060011), self.BeliefLimitNum) --"信念已超过%d，超出部分不生效"
--     elseif AttrIndex == 2 then
--         self.ExceedText = string.format(_G.LSTR(1060012), self.AttackLimitNum) --"直击已超过%d，超出部分不生效"
--     elseif AttrIndex == 3 then
--         self.ExceedText = string.format(_G.LSTR(1060013), self.HasteLimitNum) --"急速已超过%d，超出部分不生效"
--     elseif AttrIndex == 4 then
--         self.ExceedText = string.format(_G.LSTR(1060014), self.CritLimitNum) --"暴击已超过%d，超出部分不生效"
--     else
--         return
--     end
-- end

function MagicsparInlayMainPanelVM:SelectSlot(Index)
    if self.MagicsparInlayCfg == nil then return end
    self.CurSelect = Index
    self.Title = _G.LSTR(1060001)--"魔晶石镶嵌"
	--self.bSelect = true
    self.bSelectNomal = self.MagicsparInlayCfg.Hole[Index].Type == ProtoCommon.hole_type.HOLE_TYPE_NORMAL
    self.CurRatio = self.MagicsparInlayCfg.Hole[Index].Ratio/100
    self:GenItemList(Index)
end

function MagicsparInlayMainPanelVM:UpSelectSlot()
    self.bSelect = false
    self.Title = _G.LSTR(1060002)--"魔晶石一览"
	self.CurSelect = 3
	self.bMagicsparItemEmpty = false
    --self.bShowGetWay = false
    self.bListSelectUse = false
    self.bShowRemove = false
end

-- 1.PVE战职装备可镶嵌的魔晶石类型：暴击，直击，信念，急速	　	　	　	　	　	　	　	　
-- 　	2.PVP战职装备-防具可镶嵌的魔晶石类型：暴击，直击，信念，急速，韧性	　	　	　	　	　	　	　
-- 　	3.PVP战职装备-武器\饰品可镶嵌的魔晶石类型：暴击，直击，信念，急速，穿刺	　	　	　	　	　	　
-- 　	4.采集职业装备可镶嵌的魔晶石类型：获得力，鉴别力，采集力	　	　	　	　	　	　	　	　
-- 　	5.制造职业装备可镶嵌的魔晶石类型：作业精度，加工精度，制造力
--      上面逻辑有部分已修改，可镶嵌的魔晶石类型有策划配表由MateID控制
function MagicsparInlayMainPanelVM:FilterMagicspar(ResID, RuleCfg, EquipProperty)
    --if EquipProperty == ProtoCommon.equip_property.EQUIP_PROPERTY_BATTLE then
        --return true
    --end

    if RuleCfg == nil then 
        return false 
    end

    --if RuleCfg.ClassLimit > 0 and RuleCfg.ClassLimit ~= self.ItemCfg.ClassLimit then
        --return false
    --end
    local ItemCfg = ItemCfg:FindCfgByKey(ResID)
    if ItemCfg == nil then 
        return false 
    end

    local GemAttr = EquipmentMgr:GetMagicsparsAttrKey(ResID)
    if GemAttr == nil or tonumber(GemAttr) == 0 then 
        return false
    end

    local lstAttr = RuleCfg.Attr
    for i = 1, #lstAttr do
        if tonumber(lstAttr[i]) == tonumber(GemAttr) then
            return true
        end
    end
    return false
end

-- 优先级	排序方式	　	　	　	　	　	　	　	　	　	　
-- 　	　	1	是否可用，可用的在前	　	　	　	　	　	　	　	　
-- 　	　	2	魔晶石等级，按照高等级→低等级排列	　	　	　	　	　	　	　
-- 　	　	3	魔晶石类型，战职PVE装备按照：暴击>直击>急速>信念的顺序排列	　	　	　	　
-- 　	　	3	魔晶石类型，战职PVP装备按照：韧性=穿刺>暴击>直击>急速>信念的顺序排列	　	　	　
-- 　	　	3	魔晶石类型，采集装备按照：获得力>鉴别力>采集力的顺序排列	　	　	　	　
-- 　	　	3	魔晶石类型，制造装备按照：作业精度>加工精度>制造力的顺序排列
-- 韧性=穿刺>暴击>直击>急速>信念>获得力>鉴别力>采集力上限>作业精度>加工精度>制造力上限
local MagicsparAttrWeight = 
{
    [ProtoCommon.attr_type.attr_ductility] = 1000,
    [ProtoCommon.attr_type.attr_puncture] = 1000,
    [ProtoCommon.attr_type.attr_critical] = 999,
    [ProtoCommon.attr_type.attr_direct_atk] = 998,
    [ProtoCommon.attr_type.attr_quick] = 997,
    [ProtoCommon.attr_type.attr_belief] = 996,
    [ProtoCommon.attr_type.attr_gathering] = 995,
    [ProtoCommon.attr_type.attr_perception] = 994,
    [ProtoCommon.attr_type.attr_gp_max] = 993,
    [ProtoCommon.attr_type.attr_work_precision] = 992,
    [ProtoCommon.attr_type.attr_produce_precision] = 991,
    [ProtoCommon.attr_type.attr_mk_max] = 990,
}
local function MagicsparSort(Left, Right)
    local LeftCfg = ItemCfg:FindCfgByKey(Left.ResID)
    local RightCfg = ItemCfg:FindCfgByKey(Right.ResID)

    --魔晶石等级
    if LeftCfg.ItemLevel ~= RightCfg.ItemLevel then
        return LeftCfg.ItemLevel > RightCfg.ItemLevel
    end

    local LeftCfgFunc = FuncCfg:FindCfgByKey(LeftCfg.UseFunc) -- 物品功能
    local RightCfgFunc = FuncCfg:FindCfgByKey(RightCfg.UseFunc) -- 物品功能
    ---属性权重
    local LeftAttrWeight = MagicsparAttrWeight[EquipmentMgr:GetMagicsparsAttrKey(Left.ResID)]
    local RightAttrWeight = MagicsparAttrWeight[EquipmentMgr:GetMagicsparsAttrKey(Right.ResID)]
    if LeftAttrWeight ~= nil and RightAttrWeight ~= nil and RightAttrWeight ~= LeftAttrWeight then
        return LeftAttrWeight > RightAttrWeight
    end

    return Left.ResID < Right.ResID
end

function MagicsparInlayMainPanelVM:GenItemList(Index)
    local lst = {}

    local ResID = self.GemInfo[Index]   --已装备的魔晶石id
    local lstItem = EquipmentMgr:GetMagicsparsFromBag(self.bSelectNomal)
    --local RuleCfg = MagicsparRuleCfg:FindRuleCfg(self.EquipmentCfg.EquipProperty, self.EquipmentCfg.ItemMainType)
    local RuleCfg = MagicsparRuleCfg:FindCfgByKey(self.EquipmentCfg.MateID)
    for i = 1, #lstItem do
        local Item = lstItem[i]
        -- 加入去重
        if (ResID == nil or ResID == 0 or ResID ~= Item.ResID) and self:FilterMagicspar(Item.ResID, RuleCfg, self.EquipmentCfg.EquipProperty) 
        and (not table.containAttr(lst, Item.ResID, "ResID")) then
            local ViewModel = MagicsparInlayRecomItemVM.New()
            ViewModel:InitItem(Item.ResID)
            lst[#lst + 1] = ViewModel
        end
    end
    ---排序
	table.sort(lst, MagicsparSort)

    --计算第一个的推荐
    if #lst > 0 then   
        lst[1]:CalculateRecommend()
    end

    if ResID ~= nil and ResID > 0 then
        --如果已镶嵌，第一个用已镶嵌的
        local ViewModel = MagicsparInlayRecomItemVM.New()
        ViewModel:InitItem(ResID)
        ViewModel.bInlayed = true
        ViewModel.bUse = true
        table.insert(lst, 1, ViewModel)
    end

    self.bMagicsparItemEmpty = #lst == 0
    self.lstMagicsparInlayRecomItemVM = lst
end

function MagicsparInlayMainPanelVM:GetStoneIconPath(ResID)
    if ResID == nil or ResID == 0 then return nil end
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if nil == Cfg then
		return nil
	end
	return ItemCfg.GetIconPath(Cfg.IconID)
end

function MagicsparInlayMainPanelVM:UpdateRateStyle()
    -- 0 Green 1 Yellow 2 Red
    self.bGreenRate = false
    self.bYellowRate = false
    self.bRedRate = false
	if self.CurRatio <= 30 then
        self.bRedRate = true
		self.RatioColor = "#dc5868"
		self.RateBackgroundIcon = "Texture2D'/Game/UI/Texture/Magicspar/UI_Magiespar_Tips_Img_ProbabilityRed25.UI_Magiespar_Tips_Img_ProbabilityRed25'"
	elseif self.CurRatio > 30 and self.CurRatio <=70 then
        self.bYellowRate = true
		self.RatioColor = "#d1ba8e"
		self.RateBackgroundIcon = "Texture2D'/Game/UI/Texture/Magicspar/UI_Magiespar_Tips_Img_ProbabilityYellow50.UI_Magiespar_Tips_Img_ProbabilityYellow50"
    else
        self.bGreenRate = true
        self.RatioColor = "#89bd88"
        self.RateBackgroundIcon = "Texture2D'/Game/UI/Texture/Magicspar/UI_Magiespar_Tips_Img_ProbabilityGreen100.UI_Magiespar_Tips_Img_ProbabilityGreen100'"
	end
end
return MagicsparInlayMainPanelVM