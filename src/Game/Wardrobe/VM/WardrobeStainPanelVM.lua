--
-- Author: ZhengJianChuan
-- Date: 2024-03-01 20:03
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local ClosetColorClassifyCfg = require("TableCfg/ClosetColorClassifyCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local UIBindableList = require("UI/UIBindableList")
local WardrobePositionItemVM = require("Game/Wardrobe/VM/Item/WardrobePositionItemVM")
local WardrobeStainBallItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainBallItemVM")
local WardrobeStainBoxItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainBoxItemVM")
local WardrobeConsumeItemVM = require("Game/Wardrobe/VM/Item/WardrobeConsumeItemVM")
local WardrobeStainTabItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainTabItemVM")
local WardrobeStainStyleItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainStyleItemVM")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = _G.LSTR

---@class WardrobeStainPanelVM : UIViewModel
local WardrobeStainPanelVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainPanelVM:Ctor()
    self.AppearanceTabList = UIBindableList.New(WardrobePositionItemVM)
    self.ColorTabList = UIBindableList.New(WardrobeStainBallItemVM)
    self.ColorList = UIBindableList.New(WardrobeStainBoxItemVM)
    self.ColorAreaList = UIBindableList.New(WardrobeStainTabItemVM)
    self.ColorOftenList = UIBindableList.New(WardrobeStainStyleItemVM)
	self.SubTitleName = "" 
	self.AppearanceName = ""
	self.CurColorName = ""
	self.CurColor = ""
    self.CurColorVisible = false
	self.BtnUnlockTxt = ""
    self.StainTitle = ""
	self.ItemLackVisible =  false
    self.BtnUnlockVisible = true
	self.AppearanceTabVisible = true
    self.Consume2Visible = true
    self.Consume1Visible = true
    self.ConsumeVM1 = WardrobeConsumeItemVM.New()
    self.ConsumeVM2 = WardrobeConsumeItemVM.New()
    self.HorizontalConsumeVisible = true
    self.ColorListSelectedIndex = nil
    self.MoreOftenVisible = nil
    self.BtnBlockVisible = true
    self.BtnBlockChecked = true
    self.ShowOftenAll = false
    self.MoreOftenCheck = false
end

function WardrobeStainPanelVM:OnInit()
end

function WardrobeStainPanelVM:OnBegin()
end

function WardrobeStainPanelVM:OnEnd()
end

function WardrobeStainPanelVM:OnShutdown()
end

function WardrobeStainPanelVM:UpdateTitle(StainType)
    self.StainTitle = StainType == WardrobeDefine.StainType.TryStain and LSTR(1080071) or LSTR(1080062) 
end

function WardrobeStainPanelVM:UpdateSubTitle(ID)
    local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID)
    if not table.is_nil_empty(EquipmentCfgs) then
        local Item = EquipmentCfgs[1]
        self.SubTitleName = ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, Item.Part)
    end
end

function WardrobeStainPanelVM:GetPart(ID)
    local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID)
    if not table.is_nil_empty(EquipmentCfgs) then
        local Item = EquipmentCfgs[1]
        return Item.Part
    end
end

function WardrobeStainPanelVM:InitColorTabList()
    self.ColorTabList:Clear()
    local TempDataList = {}
    local Type = WardrobeDefine.ColorTypeList
    for i = 1, 8, 1 do
        local Data = {}
        Data.ID = Type[i]
        Data.Type = Type[i]
        Data.ColorType = i
        Data.IsMetal = i == 8
        table.insert(TempDataList, Data)
    end

    self.ColorTabList:UpdateByValues(TempDataList)
end

function WardrobeStainPanelVM:UpdateColorList(StainType, ColorTypeID, ApperanceID, StainAreaID)
    self.ColorList:Clear()
    
    local DataList = {}
    local Cfgs = DyeColorCfg:FindCfgByTypeID(ColorTypeID)
    local CfgList = {}
    local TryStain = StainType == WardrobeDefine.StainType.TryStain

    local RealLen = 0
    for _, v in ipairs(Cfgs) do 
       if WardrobeMgr:BeIncludedInGameVersion(v.VersionName) then
            RealLen = RealLen + 1
            table.insert(CfgList, v)
       end
    end

    local Len =  RealLen < 25 and 25 or math.ceil(RealLen / 5) * 5
    
    if RealLen == 0 then
        return
    end

    for i = 1, Len do
        local Data = {}
        local value = CfgList[i]
        if CfgList[i] ~= nil then
            Data.ID = (value and value.ID) and value.ID or 0
            Data.ColorVisible = true
            Data.IsNormalcy = value.bMetal == 0
            Data.IsMetal = ColorTypeID == 8
            if TryStain then
                Data.IsColorUnlock = false
                Data.IsChecked = false
            else
                local ColorID = WardrobeMgr:GetIsClothing(ApperanceID) and WardrobeMgr:GetCurAppearanceDyeColor(ApperanceID, StainAreaID) or WardrobeMgr:GetDyeColor(ApperanceID, StainAreaID)
                Data.IsChecked = ColorID == value.ID
                Data.IsColorUnlock = not WardrobeMgr:IsActiveColor(ApperanceID, value.ID)
            end
            Data.Color = WardrobeUtil.Dec2HexColor(value.Color)
            Data.IsSelected = false
            table.insert(DataList, Data)
        else
            Data.ID = 0
            Data.IsNormalcy = false
            Data.IsMetal = false
            Data.IsColorUnlock = false
            Data.IsChecked = false
            Data.ColorVisible = false
            Data.IsSelected = false
            table.insert(DataList, Data)
        end
    end
    self.ColorList:UpdateByValues(DataList)
end

function WardrobeStainPanelVM:UpdateCurColorInfo(CurColorID)
    if CurColorID == 0 or CurColorID == nil then
        self.CurColorName = LSTR(1080053)
        self.CurColorVisible = false
        return
    end

    local ColorCfg = DyeColorCfg:FindCfgByKey(CurColorID)
    if ColorCfg ~= nil then
        self.CurColorName = ColorCfg.DisplayName
        self.CurColor = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
        self.CurColorVisible = true
    end
end

function WardrobeStainPanelVM:UpdateCurAppearanceInfo(AppearanceID)
    self.AppearanceName = WardrobeUtil.GetEquipmentAppearanceName(AppearanceID)
end

function WardrobeStainPanelVM:UpdateBtnUnlockState(StainType, AppID, ColorID, SectionID)
    if StainType == WardrobeDefine.StainType.TryStain then
        return
    end
    
    local CurColorID = WardrobeMgr:GetIsClothing(AppID) and WardrobeMgr:GetCurAppearanceDyeColor(AppID, SectionID) or WardrobeMgr:GetDyeColor(AppID, SectionID)
    local Actived = WardrobeMgr:IsActiveColor(AppID, ColorID)

    if CurColorID ~= 0 then
        if Actived then
            self.BtnUnlockTxt = ColorID == CurColorID and LSTR(1080072) or LSTR(1080062)   -- 取消染色， 染色
        else
            self.BtnUnlockTxt = LSTR(1080061)   -- 解锁
        end
    else
        if Actived or ColorID == 0 then
            self.BtnUnlockTxt = LSTR(1080062)   --染色
        else
            self.BtnUnlockTxt = LSTR(1080061) -- 解锁
        end
    end

end

function WardrobeStainPanelVM:UpdateColorListUnlockState(StainType, AppearanceID, SectionID)
    local TryStain = StainType == WardrobeDefine.StainType.TryStain
    for i = 1, self.ColorList:Length() do
		local ItemVM = self.ColorList:Get(i)
        if ItemVM ~= nil then
            if TryStain then
                ItemVM:UpdateUnlockState(false)
                ItemVM:UpdateCheckedState(false)
            else
                ItemVM:UpdateUnlockState(not WardrobeMgr:IsActiveColor(AppearanceID, ItemVM.ID))
                local ColorID = WardrobeMgr:GetIsClothing(AppearanceID) and WardrobeMgr:GetCurAppearanceDyeColor(AppearanceID, SectionID)  or WardrobeMgr:GetDyeColor(AppearanceID, SectionID)
                ItemVM:UpdateCheckedState(ColorID == ItemVM.ID)
            end
        end
	end
end

-- 初始化左边菜单栏
function WardrobeStainPanelVM:InitAppearanceTabList(CurrentList)
    self.AppearanceTabList:Clear()
    local DataList = {}
						
    for _, partID in ipairs(WardrobeDefine.EquipmentTab) do				
        for _, AppID in ipairs(CurrentList) do				
            local CurPart = WardrobeUtil.GetPartByAppearanceID(AppID)				
            if CurPart == partID then				
                local DyeEnable = WardrobeMgr:GetDyeEnable(AppID)				
                if DyeEnable then				
                    local Data = self:CreateAppearanceTabItem(AppID)				
                    if Data ~= nil then				
                        table.insert(DataList, Data)				
                    end				
                end				
            end				
        end				
    end				
				
    self.AppearanceTabList:UpdateByValues(DataList)
end

-- 更新左边菜单栏
function WardrobeStainPanelVM:UpdateAppearanceTabList()
    for i = 1, self.AppearanceTabList:Length() do
        local ItemVM = self.AppearanceTabList:Get(i)
        if ItemVM ~= nil then
            local Data = self:CreateAppearanceTabItem(ItemVM.ID) 
            ItemVM:UpdateVM(Data)
        end
    end
end

-- 创建左边菜单栏item
function WardrobeStainPanelVM:CreateAppearanceTabItem(AppID)
    if AppID == nil  then
        return 
    end

    local Data = {}
	Data.ID = AppID
	Data.StateIcon = WardrobeUtil.GetEquipmentAppearanceIcon(AppID)
	Data.StainTagVisible = true
    local ColorID = WardrobeMgr:GetIsClothing(AppID) and WardrobeMgr:GetCurAppearanceDyeColor(AppID)  or WardrobeMgr:GetDyeColor(AppID)
    local Cfg = DyeColorCfg:FindCfgByKey(ColorID)
    if Cfg ~= nil then
	    Data.StainColor = WardrobeUtil.Dec2HexColor(Cfg.Color)
    end
	Data.StainColorVisible = WardrobeMgr:GetIsDye(AppID)
    return Data
end

-- 初始化左边染色区域栏
function WardrobeStainPanelVM:InitColorAeraList(AppID)
    local ColorAreaList = {}
    
    local Cfg = ClosetCfg:FindCfgByKey(AppID)
    
    if Cfg == nil then
        _G.FLOG_INFO(string.format("WardrobeStainPanelVM:InitColorAeraList AppID %d Is Nil ", AppID))
        return
    end

    local StainViewSuit = WardrobeMgr:GetStainViewSuitByAppID(AppID)
    local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
    local StainColor = IsAppRegionDye and WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainViewSuit.RegionDye) or StainViewSuit.Color
    local IsMetal = false

    local DCCfg = DyeColorCfg:FindCfgByKey(StainColor)
    if DCCfg ~= nil and DCCfg.Type == 8 then
        IsMetal = true
    end

    local Temp = {
        ID = -1,
        Name = LSTR(1080037),
        IsMetal = IsMetal,
        Color =  WardrobeUtil.GetColor(StainColor),
    }

    table.insert(ColorAreaList, Temp)
    self.ColorAreaList:Clear()
    if Cfg ~= nil then
        for index, v in ipairs(Cfg.StainAera) do
            if v.List ~= "" and v.Ban ~= 1 then
                local Item = {}
                Item.ID = index
                Item.Name = v.Name
                Item.List = v.List
                local Color = WardrobeUtil.GetRegionDyeColor(StainViewSuit.RegionDye, index)
                Item.Color = WardrobeUtil.GetColor(Color)
                local SocketIsMetal = false
                local DCCfg = DyeColorCfg:FindCfgByKey(Color)
                if DCCfg ~= nil and DCCfg.Type == 8 then
                    SocketIsMetal = true
                end
                Item.IsMetal = SocketIsMetal
                table.insert(ColorAreaList, Item)
            end
        end
    end

    self.ColorAreaList:UpdateByValues(ColorAreaList)
end

function WardrobeStainPanelVM:UpdateColorAeraList(AppID, PartID, SectionID)
    local StainViewSuit = WardrobeMgr:GetStainViewSuitByAppID(AppID)

    for i = 1, self.ColorAreaList:Length(), 1 do
        if i == 1 then
            local ItemData = self.ColorAreaList:Get(i)
            if ItemData ~= nil then
                local Color = WardrobeUtil.IsAppRegionDye(AppID) and WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainViewSuit.RegionDye) or StainViewSuit.Color
                ItemData:UpdateColor(Color)
            end
            break
        end
    end

    for i = 1,  self.ColorAreaList:Length(), 1 do
        local ItemData = self.ColorAreaList:Get(i)
        if i ~= 1 and ItemData ~= nil then
            if SectionID == -1 then
                local ColorID = WardrobeUtil.GetUnifyRegionDyeColor(AppID, StainViewSuit.RegionDye) or StainViewSuit.Color
                ItemData:UpdateColor(ColorID)
            else
                if ItemData.ID == SectionID then
                    for _, v in ipairs(StainViewSuit.RegionDye) do
                        if v.ID == SectionID then
                            ItemData:UpdateColor(v.ColorID)
                            break
                        end
                    end
                end
            end
        end
    end
end

function WardrobeStainPanelVM:InitColorOftenList()
    local TempList = {}
    local UsedStainList = WardrobeMgr:GetUsedStainList()
    local LimitNum = self.ShowOftenAll and 5 or 3
    for index, value in ipairs(UsedStainList) do
        if index <= LimitNum then
            local Temp = {}
            Temp.ID = value.ID
            local ColorCfg  = DyeColorCfg:FindCfgByKey(value.ID)
            Temp.Color = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
            table.insert(TempList, Temp)
        end
    end
    self.ColorOftenList:UpdateByValues(TempList)
    self.MoreOftenVisible = #UsedStainList > 3
end

function WardrobeStainPanelVM:UpdateColorOfenList(bDir)
    local UsedStainList = WardrobeMgr:GetUsedStainList()
    local TempList = {}
    if bDir then
        self.ColorOftenList:Clear()
        for index, value in ipairs(UsedStainList) do
            local Temp = {}
            Temp.ID = value.ID
            local ColorCfg  = DyeColorCfg:FindCfgByKey(value.ID)
            Temp.Color = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
            table.insert(TempList, Temp)
        end
        self.ColorOftenList:UpdateByValues(TempList)
    else
        -- 递减
        for i = self.ColorOftenList:Length(), 1, -1 do
            if i > 3 then
                self.ColorOftenList:RemoveAt(i)
            end
        end
    end
end


--要返回当前类
return WardrobeStainPanelVM