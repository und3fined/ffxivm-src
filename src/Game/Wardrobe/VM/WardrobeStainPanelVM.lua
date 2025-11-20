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
    self.CurColorIsMetal = false
	self.BtnUnlockTxt = ""
    self.StainTitle = ""
	self.ItemLackVisible =  false
    self.PanelUnlockVisible = nil
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
    self.ActiveColor = false
    self.SectionName = ""
    self.ReNameBtnVisible = nil
    -- <PartID, AppID, ColorID, RegionDye>
    self.StainSuit = {}  -- 染色界面数据
    self.PreStainSuit = {} -- 预染色数据
end

function WardrobeStainPanelVM:OnInit()
end

function WardrobeStainPanelVM:OnBegin()
end

function WardrobeStainPanelVM:OnEnd()
end

function WardrobeStainPanelVM:OnShutdown()
end

function WardrobeStainPanelVM:ClearStainSuit()
    self.StainSuit = {}
end

function WardrobeStainPanelVM:SetStainSuit(PartID, AppID, ColorID, RegionDye)
    if PartID  == nil then
        return
    end

    if self.StainSuit[PartID] == nil then
		self.StainSuit[PartID] = {}
		self.StainSuit[PartID].Avatar = AppID
		self.StainSuit[PartID].Color = ColorID
		self.StainSuit[PartID].RegionDye = RegionDye
		return
	end

	for key, value in pairs(self.StainSuit) do
		if tonumber(key) == PartID then
			self.StainSuit[PartID].Avatar = AppID
			self.StainSuit[PartID].Color = ColorID
			self.StainSuit[PartID].RegionDye = RegionDye
		end
	end
end

function WardrobeStainPanelVM:GetStainSuit()
    return self.StainSuit
end

function WardrobeStainPanelVM:GetStainSuitByAppID(AppID)
    for _, v in pairs(self.StainSuit) do
		if v.Avatar == AppID then
			return v
		end
	end
	return  {}
end

function WardrobeStainPanelVM:ClearPreStainSuit()
    self.PreStainSuit = {}
end

function WardrobeStainPanelVM:SetPreStainSuit(PartID, AppID, ColorID, RegionDye)
    if PartID  == nil then
        return
    end
    if self.PreStainSuit[PartID] == nil then
		self.PreStainSuit[PartID] = {}
		self.PreStainSuit[PartID].Avatar = AppID
		self.PreStainSuit[PartID].Color = ColorID
		self.PreStainSuit[PartID].RegionDye = RegionDye
		return
	end

	for key, value in pairs(self.PreStainSuit) do
		if tonumber(key) == PartID then
			self.PreStainSuit[PartID].Avatar = AppID
			self.PreStainSuit[PartID].Color = ColorID
			self.PreStainSuit[PartID].RegionDye = RegionDye
		end
	end

end

function WardrobeStainPanelVM:GetPreStainSuit()
    return self.PreStainSuit
end

function WardrobeStainPanelVM:GetPreStainSuitByAppID(AppID)
    for _, v in pairs(self.PreStainSuit) do
		if v.Avatar == AppID then
			return v
		end
	end
	return  {}
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

    local IsClothing = WardrobeMgr:GetIsClothing(ApperanceID)
    local ColorID = IsClothing and WardrobeMgr:GetCurAppearanceDyeColor(ApperanceID, StainAreaID) or WardrobeMgr:GetDyeColor(ApperanceID, StainAreaID)
    local IsSame = WardrobeMgr:IsSameColorRegionDye(ApperanceID, 0)
    -- 创建一个原色
    local TempData  = {}
    TempData.ID = 0
    TempData.IsNormalcy = true
    TempData.IsMetal = false
    TempData.IsColorUnlock = false
    TempData.IsChecked = ColorID == 0 and IsSame and not TryStain
    TempData.IsSelected = false
    table.insert(DataList, TempData)

    for i = 1, Len - 1 do
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
                Data.IsChecked = ColorID == value.ID
                Data.IsColorUnlock = not WardrobeMgr:IsActiveColor(ApperanceID, value.ID)
            end
            Data.Color = WardrobeUtil.Dec2HexColor(value.Color)
            Data.IsSelected = false
            table.insert(DataList, Data)
        else
            -- 空格子
            Data.ID = -1
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
        self.CurColorIsMetal = false
        return
    end

    local ColorCfg = DyeColorCfg:FindCfgByKey(CurColorID)
    if ColorCfg ~= nil then
        self.CurColorName = ColorCfg.DisplayName
        self.CurColor = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
        self.CurColorIsMetal = ColorCfg.Type == 8
        self.CurColorVisible = true
    else
        self.CurColorIsMetal = false
    end
end

function WardrobeStainPanelVM:UpdateCurAppearanceInfo(AppearanceID)
    self.AppearanceName = WardrobeUtil.GetEquipmentAppearanceName(AppearanceID)
end

function WardrobeStainPanelVM:UpdateCurAppearanceSeationName(StainType, AppearanceID, SectionID)
    if  StainType == WardrobeDefine.StainType.TryStain then
        self.ReNameBtnVisible = false
        return
    end
    if SectionID == -1 then
        self.SectionName = LSTR(1080037)
        self.ReNameBtnVisible = false
    else
        -- Todo 获取当前区域名字
        self.SectionName = WardrobeMgr:GetUnlockedAppearanceRegionName(AppearanceID, SectionID)
        self.ReNameBtnVisible = true
    end
end

function WardrobeStainPanelVM:UpdateBtnUnlockState(StainType, AppID, ColorID, SectionID)
    if StainType == WardrobeDefine.StainType.TryStain then
        return
    end
    local CurColorID = WardrobeMgr:GetIsClothing(AppID) and WardrobeMgr:GetCurAppearanceDyeColor(AppID, SectionID) or WardrobeMgr:GetDyeColor(AppID, SectionID)
    local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)

    if ColorID == 0 then
        if SectionID == -1 then
            if  not  IsAppRegionDye then
            self.BtnUnlockTxt = CurColorID == ColorID and LSTR(1080072) or LSTR(1080154) --染为原色
            else
                
                self.BtnUnlockTxt = WardrobeMgr:IsSameColorRegionDye(AppID, ColorID) and LSTR(1080072) or LSTR(1080154)
            end
        else
            self.BtnUnlockTxt = CurColorID == ColorID and LSTR(1080072) or LSTR(1080154)
        end
    else
        self.BtnUnlockTxt = ColorID == CurColorID and LSTR(1080072) or LSTR(1080062)   -- 取消染色， 染色
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
                local ColorID = WardrobeMgr:GetIsClothing(AppearanceID) and WardrobeMgr:GetCurAppearanceDyeColor(AppearanceID, SectionID) or WardrobeMgr:GetDyeColor(AppearanceID, SectionID)
                if SectionID == nil then
                    ItemVM:UpdateCheckedState(ColorID == ItemVM.ID and  WardrobeMgr:IsSameColorRegionDye(AppearanceID, ColorID))
                else
                    ItemVM:UpdateCheckedState(ColorID == ItemVM.ID)
                end
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
    if WardrobeMgr:GetIsClothing(AppID) then
        Data.StainColorVisible =  WardrobeMgr:GetCurrentIsDye(AppID)
    else
        Data.StainColorVisible =  WardrobeMgr:GetIsDye(AppID)
    end
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


    local ColorAeraAllColor = WardrobeMgr:GetDyeColor(AppID)
    local PreStainView = self:GetPreStainSuitByAppID(AppID)

    local PreviewColorAreaAllColor =  WardrobeUtil.IsAppRegionDye(AppID) and WardrobeUtil.GetUnifyRegionDyeColor(AppID, PreStainView.RegionDye) or PreStainView.Color
    self.ColorAreaList:Clear()
    local Temp = {
        ID = -1,
        SocketID = -1,
        Name = LSTR(1080037),
        AppID = AppID,
        ColorID = ColorAeraAllColor,
        PreColorID = PreviewColorAreaAllColor,
    }
    table.insert(ColorAreaList, Temp)
    if Cfg ~= nil then
        for i = #Cfg.StainAera, 1, -1 do
            local v = Cfg.StainAera[i]
            if v.List == "" or v.Ban == 1 then
                table.remove(Cfg.StainAera, i)
            end
        end
        for index, v in ipairs(Cfg.StainAera) do
            local Item = {}
            Item.SocketID = v.SocketID
            Item.ID = index
            Item.AppID = AppID
            Item.Name = WardrobeMgr:GetUnlockedAppearanceRegionName(AppID, index)
            Item.List = v.List
            local Color = WardrobeMgr:GetDyeColor(AppID, index)
            Item.ColorID = Color
            local PreColor = self:GetPreColor(AppID, index) -- 预览色
            Item.PreColorID = PreColor -- 预览色
            table.insert(ColorAreaList, Item)
        end
    end

    self.ColorAreaList:UpdateByValues(ColorAreaList)
end

function WardrobeStainPanelVM:GetPreColor(AppID, SectionID)
    local PreStainView = self:GetPreStainSuitByAppID(AppID)

    for _, v in ipairs(PreStainView.RegionDye) do
        if v.ID == SectionID then
            return v.ColorID
        end
    end

    return 0
end

function WardrobeStainPanelVM:UpdateColorAeraList(AppID, SectionID)
    local PreStainView = self:GetPreStainSuitByAppID(AppID)

    for i = 1, self.ColorAreaList:Length(), 1 do
        if i == 1 then
            local ItemData = self.ColorAreaList:Get(i)
            if ItemData ~= nil then
                local Color = WardrobeMgr:GetDyeColor(AppID)
                local PreColor = WardrobeUtil.IsAppRegionDye(AppID) and WardrobeUtil.GetUnifyRegionDyeColor(AppID, PreStainView.RegionDye) or PreStainView.Color
                ItemData:UpdateColor(Color)
                ItemData:UpdatePreColor(PreColor)
            end
            break
        end
    end

    -- 全部的时候 直接用当前的覆盖
    if SectionID == -1 then
        for i = 1, self.ColorAreaList:Length(), 1 do
            local ItemData = self.ColorAreaList:Get(i)
            if i > 1 and ItemData ~= nil then
                local ColorID = WardrobeMgr:GetDyeColor(AppID, ItemData.ID)
                ItemData:UpdateColor(ColorID)
                for _, v in ipairs(PreStainView.RegionDye) do
                    local PreColor = v.ColorID
                    ItemData:UpdatePreColor(PreColor)
                end
            end
        end
    else
        for i = 1, self.ColorAreaList:Length(), 1 do
            local ItemData = self.ColorAreaList:Get(i)
            if i > 1 and ItemData ~= nil then
                if ItemData.ID == SectionID then 
                    local ColorID = WardrobeMgr:GetDyeColor(AppID, ItemData.ID)
                    ItemData:UpdateColor(ColorID)
                    for _, v in ipairs(PreStainView.RegionDye) do
                        if v.ID == SectionID then
                            local PreColor = v.ColorID
                            ItemData:UpdatePreColor(PreColor)
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
            Temp.IsUnlock = true
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
            Temp.IsUnlock = true
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

function WardrobeStainPanelVM:IsPreviewEmpty(AppID)
    local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
    local StainView = self:GetStainSuitByAppID(AppID)
    local PreView = self:GetPreStainSuitByAppID(AppID)

    if not IsAppRegionDye then
        return StainView.ColorID == PreView.ColorID
    end

    for index, v in ipairs(StainView.RegionDye or {}) do
        local PreViewRegionDye = PreView.RegionDye
        if not table.is_nil_empty(PreViewRegionDye) then
            if PreViewRegionDye[index] ~= nil and PreViewRegionDye[index].ID ~= nil and PreViewRegionDye[index].ColorID ~= nil then 
              if PreViewRegionDye[index].ID == v.ID and PreViewRegionDye[index].ColorID ~= v.ColorID then
                    return false
              end
            end
        end
    end
    return true
end


--要返回当前类
return WardrobeStainPanelVM