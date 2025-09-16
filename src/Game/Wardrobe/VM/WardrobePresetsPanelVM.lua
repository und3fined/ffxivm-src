--
-- Author: ZhengJianChuan
-- Date: 2024-03-01 20:03
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local UIBindableList = require("UI/UIBindableList")
local ClosetPresetSuitCfg = require("TableCfg/ClosetPresetSuitCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local WardrobePresetsListItemVM = require("Game/Wardrobe/VM/Item/WardrobePresetsListItemVM")
local WardrobePresetsSlotItemVM = require("Game/Wardrobe/VM/Item/WardrobePresetsSlotItemVM")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local MajorUtil = require("Utils/MajorUtil")
local ItemUtil = require("Utils/ItemUtil")
local NormalColor = "#828282FF"
local WarningColor = "#D1BA8EFF"
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

local LSTR

---@class WardrobePresetsPanelVM : UIViewModel
local WardrobePresetsPanelVM = LuaClass(UIViewModel)

---Ctor
function WardrobePresetsPanelVM:Ctor()
    self.PresetsList = UIBindableList.New(WardrobePresetsListItemVM)
    self.EquipmentList = UIBindableList.New(WardrobePresetsSlotItemVM)
    self.SaveBtnVisible = false
    self.UseBtnVisible = false
    self.UsingBtnVisible = false
    self.UsingBtnStatus = false
    self.AssociationCheck = false
    self.RenameVisible = false
    self.AssocaitionVisible = false
    self.AssociationText = ""
    self.SuitName = ""
    -- self.BtnUseText = "使用"
end

function WardrobePresetsPanelVM:OnInit()
end

function WardrobePresetsPanelVM:OnBegin()
	LSTR = _G.LSTR
end

function WardrobePresetsPanelVM:OnEnd()
end

function WardrobePresetsPanelVM:OnShutdown()
end

function WardrobePresetsPanelVM:InitPresetList()
    local Cfg = ClosetPresetSuitCfg:FindAllCfg()
    local ProfID = MajorUtil.GetMajorProfID()
    local CurSuitID = WardrobeMgr:GetUsedSuitID()
    local SuitsInfo = WardrobeMgr:GetPresets(CurSuitID) or WardrobeMgr:GetPresetsClient(CurSuitID)
    local DataList = {}
    local MaxPresetsNum = #Cfg

    self.PresetsList:Clear()

    -- 新建一个当前预设的id
    local TempData ={}
    TempData.IconVisible = true
    TempData.PresetName = _G.LSTR(1080063)
    TempData.ProfName = _G.EquipmentMgr:GetProfName((SuitsInfo ~= nil and SuitsInfo.RelatedProf ~= 0) and SuitsInfo.RelatedProf or ProfID)
    TempData.ProfVisible = true
    TempData.ProfColor = "#D5D5D5FF"
    TempData.CurSuitCheck = WardrobeMgr:GetUsedSuitID() == 0 or (WardrobeMgr:GetUsedSuitID() ~=0 and not WardrobeMgr:GetCurUsedSuitIsUsed(CurSuitID, self:GetCurSuitData()))
    TempData.DetailVisible = true
    TempData.AddVisible = false
    TempData.IsFirst = true
    table.insert(DataList, TempData)

    local CurLength = 0

    for index, v in ipairs(Cfg) do
        local DataSuitsInfo = WardrobeMgr:GetPresets(v.ID) or WardrobeMgr:GetPresetsClient(v.ID)
        if DataSuitsInfo ~= nil and (v.DefaultUnlock == 1 or index <= WardrobeMgr:GetSuitUpperLimit())  then
            local Data = {}
            Data.ID = v.ID
            Data.IconVisible = true
            Data.DetailVisible = true
            Data.AddVisible = false
            Data.CurSuitCheck = WardrobeMgr:GetUsedSuitID() == v.ID and WardrobeMgr:GetPresets(v.ID) ~= nil and WardrobeMgr:GetCurUsedSuitIsUsed(CurSuitID, self:GetCurSuitData()) 
            Data.Num = index
            if DataSuitsInfo.RelatedProf == 0 then
                Data.ProfName = DataSuitsInfo.SuitProfID == 0 and "" or string.format("%s%s", _G.EquipmentMgr:GetProfName(DataSuitsInfo.SuitProfID), _G.LSTR("1080105"))
                Data.ProfVisible =  DataSuitsInfo.SuitProfID and DataSuitsInfo.SuitProfID ~= 0
                Data.ProfColor = NormalColor
            else
                Data.ProfName = string.format(_G.LSTR(1080064), _G.EquipmentMgr:GetProfName(DataSuitsInfo.RelatedProf) or "")
                Data.ProfVisible = true
                Data.ProfColor = WarningColor
            end
            Data.PresetName = DataSuitsInfo.SuitName
            CurLength = index
            table.insert(DataList, Data)
        end
    end

    -- 最后面加一个添加的Item
    if CurLength < MaxPresetsNum then
        local Data = {}
        Data.IconVisible = false
        Data.DetailVisible = false
        Data.AddVisible = true
        Data.CurSuitCheck = false
        table.insert(DataList, Data)
    end

    self.PresetsList:UpdateByValues(DataList)
end

function WardrobePresetsPanelVM:IsPreInstallSuit(Data)
    if Data and Data.Suit then
        for k, v in pairs(Data.Suit) do
            if v.Avatar ~= 0 then
                return false
            end
        end
    end

    return true
end

-- 更新预设列表里的装备数据
function WardrobePresetsPanelVM:UpdateEquipementSlotList(PresetsID)
    local DataList = {}
    self.EquipmentList:Clear()
    
    local CurrentList = WardrobeMgr:GetPresets(PresetsID) or WardrobeMgr:GetPresetsClient(PresetsID)
    local IsPreInitSuit = self:IsPreInstallSuit(CurrentList)
    if not PresetsID or IsPreInitSuit then
        DataList = self:GetCurSuitData()
    else
        for key, value in ipairs(WardrobeDefine.EquipmentTab) do
            if CurrentList.Suit[value] == nil then
                CurrentList.Suit[value] = { Color = 0, Avatar = 0}
            end
        end    
        
        for _, v in ipairs(WardrobeDefine.EquipmentTab) do
            for key, value in pairs(CurrentList.Suit) do
                if key == v then
                    local Data = {}
                    local AppID = value.Avatar
                    local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
                    Data.Avatar = AppID
                    if AppID == 0 then
                        Data.EquipmentIcon =  _G.EquipmentMgr:GetPartIcon(v)
                        Data.EquipmentIconAlpha = 0.1
                        Data.StainTagVisible = false
                        Data.StainColor = ""
                        Data.StainColorVisible = false
                        Data.CanEquiped = true
                    else
                        Data.EquipmentIcon = WardrobeUtil.GetEquipmentAppearanceIcon(AppID)
                        Data.EquipmentIconAlpha = 1.0
                        Data.StainTagVisible = WardrobeMgr:GetDyeEnable(AppID)
                        Data.StainColorVisible = WardrobeUtil.IsAppRegionDye(AppID) and WardrobeUtil.IsDyeColorRegionDye(value.RegionDye) or value.Color ~= 0
                        if WardrobeMgr:GetIsUnlock(AppID) then
                            Data.CanEquiped = WardrobeMgr:CanEquipedAppearanceByServerData(AppID) 
                        else
                            Data.CanEquiped = WardrobeMgr:CanEquipedAppearanceByClientData(AppID)
                        end
                    end
                    table.insert(DataList, Data)
                end
            end
        end
    end

    self.EquipmentList:UpdateByValues(DataList)
end

-- 当前穿戴获取的外观
function WardrobePresetsPanelVM:GetCurSuitData()
    local DataList = {}
    for _, v in ipairs(WardrobeDefine.EquipmentTab) do
        local Data = {}
        local SuitView = WardrobeMgr:GetCurAppearanceList()
        local SuitItem = SuitView[v]
        Data.RegionDye = {}
        Data.PartID = v
        if SuitItem == nil then
            Data.EquipmentIcon = _G.EquipmentMgr:GetPartIcon(v)
            Data.EquipmentIconAlpha = 0.1
            Data.CanEquiped = true
            Data.StainTagVisible = false
            Data.StainColor = ""
            Data.StainColorVisible = false
            Data.Avatar = 0
            Data.Color = 0
        else
            local AppID = SuitItem.Avatar
            Data.Avatar = AppID
            if AppID == 0 then
                Data.EquipmentIcon = _G.EquipmentMgr:GetPartIcon(v)
                Data.EquipmentIconAlpha = 0.1
                Data.StainTagVisible = false
                Data.StainColor = ""
                Data.StainColorVisible = false
                Data.CanEquiped = true
                Data.Color = 0
            else
                Data.EquipmentIcon = WardrobeUtil.GetEquipmentAppearanceIcon(AppID)
                Data.EquipmentIconAlpha = 1.0
                Data.StainTagVisible = WardrobeMgr:GetDyeEnable(AppID)
                Data.StainColorVisible = WardrobeMgr:GetIsDye(AppID)
                if WardrobeMgr:GetIsUnlock(AppID) then
                    Data.CanEquiped = WardrobeMgr:CanEquipedAppearanceByServerData(AppID) 
                else
                    Data.CanEquiped = WardrobeMgr:CanEquipedAppearanceByClientData(AppID)
                end
                Data.RegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(AppID)
                Data.Color = SuitItem.Color 
            end
        end

        if Data.CanEquiped then
            table.insert(DataList, Data)
        end
    end

    return DataList
end


function WardrobePresetsPanelVM:UpdateBtnStatus(PresetsID)
    local PresetInfo = WardrobeMgr:GetPresets(PresetsID) or WardrobeMgr:GetPresetsClient(PresetsID)

    local DataSaveServer = WardrobeMgr:GetPresets(PresetsID) ~= nil
    local CurSuitData = self:GetCurSuitData()
    local IsCurrendUsed = WardrobeMgr:GetUsedSuitID() == PresetsID

    if PresetsID == nil then
        -- 点击当前穿搭
        self.UsingBtnVisible = false
        self.UsingBtnStatus = false
        self.UseBtnVisible = false
        self.SaveBtnVisible = false
        self.RenameVisible = false
        self.AssocaitionVisible = false
        return
    end
    -- 预设套装PresetsID
    self.SaveBtnVisible = true
    self.AssocaitionVisible = DataSaveServer
    self.RenameVisible = DataSaveServer

    --self.UseBtnVisible 使用按钮
    --self.UsingBtnVisible 使用中按钮

    self.BtnUseText = IsCurrendUsed and _G.LSTR(1080065) or _G.LSTR(1080066)

    if DataSaveServer then
        -- 在服务器上有数据，判断两个按钮的显示
        _G.FLOG_INFO("WardrobePresetsPanelVM:UpdateBtnStatus  WardrobeMgr:GetPresets(PresetsID) ~= nil ")

        if IsCurrendUsed then
            -- 判断当前穿戴是否跟服务器的数据一直 不一致的
            local IsSame = WardrobeMgr:GetUsedSuitID() == PresetsID and WardrobeMgr:GetCurUsedSuitIsUsed(PresetsID, self:GetCurSuitData())
            self.UsingBtnVisible = IsSame
            self.UseBtnVisible = not IsSame
        else
            self.UsingBtnVisible = false
            self.UseBtnVisible = true
        end
    
        self.UsingBtnStatus = not IsCurrendUsed

    else
        -- 没有保存在服务器的预设套装，使用跟使用中都不显示
        self.UseBtnVisible = false
        self.UsingBtnVisible = false
    end

    -- 文字类数据
    if PresetInfo ~= nil and PresetInfo.RelatedProf ~= nil then
        self.AssociationCheck = (PresetInfo.RelatedProf ~= 0)
        if PresetInfo.RelatedProf ~= 0 then
            local ProfName = _G.EquipmentMgr:GetProfName(PresetInfo.RelatedProf)
            self.AssociationText = string.format(_G.LSTR(1080064), ProfName)
        else
            self.AssociationText =_G.LSTR(1080067)
        end
    else
        self.AssociationCheck = false
        self.AssociationText = _G.LSTR(1080067)
    end

    if PresetInfo ~= nil and PresetInfo.SuitName ~= nil then
        self.SuitName = PresetInfo.SuitName
    else
        self.SuitName = _G.LSTR(1080068)
    end

end

function WardrobePresetsPanelVM:UpdatePresetListByID(SuitID)
    for i = 1 , self.PresetsList:Length() do
        local ItemVM = self.PresetsList:Get(i)
        local ItemSuitID = ItemVM.ID
        if ItemSuitID ~= nil then
            local DataSuitsInfo = WardrobeMgr:GetPresets(ItemSuitID) or WardrobeMgr:GetPresetsClient(ItemSuitID)
            local Value = {}
            if DataSuitsInfo.RelatedProf == 0 then
                Value.ProfName  = DataSuitsInfo.SuitProfID == 0 and "" or string.format("%s%s", _G.EquipmentMgr:GetProfName(DataSuitsInfo.SuitProfID), _G.LSTR(1080105))
                Value.ProfVisible = DataSuitsInfo.SuitProfID and DataSuitsInfo.SuitProfID ~= 0
                Value.ProfColor = NormalColor
            else
                Value.ProfVisible = true
                Value.ProfColor = WarningColor
                Value.ProfName = string.format(_G.LSTR(1080064), _G.EquipmentMgr:GetProfName(DataSuitsInfo.RelatedProf) or "")
            end
            Value.PresetName = DataSuitsInfo.SuitName
            ItemVM:UpdateNameProf(Value)
        end

        if ItemSuitID ~= nil then
            ItemVM:UpdateCurSuitCheck(ItemSuitID == WardrobeMgr:GetUsedSuitID() and WardrobeMgr:GetPresets(ItemSuitID) ~= nil and WardrobeMgr:GetCurUsedSuitIsUsed(ItemSuitID, self:GetCurSuitData()))
        else
            ItemVM:UpdateCurSuitCheck(false)
        end
    end
end

--预设套装扩容
function WardrobePresetsPanelVM:UpdateEnlargePresetList(SuitID)
    local Length = self.PresetsList:Length()
    local Data = {}
    local DataSuitsInfo = WardrobeMgr:GetPresets(SuitID) or WardrobeMgr:GetPresetsClient(SuitID)
    local Cfg = ClosetPresetSuitCfg:FindCfgByKey(SuitID)
    if Cfg ~= nil then
        Data.ID = SuitID
        Data.IconVisible = true
        Data.DetailVisible = true
        Data.AddVisible = false
        Data.CurSuitCheck = false
        Data.Num = SuitID
        Data.ProfName = DataSuitsInfo ~= nil and _G.EquipmentMgr:GetProfName(DataSuitsInfo.RelatedProf) or ""
        Data.PresetName = Cfg ~= nil and Cfg.Name or ""
        Data.ProfVisible = false
        self.PresetsList:InsertByValue(Data, Length)
    end

    local Cfgs = ClosetPresetSuitCfg:FindAllCfg()
    if SuitID >= #Cfgs then
        local NewLength = self.PresetsList:Length()
        self.PresetsList:RemoveAt(NewLength)
    end
end


--要返回当前类
return WardrobePresetsPanelVM