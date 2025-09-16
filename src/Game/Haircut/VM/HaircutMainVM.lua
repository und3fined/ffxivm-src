local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ProtoCommon = require("Protocol/ProtoCommon")
--local MajorUtil = require("Utils/MajorUtil")

local LoginCreatePrefixItemVM = require("Game/LoginCreate/LoginCreatePrefixItemVM")
local LoginCreateSlotItemVM = require("Game/LoginCreate/LoginCreateSlotItemVM")
local LoginCreateColorItemVM = require("Game/LoginCreate/LoginCreateColorItemVM")
local LoginCreateTextSlotItemVM = require("Game/LoginCreate/LoginCreateTextSlotItemVM")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = _G.LSTR
local HaircutMgr = nil
local LoginAvatarMgr = nil
local LoginUIMgr = nil

---@class HaircutMainVM : UIViewModel
local HaircutMainVM = LuaClass(UIViewModel)


function HaircutMainVM:Ctor()
    HaircutMgr = _G.HaircutMgr
    LoginAvatarMgr = _G.LoginAvatarMgr
    LoginUIMgr = _G.LoginUIMgr
    self.bShowNormalMenue = true -- 第一级页签状态
    self.MainCfgList = {} -- 第一级菜单
    self.ListMainMenuVM = {}
    self.ListSubMenuVM = {}  -- 二级页签列表
    self.PreSelectSubIndex = 1 -- 上一步的页签
    self.MainType = 1
    self.SubType = 1
    self.SubTitleText = "妆容"

    -- 右屏自定义数据的控件的显隐
    self.bShowPanelFace = false -- 图片列表
    self.bShowFlip = false  -- 反转选项
    self.bFlip = false -- 是否反转
    self.bShowHairText = false -- 是否显示已解锁发型的介绍
    self.bShowUnlock = false -- 解锁发型的部分
    self.bUseUnlock = false -- 是否用到解锁发型
    self.HairText = nil -- 已解锁发型的介绍
    self.UnLockItemID = nil --消耗道具ID
    self.UnlockItemNum = 0 -- 解锁道具数量
    self.LockText = nil -- 解锁数量文本
    self.UnLockItemIcon = nil
    self.bUseLockHair = false -- 是否使用未解锁的发型
    self.bLockBtnEnable = false

    self.bShowPanelColor = false -- 色板
    self.bShowWordPanel = false -- 色板上种类多选框
    self.bShowBtnNone = false -- 色板上"无"选项
    self.bShowColorTable = true
   
    self.bShowPanelType = false -- 类型选择

    self.bShowLongSwitch = false -- 展开切换框
    self.bShowShortSwitch = false -- 正常切换框
    self.bShowSwitch = false

    -- 图片列表
    self.ListFaceTableVM = nil
    self.HairFaceTableVM = nil
    self.FaceTableSize = _G.UE.FVector2D(408, 774) -- _G.UE.FVector2D(408, 693)
    self.FaceTableNum = 0

    -- 色号列表
    self.ListColorTableVM = nil
    self.FullColorTableVM = nil
    self.ListWorldTableVM = nil
    --self.ListWorldState = nil -- 多选图片列表状态
    --self.VerticalDifferSize = _G.UE.FVector2D(451, 722) -- _G.UE.FVector2D(840, 722)
    --self.ColorTableSize = _G.UE.FVector2D(450, 728)
    self.bExpanded = false -- 展开面板
    self.bLightColor = false

    -- 类型列表
    self.ListTypeTableVM = nil

    -- 是否在操作副属性
    self.bOperateSub = false
    -- 检测预设数据是否变化
    self.DefaultCustomData = nil

    -- 属性数据设置为无
    self.bParamNone = false

    -- 数据和选中状态映射列表
    self.DataStateList = {} -- {Type: {Value: TableIndex}}
    self.FaceTableIndex = nil
    self.TypeTableIndex = nil
    self.ColorTableIndex = nil
    self.HairTableIndex = nil

    self.SelectedFaceIndex = 1 -- 选中的脸型

    self.bShowSuitTips = false

    self.bMultiSelect = false

end
-- 部分数据初始化
function HaircutMainVM:InitViewData()
    self.bShowSuitTips = HaircutMgr:GetSuitTips()
    LoginAvatarMgr:SetSystemType(LoginAvatarMgr.FaceSystemType.Haircut)
    HaircutMgr:InitAvatarFace()

    self.bShowNormalMenue = true
    LoginAvatarMgr:ResetParam("CurFocusType", false)
    LoginAvatarMgr:ResetRecordList()
    LoginAvatarMgr:InitMenuData()
    --LoginAvatarMgr:InitColorData()
    LoginAvatarMgr:InitUIColorData()
    --LoginAvatarMgr:InitRaceHeight()
    LoginAvatarMgr:ModelMoveToLeft(false, false)
    self.bExpanded = false

    self:UpdateRoleFace()
end

function HaircutMainVM:UnInitViewData()
    -- 移动模型
    LoginAvatarMgr:ModelMoveToLeft(false, true)
    --local AvatarFace = LoginAvatarMgr:GetCurAvatarFace()
    --if AvatarFace == nil or self.DefaultCustomData == nil then return end
    --local CurAvatarFace = table.clone(AvatarFace)
    --if not table.compare_table(self.DefaultCustomData, CurAvatarFace) then
        --LoginAvatarMgr:RefreshPlayerAvatarFace()
    --end
    LoginAvatarMgr:SetCameraFocus(0, true)
end

function HaircutMainVM:SetMainType(MenueType)
    self.MainType = MenueType
    -- if MenueType == LoginAvatarMgr.CustomizeMainMenu.Decorate then
    --     self.SubTitleText = _G.LSTR("妆容")
    -- else
    --     self.SubTitleText = _G.LSTR("头发")
    -- end
end

function HaircutMainVM:InitMainType()
    local MainList = {}
    local IconNames = { "Hair", "Eye"}
    for Index, Name in ipairs(IconNames) do
        -- UI_Haircut_Icon_Hair_Focus_png
        local NormalIcon = string.format("PaperSprite'/Game/UI/Atlas/Haircut/Frames/UI_Haircut_Icon_%s_Normal_png.UI_Haircut_Icon_%s_Normal_png'", Name, Name)
        local FocusIcon = string.format("PaperSprite'/Game/UI/Atlas/Haircut/Frames/UI_Haircut_Icon_%s_Focus_png.UI_Haircut_Icon_%s_Focus_png'", Name, Name)
        local Look = {UnCheckIcon = NormalIcon, CheckIcon = FocusIcon}
        MainList[Index] = Look
    end
    self.MainCfgList = MainList
end

function HaircutMainVM:GetMainMenuData()
    local ListData = {}
    local IconNames = { "Hair", "Eye"}
    for _, Name in ipairs(IconNames) do
        -- UI_Haircut_Icon_Hair_Focus_png
        local NormalIcon = string.format("Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Haircut_%s_Normal.UI_Icon_Tab_Haircut_%s_Normal'", Name, Name)
        local FocusIcon = string.format("Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Haircut_%s_Select.UI_Icon_Tab_Haircut_%s_Select'", Name, Name)
        local Data = {}
        Data.IconPath = NormalIcon
        Data.SelectIcon = FocusIcon
        Data.bShowlock = false
        Data.ModuleID = ProtoCommon.ModuleID.ModuleIDBarberShop
        table.insert(ListData, Data)
    end
    return ListData
end

-- 二级页签列表更新
function HaircutMainVM:UpdateSubMenu(MainTile)
    local TileList = LoginAvatarMgr:GetSubMenuList(MainTile)
    if TileList  == nil then return end
    LoginUIMgr.LoginReConnectMgr:SaveValue("HairCutSubMenu", MainTile)
    
    local ListSlotVMp = {}
    for _, List in ipairs(TileList) do
        if List.bCanHaircut == 1 then
            local PrefixItemVM = LoginCreatePrefixItemVM.New()
            PrefixItemVM:SetItemData(List)
            ListSlotVMp[#ListSlotVMp + 1] = PrefixItemVM
        end
    end
    self.ListSubMenuVM = ListSlotVMp
    self.SubTitleText = MainTile
end

-- 二级页签所选状态更新
function HaircutMainVM:UpdateSubMenuSelected(Index)
    if self.ListSubMenuVM[Index] == nil then
        return
    end
    LoginUIMgr.LoginReConnectMgr:SaveValue("HairCutSubMenuSelect", Index)
    self.ListSubMenuVM[Index]:SetItemSelected(true)

    local LastIndex = self.PreSelectSubIndex
    if LastIndex ~= Index and self.ListSubMenuVM[LastIndex] ~= nil then 
        self.ListSubMenuVM[LastIndex]:SetItemSelected(false)
    end
    self.PreSelectSubIndex = Index

    self.SubType = self.ListSubMenuVM[Index].SubType
    -- 各个属性设置
    self:InitRightWidget()
    self:DealTypeFunc()

    -- 相机镜头变化
    LoginAvatarMgr:SetCameraFocus(self.SubType, false, true)

    -- 子菜单标题
    --LoginUIMgr:SetSubTitle(self.ListSubMenuVM[Index].TextTitle)
end
function HaircutMainVM:DealTypeFunc()
    local SubType = self.SubType
    if SubType == LoginAvatarMgr.CustomizeSubType.Ear or SubType == LoginAvatarMgr.CustomizeSubType.Tail then
        self.bShowShortSwitch = true
    end
    if self.MainType == LoginAvatarMgr.CustomizeMainMenu.Eye then
        self:SelectFacialFeature()
        return
    end
    if SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
        self:SelectHairDo()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.PupilSize then
        self:SelectPupilSize()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.EyeColor or SubType == LoginAvatarMgr.CustomizeSubType.FaceDecalColor then
        self:SelectDoubleColor(true, false)
    elseif SubType == LoginAvatarMgr.CustomizeSubType.HairColor then
        self:SelectDoubleColor(true, true)
    elseif SubType == LoginAvatarMgr.CustomizeSubType.LipColor then
        self.bShowBtnNone = true
        self:SelectDoubleColor(true, false)
    elseif SubType == LoginAvatarMgr.CustomizeSubType.FaceDecal then
        self:SetFaceDecal()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.PupilContour or SubType == LoginAvatarMgr.CustomizeSubType.Tattoo or 
           SubType == LoginAvatarMgr.CustomizeSubType.TattooDecor or SubType == LoginAvatarMgr.CustomizeSubType.Earring then
        self:SetPreOption()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.ScaleJewelry or SubType == LoginAvatarMgr.CustomizeSubType.FaceScar then
        self:SetLastOption()
    end

end

-- 关闭右屏控件
function HaircutMainVM:InitRightWidget()

    -- 图片选择框
    self.bShowPanelFace = false
    self.bShowFlip = false
    --self.bUseUnlock = false
    self.bShowUnlock = false
    self.bShowHairText = false

    -- 色板内细节
    self.bShowPanelColor = false
    self.bShowWordPanel = false
    self.bShowBtnNone = false
    --self.bExpanded = false
    self.bLightColor = false
    self.bShowColorTable = true

    -- 类型选择
    self.bShowPanelType = false

    -- 滑动条
    self.bShowPanelHeight = false
    self.bShowTextHeight = false

    -- 切换按钮
    self.bShowLongSwitch = false
    self.bShowShortSwitch = false
    self.bShowSwitch = false

    self.bOperateSub = false

    self.FaceTableSize = _G.UE.FVector2D(408, 774)

    self.bParamNone = false
    self.bMultiSelect = false

end

-- 切换控件操作
function HaircutMainVM:UpdateSwitchSelected(bLeft, LeftName, RightName)
    self.bOperateSub = not bLeft
    self[LeftName] = bLeft
    self[RightName] = not bLeft
end

function HaircutMainVM:UpdateParamSwitchSelected(bLeft)
    local bSwitchChanged = self.bOperateSub == bLeft
    self.bOperateSub = not bLeft
    LoginUIMgr.LoginReConnectMgr:SaveValue("HairCutColorIsLeft", bLeft)
    local IsShowBtnNone = (self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor and (not bLeft)) or (self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor)
    if IsShowBtnNone then
        self.bShowBtnNone = true
    else
        self.bShowBtnNone = false
    end
    if self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor or self.SubType == LoginAvatarMgr.CustomizeSubType.FaceDecalColor then
        self.bLightColor = not bLeft
        local PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
        local ColorValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
        if self.bLightColor and ColorValue > 0 then
            ColorValue = ColorValue < 127 and (ColorValue + 128) or ColorValue
        else
            ColorValue = ColorValue > 127 and (ColorValue - 128) or ColorValue
        end
        self:SetAvatarCustomizeByPart(PartKey, ColorValue, bSwitchChanged)
    end
    local bRaceColor = false
    if self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor and bLeft then
        bRaceColor = true
    end
    self:SelectDoubleColor(bLeft, bRaceColor)
end
-- 图片选择列表操作
function HaircutMainVM:UpdateFaceTableSelected(Index)
    if self.ListFaceTableVM == nil then return end
    local FaceTableItem = self.ListFaceTableVM[Index]
    -- 设置角色数据
    local PartKey = self:GetPropertyKey()
    -- 单选直接传值
    if FaceTableItem.IsSingSelect == true then
        local Value = FaceTableItem.DataValue
       self:SetAvatarCustomizeByPart(PartKey, Value)
    end
    self.FaceTableIndex = Index
    
    -- 记录一下选的脸型
    if self.SubType == LoginAvatarMgr.CustomizeSubType.FaceBase then
        self.SelectedFaceIndex = Index
    end

    -- 处理特殊发型问题
    if self.SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
        local HairVM = self.ListFaceTableVM[Index]
        self:UpdateHairItem(HairVM)
        self.ListFaceTableVM[Index].bCanUnlock = self.bLockBtnEnable
        self.HairFaceTableVM = table.clone(self.ListFaceTableVM)
        self.HairTableIndex = Index
    end
end

-- 处理特殊发型
function HaircutMainVM:UpdateHairItem(HairVM)
    if HairVM.bLocked == true then
        self.bShowHairText = false
        self.bUseUnlock = true
        self.bShowUnlock = true
        self.bLockBtnEnable = false
        -- 获取背包道具数量
        local UnlockCfg = HairUnlockCfg:FindCfgByID(HairVM.LockType)
        if UnlockCfg ~= nil then
            self.UnLockItemID = UnlockCfg.UnlockItemID
            self.UnlockItemNum = _G.BagMgr:GetItemNum(UnlockCfg.UnlockItemID)
            local IconID = ItemUtil.GetItemIcon(UnlockCfg.UnlockItemID)
	        if IconID then
                self.UnLockItemIcon = UIUtil.GetIconPath(IconID)
	        end
        end

        local NeedNum = 1 -- TODO 目前全为1
        local HasNum = self.UnlockItemNum
        self.bLockBtnEnable = HasNum >= NeedNum
        if not self.bLockBtnEnable then
            self.LockText = string.format("<span color=\"#dc5868\">%d</>/%d", HasNum, NeedNum)
        else
            self.LockText = string.format("%d/%d", HasNum, NeedNum)
        end
    elseif HairVM.bSpecial == true then
        self.bShowHairText = true
        --self.HairText = HairVM.HaircutDesc
        self.HairText = string.format(LSTR('<span color="#d1ba8e">%s</>'), HairVM.HaircutDesc)
        self.bUseUnlock = false
        self.bShowUnlock = false
    else
        self.bUseUnlock = false
        self.bShowUnlock = false
        self.bShowHairText = false
    end
end

-- 勾选项
function HaircutMainVM:SetDecalFlip()
    self.bFlip = not self.bFlip
    local Value = self.bFlip and 1 or 0
    self:SetAvatarCustomizeByPart(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub, Value)
end
--  色号选择列表
function HaircutMainVM:UpdateColorTableSelected(Index)
    if self.ListColorTableVM == nil then return end
    local ColorTableItem = self.ListColorTableVM[Index]
    -- 浓/淡/无处理
    self.bParamNone = Index == nil or Index == 0
    if self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor and self.bParamNone == false then
        local ModeValue = self.bLightColor and 2 or 1
        self:SetAvatarCustomizeByPart(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub, ModeValue, false)
    end

    --  挑染处理
    if self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor and self.bParamNone == false and self.bOperateSub then
        self:SetAvatarCustomizeByPart(LoginAvatarMgr.CustomizeSubMenu[self.SubType].SubChild, 128)
    end

    -- 设置角色数据
    local PartKey = self:GetPropertyKey()
    local Value = ColorTableItem.DataValue
    self:SetAvatarCustomizeByPart(PartKey, Value)
    self.ColorTableIndex = Index
end

-- 色板上多选列表
function HaircutMainVM:UpdateWorldTableSelected(Index)
    -- 图片列表多选
    if self.ListFaceTableVM ~= nil and table.size(self.ListFaceTableVM) == 6 and self.bShowPanelFace then
        self:MultiTableSelected(Index)
        return
    end
    -- 色板上多选列表
    local ListVM = self.ListWorldTableVM
    if ListVM == nil and table.size(ListVM) ~= 3 then return end
    local bEmpty = (Index == 1 and ListVM[1].bShowImgTick == true) or (ListVM[2].bShowImgTick == false and ListVM[3].bShowImgTick == false)
    if bEmpty == true then
        ListVM[2].bShowImgTick = false
        ListVM[3].bShowImgTick = false
        ListVM[1].bShowImgTick = true
    else
        ListVM[1].bShowImgTick = false
    end
    self.bParamNone = bEmpty
    self.ListWorldTableVM = ListVM
    -- Todo 获取并重置option的值
    local flag1 = ListVM[2].bShowImgTick == true and 1 or 0
    local flag2 = ListVM[3].bShowImgTick == true and 1 or 0
    local PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    local OptionValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if OptionValue == nil then
        OptionValue = 0
        FLOG_ERROR("OptionValue = nil reset to 0")
    end
    OptionValue = (OptionValue & 0x1F) + (flag1 << 6) + (flag2 << 5)
    self:SetAvatarCustomizeByPart(PartKey, OptionValue)

    -- 选择无的时候隐藏
    self.bShowColorTable = not self.bParamNone

    -- 无且展开色板时需要还原
    if self.bExpanded == true and self.bShowColorTable == false then
        self:ExpandedStateChanged(false)
    end
end

-- 色板上无颜色选项
function HaircutMainVM:SetColorTypeNone()
    local PartKey = self:GetPropertyKey()
    self:SetAvatarCustomizeByPart(PartKey, 0)
    -- LipMode or variation
    if self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor then
        self:SetAvatarCustomizeByPart(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub, 0)
    elseif self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor then
        self:SetAvatarCustomizeByPart(LoginAvatarMgr.CustomizeSubMenu[self.SubType].SubChild, 0)
    end

    self.bParamNone = true
end
-- 图片多选列表
function HaircutMainVM:MultiTableSelected(Index)
    local ListVM = self.ListFaceTableVM
    local LastValue = 0
    -- 根据选择变化
    local TypeNum = 5
    local HasValue = false
    for Index = 1, TypeNum do
        HasValue = HasValue or ListVM[Index + 1].bShowImgTick
    end
    local bEmpty = (Index == 1 and ListVM[1].bShowImgTick == true) or HasValue == false
    if bEmpty == true then
        ListVM[1].bShowImgTick = true
        for Index = 1, TypeNum do
            ListVM[Index + 1].bShowImgTick = false
        end
        LastValue = 0
    else
        ListVM[1].bShowImgTick = false
        for Index = 1, TypeNum do
            local flag = ListVM[Index + 1].bShowImgTick == true and 1 or 0
            LastValue = LastValue + (flag << (TypeNum - Index))
        end
    end
    self.ListFaceTableVM = ListVM
    -- 获取并重置option的值
    local PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    local OptionValue =  LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if OptionValue == nil then
        OptionValue = 0
        FLOG_ERROR("OptionValue = nil reset to 0")
    end
    OptionValue = (OptionValue & 96) + LastValue
    self:SetAvatarCustomizeByPart(PartKey, OptionValue)
end
-- 类型选择列表 
function HaircutMainVM:UpdateTypeTableSelected(Index)
    if self.ListTypeTableVM == nil then return end
    local TypeTableItem = self.ListTypeTableVM[Index]
    self.TypeTableIndex = Index

    -- 设置角色数据
    local PartKey = self:GetPropertyKey()
    local Value = TypeTableItem.DataValue
    self:SetAvatarCustomizeByPart(PartKey, Value)
end

-- 获取属性Key
function HaircutMainVM:GetPropertyKey()
    local PartKey = nil
    if self.bOperateSub == false or self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor or self.SubType == LoginAvatarMgr.CustomizeSubType.FaceDecalColor then
        PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    else
        PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub or LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    end
    return PartKey
end
-------------------------------------   Deal  Property   ------------------------------------------
-- 左右状态栏选颜色
function HaircutMainVM:SelectDoubleColor(bMain, bRaceColor)
    self.bParamNone = false -- 重置下
    self.bShowSwitch = true
    self.bShowLongSwitch = self.bExpanded
    self.bShowShortSwitch = not self.bExpanded
    if self.ListSubMenuVM == nil or self.ListSubMenuVM[self.PreSelectSubIndex] == nil then
        FLOG_WARNING("SubMenuList error, please check ListSubMenuVM") 
        return
    end
    local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local CustomKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    if bMain == false and self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor then
        CustomKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub
    end
    self:SelectColor(CustomKey, TotalNum, bRaceColor)
end

-- 唇色/面妆颜色
function HaircutMainVM:SelectColor(Type, TotalNum, bRaceColor)
    self.bShowPanelColor = true
    local ListVMp = {}
    --local ColorList = LoginAvatarMgr:GetColorListByType(Type)
    local ColorList = LoginAvatarMgr:GetUIColorListByType(Type)
    if ColorList == nil or table.size(ColorList) < TotalNum then
        FLOG_WARNING("ColorList error, please check CharaMakeTypeLooks table") 
        return
    end
    for Index = 1, TotalNum do
        local ColorItemVM = LoginCreateColorItemVM.New()
        -- 种族颜色序号映射
        local RaceIndex = nil
        if bRaceColor == true then
            RaceIndex =  LoginAvatarMgr:GetRaceColorID(Index-1)
        else
            RaceIndex = Index
        end

        -- 浓淡处理
        local ColorFlag = self.bLightColor == true and 1 or 0
        --RaceIndex = RaceIndex | (ColorFlag << 7) --浓艳清淡共用一套色板
        local Value = Index - 1 + ColorFlag * 128
        local ColorData = {Color = ColorList[RaceIndex], DataValue = Value}
        ColorItemVM:UpdateData(ColorData)
        ListVMp[#ListVMp + 1] = ColorItemVM
    end

    self.FullColorTableVM = ListVMp
    self:CalculateListColor()
end

function HaircutMainVM:ExpandedStateChanged(bExpanded)
    self.bExpanded = bExpanded
    self.bShowLongSwitch = self.bShowSwitch and self.bExpanded
    self.bShowShortSwitch = self.bShowSwitch and (not self.bExpanded)
    self:CalculateListColor()
    self:UpdateExpandedAction()
end

function HaircutMainVM:UpdateExpandedAction()
     -- 隐藏主菜单
     self.bShowNormalMenue = not self.bExpanded
     -- 移动模型
     LoginAvatarMgr:ModelMoveToLeft(self.bExpanded, false)
end

function HaircutMainVM:CalculateListColor()
    self.ColorTableIndex = 0
    local PartKey = self:GetPropertyKey()
    local ColorData = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if ColorData == nil then
        ColorData = 0 -- 待定
    end
    local Single = (ColorData + 1)%2 == 1 and 1 or 0  -- 根据角色数据判断折叠色号
    -- 唇色
    if self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor then
        local LipModeData = LoginAvatarMgr:GetCurCustomizeValue(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub)
        if LipModeData == 0 then
            Single = 1 -- 无颜色默认展示单数列
            self.bParamNone = true
        end
    end
    -- 挑染
    if self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor and self.bOperateSub then
        local Variation = LoginAvatarMgr:GetCurCustomizeValue(LoginAvatarMgr.CustomizeSubMenu[self.SubType].SubChild)
        if Variation == 0 then
            Single = 1 -- 无颜色默认展示单数列
            self.bParamNone = true
        end
    end
    local ListVMp = self.FullColorTableVM
    if self.bExpanded == false then
        -- 单列显示
        ListVMp = {}
        for _, ColorVM in ipairs(self.FullColorTableVM) do
            if (ColorVM.DataValue + 1)%2 == Single then
                table.insert(ListVMp, ColorVM)
            end
        end
    end
    self.ListColorTableVM = ListVMp
    -- 处理数据状态映射
    for Index, Value in ipairs(ListVMp) do
        local bEmptySelect = self.bMultiSelect == true or self.bParamNone == false -- option色板不重置select
        if ColorData == Value.DataValue and bEmptySelect then
            self.ColorTableIndex = Index
            return
        end
    end
end

-- 五官统一
function HaircutMainVM:SelectFacialFeature()
    self.bShowPanelType = true
    self.TypeTableIndex = 1
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    --local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    local ListVMp = {}
    for Index, Value in ipairs(TypeList) do
        local TextItemVM = LoginCreateTextSlotItemVM.New()
        local TextData = {Index = Index, DataValue = Value.TypeID, bSize = false}
        TextItemVM:UpdateData(TextData)
        ListVMp[#ListVMp + 1] = TextItemVM
        if PartValue == Value.TypeID then -- 处理数据状态映射
            self.TypeTableIndex = Index
        end
    end
    self.ListTypeTableVM = ListVMp
end

-- 眼瞳大小
function HaircutMainVM:SelectPupilSize()
    self.bShowPanelType = true
    self.TypeTableIndex = 1
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if PartValue == nil then
        PartValue = 0
        FLOG_ERROR("SelectPupilSize PartValue = nil reset to 0")
    end
    local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local ListVMp = {}
    for Index = 1, TotalNum do
        local TextItemVM = LoginCreateTextSlotItemVM.New()
        local TextData = {Index = Index, DataValue = Index, bSize = true}
        TextItemVM:UpdateData(TextData)
        ListVMp[#ListVMp + 1] = TextItemVM
        self.TypeTableIndex = PartValue + 1 -- 处理数据状态映射1:1,2:0
    end
    self.ListTypeTableVM = ListVMp
end

-- 面妆
function HaircutMainVM:SetFaceDecal()
    self.bShowPanelFace = true
    self.bShowFlip = true
    self.FaceTableSize = _G.UE.FVector2D(408, 693)

    self.FaceTableIndex = 1

    -- 获取decal Flip
    self.bFlip = LoginAvatarMgr:GetCurCustomizeValue(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub) == 1 and true or false
    -- 获取decal id
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)

    local ListSlotVMp = {}
    local BlankItemVM = LoginCreateSlotItemVM.New()
    local BlankSlotData = {IsSingSelect = true, bShowBlank = true, DataValue = 0}
    BlankItemVM:UpdateData(BlankSlotData)
    ListSlotVMp[1] = BlankItemVM
    --local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    for Index, Value in ipairs(TypeList) do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        -- 面妆数值转换
        local DecalID = LoginAvatarMgr:GetDecalIDFromName(Value.ModelName)
        local SlotData = {IsSingSelect = true, bShowBlank = false, DataValue = DecalID, ImgIcon = Value.IconPath, bUseCancel = true}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
        if PartValue == DecalID then -- 处理数据状态映射
            self.FaceTableIndex = Index + 1
        end
    end
    self.ListFaceTableVM = ListSlotVMp
    self.FaceTableNum = table.size(self.ListFaceTableVM)
end

-- 瞳孔轮廓/刺青/刺青装饰/耳饰
function HaircutMainVM:SetPreOption()
    self.bMultiSelect = true
    self.bShowWordPanel = true
    --self.bOperateSub = true
    -- 图片类型
    local ListWorldState = self:GetListWorldState(true) -- 图片选择状态,设置默认数据
    local ListSlotVMp = {}
    local BlankItemVM = LoginCreateSlotItemVM.New()
    local BlankSlotData = {IsSingSelect = false, bHaircut = true, bShowBlank = true, DataValue = 0, bShowImgTick = ListWorldState[1]}
    BlankItemVM:UpdateData(BlankSlotData)
    ListSlotVMp[1] = BlankItemVM

    if ListWorldState[1] == true then
        self.bParamNone = true
    else
        self.bParamNone = false
    end

    if self.DefaultCustomData == nil then
        FLOG_ERROR("HaircutMainVM:DefaultCustomData is nil")
        return
    end
    
    local FaceValue = self.DefaultCustomData[LoginAvatarMgr.CustomizeSubMenu[LoginAvatarMgr.CustomizeSubType.FaceBase].Main]
    local IconList = LoginAvatarMgr:GetOptionIconListByValue(FaceValue) -- 获取图标
    for Index = 1, 2 do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local IconPath = IconList[8-Index] -- 图标路径
        local SlotData = {IsSingSelect = false, bHaircut = true, bShowBlank = false, DataValue = 0, bShowImgTick = ListWorldState[Index + 1], ImgIcon = IconPath}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
    end
    self.ListWorldTableVM = ListSlotVMp

    -- 色板为SubKey
    self.bOperateSub = true
    -- 颜色
    self:SelectColor(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub, 192, false)

    -- 选择无的时候隐藏
    self.bShowColorTable = not self.bParamNone
end

-- 鳞片饰品/胡须伤痕/黑痣伤痕
function HaircutMainVM:SetLastOption()
    self.bMultiSelect = true
    self.bShowPanelFace = true
    local ListWorldState = self:GetListWorldState(false) -- 图片选择状态,设置默认数据
    local ListSlotVMp = {}
    local BlankItemVM = LoginCreateSlotItemVM.New()
    local BlankSlotData = {IsSingSelect = false, bHaircut = true, bShowBlank = true, DataValue = 0, bShowImgTick = ListWorldState[1]}
    BlankItemVM:UpdateData(BlankSlotData)
    ListSlotVMp[1] = BlankItemVM
     -- 获取图标
    if self.DefaultCustomData == nil then
        FLOG_ERROR("HaircutMainVM:DefaultCustomData is nil")
        return
    end
    local FaceValue = self.DefaultCustomData[LoginAvatarMgr.CustomizeSubMenu[LoginAvatarMgr.CustomizeSubType.FaceBase].Main]
    local IconList = LoginAvatarMgr:GetOptionIconListByValue(FaceValue)

    for Index = 1, 5 do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local IconPath = IconList[6-Index] -- 图标路径
        local SlotData = {IsSingSelect = false, bHaircut = true, bShowBlank = false, DataValue = 0, bShowImgTick = ListWorldState[Index + 1], ImgIcon = IconPath}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
    end
    self.ListFaceTableVM = ListSlotVMp
end

-- 处理Option数据状态ListWorldState
function HaircutMainVM:GetListWorldState(bPreOption)
    -- 获取option值
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if PartValue == nil then
        PartValue = 0
        FLOG_ERROR("GetListWorldState is nil, please check table")
    end
    local ValueList = {}
    for Index = 1, 8 do
        ValueList[9-Index] = PartValue % 2
        PartValue = math.floor(PartValue / 2)
    end
    -- 选择状态
    local ListWorldState = {}
    if bPreOption == true then
        ListWorldState[1] = ValueList[2] + ValueList[3] == 0
        ListWorldState[2] = ValueList[2] == 1
        ListWorldState[3] = ValueList[3] == 1
    else
        local AddValue = 0
        for i = 1, 5 do
            ListWorldState[i + 1] = ValueList[i + 3] == 1
            AddValue = AddValue + ValueList[i + 3]
        end
        ListWorldState[1] = AddValue == 0
    end
    return ListWorldState
end
-- 发型
function HaircutMainVM:SelectHairDo()
    self.bShowPanelFace = true
    --local PartKey = self:GetPropertyKey()
    --local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    local ListSlotVMp = {}
    for _, Value in ipairs(TypeList) do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local HairID = LoginAvatarMgr:GetHairIDFromName(Value.ModelName)
        local SlotData = {IsSingSelect = true, bShowBlank = false, bHaircut = true, DataValue = HairID, 
                          ImgIcon = Value.IconPath, LockType = Value.HaircutType, HaircutDesc = Value.HaircutDesc}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
        -- if PartValue == HairID then -- 处理数据状态映射
        --     self.FaceTableIndex = Index
        -- end
    end
    self.ListFaceTableVM = ListSlotVMp
    self.FaceTableNum = table.size(self.ListFaceTableVM)

    -- 查询解锁发型
    --_G.HaircutMgr:SendMsgHairQuery()
    self:UpdateUnlockList()
end

-- 初始化角色捏脸数据
function HaircutMainVM:UpdateRoleFace()
    local DefaultTable = HaircutMgr:GetDefaultAvatarFace()
    if DefaultTable == nil then
        DefaultTable = LoginAvatarMgr:GetCurAvatarFace()
    end
    if DefaultTable == nil then
        FLOG_WARNING("UpdateRoleFace is nil, please check avatar face")
        return
    end
    self.DefaultCustomData = table.clone(DefaultTable)
    --LoginAvatarMgr:AddHistory(0, table.clone(DefaultTable))
    --self:InitMainType()
end

-- 重置发型数据
function HaircutMainVM:ResetHair()
    local HairKey = LoginAvatarMgr.CustomizeSubMenu[LoginAvatarMgr.CustomizeSubType.Hairdo].Main
    local DefaultHair = self.DefaultCustomData[HairKey]
    self:SetAvatarCustomizeByPart(HairKey, DefaultHair)
    for Index, HairVM in ipairs(self.HairFaceTableVM) do
        local HairID = HairVM.DataValue
        if DefaultHair == HairID then -- 处理数据状态映射
            self.FaceTableIndex = Index
            self.HairTableIndex = Index
        end
    end
    self.bUseUnlock = false
end
-- 排序函数 可解锁>已解锁>无需解锁>未解锁
function HaircutMainVM.CalRankWeight(SlotVM)
    local Weight = 1
    if SlotVM.bSpecial == false then
        Weight = 2
    elseif SlotVM.bLocked == false then
        Weight = 3
    elseif SlotVM.bCanUnlock == true then
        Weight = 4
    else
        Weight = 1
    end
    return Weight
end
-- 获取解锁列表
function HaircutMainVM:UpdateUnlockList()
    local UnlockList = HaircutMgr:GetHairUnlockList()
    if UnlockList == nil or self.ListFaceTableVM == nil then return end
    local ListSlotVMp = {}
    for _, HairVM in ipairs(self.ListFaceTableVM) do
        if table.contain(UnlockList, HairVM.LockType) then
            HairVM.bLocked = false
        elseif HairVM.bSpecial == true then
            HairVM.bLocked = true
            self:UpdateHairItem(HairVM)
            HairVM.bCanUnlock = self.bLockBtnEnable
        end
        ListSlotVMp[#ListSlotVMp + 1] = HairVM
    end

    -- 排序
    local function SortFunction(VM1, VM2)
        local Weight1 = self.CalRankWeight(VM1)
        local Weight2 = self.CalRankWeight(VM2)
        if Weight1 == Weight2 then
            return VM1.DataValue < VM2.DataValue
        else
            return Weight1 > Weight2
        end
    end
    table.sort(ListSlotVMp, SortFunction)

    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    for Index, SlotVM in ipairs(ListSlotVMp) do
        if PartValue == SlotVM.DataValue then -- 处理数据状态映射
            self.FaceTableIndex = Index
            self.HairTableIndex = Index
        end
    end

    self.ListFaceTableVM = ListSlotVMp
    self.HairFaceTableVM = table.clone(self.ListFaceTableVM)
end

-- 只更新选中值
function HaircutMainVM:UpdateTableSelect()
    if self.SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
        local PartKey = self:GetPropertyKey()
        local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
        for Index, SlotVM in ipairs(self.ListFaceTableVM) do
            if PartValue == SlotVM.DataValue then -- 处理数据状态映射
                self.FaceTableIndex = Index
                self.HairTableIndex = Index
            end
        end
    end
end

-- 请求解锁发型
function HaircutMainVM:GetUnlockHair()
    if self.HairFaceTableVM == nil then return nil end
    local HairLockType = self.HairFaceTableVM[self.HairTableIndex].LockType
    local UnlockCfg = HairUnlockCfg:FindCfgByID(HairLockType)
    if UnlockCfg ~= nil then
        return UnlockCfg.UnlockItemID
    else
        FLOG_ERROR("GetUnlockHair ErrorType"..tostring(HairLockType))
        return 0;
    end
end

function HaircutMainVM:GetUnlockType()
    if self.HairFaceTableVM == nil then return nil end
    local HairLockType = self.HairFaceTableVM[self.HairTableIndex].LockType
    return HairLockType
end

-- 设置数值
function HaircutMainVM:SetAvatarCustomizeByPart(PartKey, Value)
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if self.DefaultCustomData ~= nil and PartValue ~= Value then
        --LoginAvatarMgr:AddHistory(PartKey, Value) -- 加入历史列表
        local HisRecord = {PartKey = PartKey, PartValue = Value, MainType = self.MainType, SubIndex = self.PreSelectSubIndex,
                           bOperateSub = self.bOperateSub, bExpanded = self.bExpanded}
        LoginAvatarMgr:AddHistory(HisRecord)
    end
    LoginAvatarMgr:SetAvatarCustomizeByPart(PartKey, Value)
end

return HaircutMainVM