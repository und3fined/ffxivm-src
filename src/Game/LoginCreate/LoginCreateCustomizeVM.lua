local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
--local MajorUtil = require("Utils/MajorUtil")

local LoginCreatePrefixItemVM = require("Game/LoginCreate/LoginCreatePrefixItemVM")
local LoginCreateVoiceItemVM = require("Game/LoginCreate/LoginCreateVoiceItemVM")
local LoginCreateSlotItemVM = require("Game/LoginCreate/LoginCreateSlotItemVM")
local LoginCreateColorItemVM = require("Game/LoginCreate/LoginCreateColorItemVM")
local LoginCreateTextSlotItemVM = require("Game/LoginCreate/LoginCreateTextSlotItemVM")

local LoginAvatarMgr = nil

---@class LoginCreateCustomizeVM : UIViewModel
local LoginCreateCustomizeVM = LuaClass(UIViewModel)


function LoginCreateCustomizeVM:Ctor()
    LoginAvatarMgr = _G.LoginAvatarMgr
    self.bShowNormalMenue = true -- 第一级页签状态
    self.LooksCfgList = nil -- 第一级菜单
    self.bVoiceMenue = false -- 第二集页签是否为音效
    self.ListSubMenuVM = nil  -- 二级页签列表
    self.ListVoiceVM = nil -- 二级页签音效列表
    self.PreSelectSubIndex = nil -- 上一步的页签
    self.MainType = 1
    self.SubType = 1
    self.EmotionIndex = 1

    -- 右屏自定义数据的控件的显隐
    self.bShowPanelFace = false -- 图片列表
    self.bShowFlip = false  -- 反转选项
    self.bFlip = false -- 是否反转

    self.bShowPanelColor = false -- 色板
    self.bShowWordPanel = false -- 色板上种类多选框
    self.bShowBtnNone = false -- 色板上"无"选项
    self.bShowColorTable = true
	

    self.bShowPanelHeight = false -- 滑动条
    self.bShowTextHeight = false -- 展示换算后的实际身高
   
    self.bShowPanelType = false -- 类型选择

    self.bShowLongSwitch = false -- 展开切换框
    self.bShowShortSwitch = false -- 正常切换框
    self.bShowSwitch = false

    -- 图片列表
    self.ListFaceTableVM = nil
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

    -- 滑动条
    self.ProBarPercent = 0.5
    self.TextTallest = nil
    self.TextShortest = nil
    self.TextPrecent = nil
    self.TextHeight = nil
    self.LastRecordSlider = nil

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

    self.SelectedFaceIndex = 1 -- 选中的脸型

    self.bMultiSelect = false

end
-- 部分数据初始化
function LoginCreateCustomizeVM:InitViewData()
    LoginAvatarMgr:SetSystemType(LoginAvatarMgr.FaceSystemType.Login)
    self.bShowNormalMenue = true
    LoginAvatarMgr:ResetParam("CurFocusType", false)
    --LoginAvatarMgr:ResetRecordList()
    LoginAvatarMgr:InitMenuData()
    --LoginAvatarMgr:InitColorData()
    LoginAvatarMgr:InitUIColorData()
    LoginAvatarMgr:InitRaceHeight()
    LoginAvatarMgr:InitVoiceType()
    local DefaultTable = LoginAvatarMgr:GetCurAvatarFace()
    self.bExpanded = false
    if DefaultTable == nil then return end
    self.DefaultCustomData = table.clone(DefaultTable)
    --LoginAvatarMgr:AddHistory(0, table.clone(DefaultTable))
    self:InitMainType()
end

function LoginCreateCustomizeVM:UnInitViewData()
     -- 移动模型
    LoginAvatarMgr:ModelMoveToLeft(false, true)
    local AvatarFace = LoginAvatarMgr:GetCurAvatarFace()
    if AvatarFace == nil or self.DefaultCustomData == nil then return end
    local CurAvatarFace = table.clone(AvatarFace)
    if not table.compare_table(self.DefaultCustomData, CurAvatarFace) then
        LoginAvatarMgr:RefreshPlayerAvatarFace()
    end
    --LoginAvatarMgr:SetCameraFocus(nil, true, nil)
end

function LoginCreateCustomizeVM:SetMainType(MenueType)
    self.MainType = MenueType
end

function LoginCreateCustomizeVM:InitMainType()
    local LooksList = {}
    local IconNames = {"FaceShape", "Facial", "Makeup", "HairStyle", "BodyShape", "Sound"}
    for Index, Name in ipairs(IconNames) do
        local Look = {SimpleIcon = string.format("PaperSprite'/Game/UI/Atlas/LoginCreate/Frames/UI_LoginCreate_Icon_%s_png.UI_LoginCreate_Icon_%s_png'", Name, Name)}
        LooksList[Index] = Look
    end
    self.LooksCfgList = LooksList
end

-- 二级页签列表更新
function LoginCreateCustomizeVM:UpdateSubMenu(MainTile)
    local TileList = LoginAvatarMgr:GetSubMenuList(MainTile)
    if TileList  == nil then return end
    local ListSlotVMp = {}
    for _, List in ipairs(TileList) do
        local PrefixItemVM = LoginCreatePrefixItemVM.New()
        PrefixItemVM:SetItemData(List)
        ListSlotVMp[#ListSlotVMp + 1] = PrefixItemVM
    end
    self.ListSubMenuVM = ListSlotVMp
    self.bVoiceMenue = false
    -- 子菜单标题
    _G.LoginUIMgr:SetSubTitle(MainTile)
end

-- 二级页签所选状态更新
function LoginCreateCustomizeVM:UpdateSubMenuSelected(Index)
    if self.ListSubMenuVM[Index] ~= nil then 
        self.ListSubMenuVM[Index]:SetItemSelected(true)
    else
        return
    end
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
    --_G.LoginUIMgr:SetSubTitle(self.ListSubMenuVM[Index].TextTitle)
end
function LoginCreateCustomizeVM:DealTypeFunc()
    -- local SubFunCases = {
    --     [LoginAvatarMgr.CustomizeSubType.FaceBase] = function()
    --         self:SelectFacePart()
    --     end,
    --     [LoginAvatarMgr.CustomizeSubType.SkinColor] = function()
    --         self:SelectFaceColor()
    --     end
    -- }
    -- local Func = SubFunCases[self.SubType]
    local SubType = self.SubType
    if SubType == LoginAvatarMgr.CustomizeSubType.Ear or SubType == LoginAvatarMgr.CustomizeSubType.Tail then
        self.bShowShortSwitch = true
    end
    if self.MainType == LoginAvatarMgr.CustomizeMainMenu.Eye then
        self:SelectFacialFeature()
        return
    end
    if SubType == LoginAvatarMgr.CustomizeSubType.FaceBase then
        self:SelectFacePart()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
        self:SelectHairDo()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.SkinColor then
        self:SelectFaceColor()
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
    elseif SubType == LoginAvatarMgr.CustomizeSubType.HeightScaleRate then
        self:SetHeightScale()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.BodyType then
        self:SetBodyType()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.ChestSize then
        self:SetChestSize()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.PupilContour or SubType == LoginAvatarMgr.CustomizeSubType.Tattoo or 
           SubType == LoginAvatarMgr.CustomizeSubType.TattooDecor or SubType == LoginAvatarMgr.CustomizeSubType.Earring then
        self:SetPreOption()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.ScaleJewelry or SubType == LoginAvatarMgr.CustomizeSubType.FaceScar then
        self:SetLastOption()
    elseif SubType == LoginAvatarMgr.CustomizeSubType.Tail then
        self:SelectTail()
    end

end
-- 二级页签声音列表更新
function LoginCreateCustomizeVM:UpdateVoiceMenu()
    local VoiceIndex = 5 -- 五种情感动作
    local ListSlotVMp = {}
    for Index = 1, VoiceIndex do
        local VoiceItemVM = LoginCreateVoiceItemVM.New()
        VoiceItemVM:SetItemType(Index)
        ListSlotVMp[#ListSlotVMp + 1] = VoiceItemVM
    end
    self.ListVoiceVM = ListSlotVMp
    self.bVoiceMenue = true
    self.SubType = LoginAvatarMgr.CustomizeSubType.Voice
    -- 相机镜头变化
    LoginAvatarMgr:SetCameraFocus(self.SubType, false, true)

    -- 子菜单标题
    _G.LoginUIMgr:SetSubTitle(_G.LSTR(980009))
end

-- 二级页签音效所选状态更新
function LoginCreateCustomizeVM:UpdateVoiceSelected(Index)
    if self.ListVoiceVM[Index] ~= nil then
        self.ListVoiceVM[Index]:SetItemSelected(true)
    else
        return
    end
    local LastIndex = self.PreSelectSubIndex
    if LastIndex ~= Index and self.ListVoiceVM[LastIndex] ~= nil then 
        self.ListVoiceVM[LastIndex]:SetItemSelected(false)
    end
    self.PreSelectSubIndex = Index
    -- 各个属性设置
    self:InitRightWidget()
    -- 选择音色
    self:SelectVoiceType()

    self.EmotionIndex = Index
end

-- 关闭右屏控件
function LoginCreateCustomizeVM:InitRightWidget()

    -- 图片选择框
    self.bShowPanelFace = false
    self.bShowFlip = false

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
    --self.LastRecordSlider = nil

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
function LoginCreateCustomizeVM:UpdateSwitchSelected(bLeft, LeftName, RightName)
    self.bOperateSub = not bLeft
    self[LeftName] = bLeft
    self[RightName] = not bLeft
end

function LoginCreateCustomizeVM:UpdateParamSwitchSelected(bLeft)
    local bSwitchChanged = self.bOperateSub == bLeft
    self.bOperateSub = not bLeft
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
function LoginCreateCustomizeVM:UpdateFaceTableSelected(Index)
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
end

-- 勾选项
function LoginCreateCustomizeVM:SetDecalFlip()
    self.bFlip = not self.bFlip
    local Value = self.bFlip and 1 or 0
    self:SetAvatarCustomizeByPart(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub, Value)
end
--  色号选择列表
function LoginCreateCustomizeVM:UpdateColorTableSelected(Index)
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
function LoginCreateCustomizeVM:UpdateWorldTableSelected(Index)
    -- 图片列表多选
    if table.size(self.ListFaceTableVM) == 6 and self.bShowPanelFace then
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
function LoginCreateCustomizeVM:SetColorTypeNone()
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
function LoginCreateCustomizeVM:MultiTableSelected(Index)
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
function LoginCreateCustomizeVM:UpdateTypeTableSelected(Index)
    if self.ListTypeTableVM == nil then return end
    local TypeTableItem = self.ListTypeTableVM[Index]
    self.TypeTableIndex = Index

     -- 设置角色数据
    local PartKey = self:GetPropertyKey()
    local Value = TypeTableItem.DataValue
    self:SetAvatarCustomizeByPart(PartKey, Value)
    -- TODO音色变化
    if self.bVoiceMenue == true then
        LoginAvatarMgr:PlayEmotionNextTick(self.EmotionIndex)
    end
end

-- 滑动条变化
function LoginCreateCustomizeVM:UpdateSliderValue(PercentValue)
    self:UpdateSliderText(PercentValue)
    -- 设置角色数据
    local PartKey = self:GetPropertyKey()
    -- Todo 数值转换
    -- local Value = PercentValue
    local InterHeight = math.floor(PercentValue*100 + 0.5)
    self:SetAvatarCustomizeByPart(PartKey, InterHeight, false)
end

function LoginCreateCustomizeVM:RecordSliderValue(PercentValue)
    -- 设置角色数据
    local PartKey = self:GetPropertyKey()
    --local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    local InterHeight = math.floor(PercentValue*100 + 0.5)
    if self.LastRecordSlider ~= nil then
        --LoginAvatarMgr:AddHistory(PartKey, self.LastRecordSlider, true) -- 加入历史列表
        local HisRecord = {PartKey = PartKey, PartValue = self.LastRecordSlider, MainType = self.MainType, SubIndex = self.PreSelectSubIndex,
                           bOperateSub = self.bOperateSub, bExpanded = self.bExpanded, bUsePart = true}
        LoginAvatarMgr:AddHistory(HisRecord)
    end
    self.LastRecordSlider = InterHeight
end
-- 滑动条文本变化
function LoginCreateCustomizeVM:UpdateSliderText(PercentValue)
    self.ProBarPercent = PercentValue
    local InterHeight = math.floor(PercentValue*100 + 0.5)
    self.TextPrecent = string.format("%d", InterHeight)
    --换算真实身高
    local RealHeight = LoginAvatarMgr:GetRealHeight(PercentValue)
    self.TextHeight = string.format(_G.LSTR(980046), RealHeight)
end

-- 获取属性Key
function LoginCreateCustomizeVM:GetPropertyKey()
    local PartKey = nil
    if self.bOperateSub == false or self.SubType == LoginAvatarMgr.CustomizeSubType.LipColor or self.SubType == LoginAvatarMgr.CustomizeSubType.FaceDecalColor then
        PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    else
        PartKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub or LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    end
    return PartKey
end
-------------------------------------   Deal  Property   ------------------------------------------
-- 脸部处理
function LoginCreateCustomizeVM:SelectFacePart()
    self.bShowPanelFace = true
     --local StateMap = {}-- 处理数据状态映射
    self.FaceTableIndex = 1
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    --local TotalFaceNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    local ListSlotVMp = {}
    for Index, Value in ipairs(TypeList) do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local FaceBase = LoginAvatarMgr:GetFaceBaseFromName(Value.ModelName)
        local SlotData = {IsSingSelect = true, bShowBlank = false, DataValue = FaceBase, ImgIcon = Value.IconPath}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
        --StateMap[FaceBase] = Index
        if PartValue == FaceBase then -- 处理数据状态映射
            self.FaceTableIndex = Index
        end
    end
    self.ListFaceTableVM = ListSlotVMp
    self.FaceTableNum = table.size(self.ListFaceTableVM)
    --self.DataStateList[self.SubType] = StateMap
    --self.FaceTableIndex = StateMap[PartValue] or 1
end

-- 脸部肤色
function LoginCreateCustomizeVM:SelectFaceColor()
    local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    self:SelectColor(LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main, TotalNum, true)--ProtoCommon.avatar_personal.AvatarSkinColor
end

-- 左右状态栏选颜色
function LoginCreateCustomizeVM:SelectDoubleColor(bMain, bRaceColor)
    self.bParamNone = false -- 重置下
    self.bShowSwitch = true
    self.bShowLongSwitch = self.bExpanded
    self.bShowShortSwitch = not self.bExpanded
    local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local CustomKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Main
    if bMain == false and self.SubType == LoginAvatarMgr.CustomizeSubType.HairColor then
        CustomKey = LoginAvatarMgr.CustomizeSubMenu[self.SubType].Sub
    end
    self:SelectColor(CustomKey, TotalNum, bRaceColor)
end


-- 唇色/面妆颜色
function LoginCreateCustomizeVM:SelectColor(Type, TotalNum, bRaceColor)
    self.bShowPanelColor = true
    local ListVMp = {}
    --local ColorList = LoginAvatarMgr:GetColorListByType(Type)
    local ColorList = LoginAvatarMgr:GetUIColorListByType(Type)
    if ColorList == nil or table.size(ColorList) < TotalNum then
        FLOG_ERROR("ColorList error, please check CharaMakeTypeLooks table")
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

function LoginCreateCustomizeVM:ExpandedStateChanged(bExpanded)
    self.bExpanded = bExpanded
    self.bShowLongSwitch = self.bShowSwitch and self.bExpanded
    self.bShowShortSwitch = self.bShowSwitch and (not self.bExpanded)
    self:CalculateListColor()
    self:UpdateExpandedAction()
end

function LoginCreateCustomizeVM:UpdateExpandedAction()
     -- 隐藏主菜单
     self.bShowNormalMenue = not self.bExpanded
     -- 移动模型
     LoginAvatarMgr:ModelMoveToLeft(self.bExpanded, false)
end

function LoginCreateCustomizeVM:CalculateListColor()
    --if self.bShowColorTable == false then return end
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
            if ColorVM ~= nil and ColorVM.DataValue ~= nil and (ColorVM.DataValue + 1)%2 == Single then
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
function LoginCreateCustomizeVM:SelectFacialFeature()
    self.bShowPanelType = true
    self.TypeTableIndex = 1
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    --local TotalNum = self.ListSubMenuVM[self.PreSelectSubIndex].MaxValue
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    if TypeList == nil then
        FLOG_ERROR("GetPropertyList error, please check CharaMakeTypeLooks table self.SubType = %d", self.SubType)
        return
    end
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
function LoginCreateCustomizeVM:SelectPupilSize()
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
        self.TypeTableIndex = PartValue + 1 -- 处理数据状态映射1:0,2:1
    end
    self.ListTypeTableVM = ListVMp
end

-- 面妆
function LoginCreateCustomizeVM:SetFaceDecal()
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
function LoginCreateCustomizeVM:SetPreOption()
    self.bMultiSelect = true
    self.bShowWordPanel = true
    --self.bOperateSub = true
    -- 图片类型
    local ListWorldState = self:GetListWorldState(true) -- 图片选择状态,设置默认数据
    local ListSlotVMp = {}
    local BlankItemVM = LoginCreateSlotItemVM.New()
    local BlankSlotData = {IsSingSelect = false, bShowBlank = true, DataValue = 0, bShowImgTick = ListWorldState[1]}
    BlankItemVM:UpdateData(BlankSlotData)
    ListSlotVMp[1] = BlankItemVM

    if ListWorldState[1] == true then
        self.bParamNone = true
    else
        self.bParamNone = false
    end

    local IconList = LoginAvatarMgr:GetOptionIconList(self.SelectedFaceIndex) -- 获取图标
    for Index = 1, 2 do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local IconPath = IconList[8-Index] -- 图标路径
        local SlotData = {IsSingSelect = false, bShowBlank = false, DataValue = 0, bShowImgTick = ListWorldState[Index + 1], ImgIcon = IconPath}
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
function LoginCreateCustomizeVM:SetLastOption()
    self.bMultiSelect = true
    self.bShowPanelFace = true
    local ListWorldState = self:GetListWorldState(false) -- 图片选择状态,设置默认数据
    local ListSlotVMp = {}
    local BlankItemVM = LoginCreateSlotItemVM.New()
    local BlankSlotData = {IsSingSelect = false, bShowBlank = true, DataValue = 0, bShowImgTick = ListWorldState[1]}
    BlankItemVM:UpdateData(BlankSlotData)
    ListSlotVMp[1] = BlankItemVM
    local IconList = LoginAvatarMgr:GetOptionIconList(self.SelectedFaceIndex) -- 获取图标
    for Index = 1, 5 do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local IconPath = IconList[6-Index] -- 图标路径
        local SlotData = {IsSingSelect = false, bShowBlank = false, DataValue = 0, bShowImgTick = ListWorldState[Index + 1], ImgIcon = IconPath}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
    end
    self.ListFaceTableVM = ListSlotVMp
end

-- 处理Option数据状态ListWorldState
function LoginCreateCustomizeVM:GetListWorldState(bPreOption)
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
function LoginCreateCustomizeVM:SelectHairDo()
    self.bShowPanelFace = true
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    local ListSlotVMp = {}
    for Index, Value in ipairs(TypeList) do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local HairID = LoginAvatarMgr:GetHairIDFromName(Value.ModelName)
        local SlotData = {IsSingSelect = true, bShowBlank = false, DataValue = HairID, ImgIcon = Value.IconPath}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
        if PartValue == HairID then -- 处理数据状态映射
            self.FaceTableIndex = Index
        end
    end
    self.ListFaceTableVM = ListSlotVMp
    self.FaceTableNum = table.size(self.ListFaceTableVM)
end
-- 身高
function LoginCreateCustomizeVM:SetHeightScale()
    self.bShowPanelHeight = true
    self.bShowTextHeight = true
    self.TextTallest = _G.LSTR(980045)
    self.TextShortest = _G.LSTR(980034)
    -- 获取当前值
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if PartValue == nil then
        PartValue = 0
        FLOG_ERROR("SetHeightScale PartValue = nil reset to 0")
    end
    local CurrentValue = PartValue/100
    self:UpdateSliderText(CurrentValue)
    self.LastRecordSlider = PartValue
end

-- 体型
function LoginCreateCustomizeVM:SetBodyType()
    self.bShowPanelHeight = true
    self.bShowTextHeight = false
    -- 耳朵大小标识：精灵：长，短/拉拉肥：强壮，瘦弱
    local RoleBase = LoginAvatarMgr:GetCreateRoleBase()
    local RaceType = ProtoCommon.race_type
    if RoleBase.RaceID == RaceType.RACE_TYPE_Elezen then -- 精灵族
        self.TextTallest = _G.LSTR(980044)
        self.TextShortest = _G.LSTR(980033)
    else
        self.TextTallest = _G.LSTR(980017)
        self.TextShortest = _G.LSTR(980032)
    end
    -- 获取当前值
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if PartValue ~= nil then
        local CurrentValue = PartValue/100
        self:UpdateSliderText(CurrentValue)
    end
    self.LastRecordSlider = PartValue
end

-- 胸型
function LoginCreateCustomizeVM:SetChestSize()
    self.bShowPanelHeight = true
    self.bShowTextHeight = false
    self.TextTallest = _G.LSTR(980010)
    self.TextShortest = _G.LSTR(980013)
    -- TODO获取当前值
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if PartValue ~= nil then
        local CurrentValue = PartValue/100
        self:UpdateSliderText(CurrentValue)
    end
    self.LastRecordSlider = PartValue
end

-- 尾巴
function LoginCreateCustomizeVM:SetTailSize()
    self.bShowPanelHeight = true
    self.bShowTextHeight = false
    self.TextTallest = _G.LSTR(980044)
    self.TextShortest = _G.LSTR(980033)
    -- TODO获取当前值
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if PartValue == nil then
        PartValue = 0
        FLOG_ERROR("SetTailSize PartValue = nil reset to 0")
    end
    local CurrentValue = PartValue/100
    self:UpdateSliderText(CurrentValue)
end

function LoginCreateCustomizeVM:SelectTail()
    self.bShowPanelFace = true
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    local TypeList = LoginAvatarMgr:GetPropertyList(self.SubType)
    local ListSlotVMp = {}
    for Index, Value in ipairs(TypeList) do
        local SlotItemVM = LoginCreateSlotItemVM.New()
        local SlotData = {IsSingSelect = true, bShowBlank = false, DataValue = Value.TypeID, ImgIcon = Value.IconPath}
        SlotItemVM:UpdateData(SlotData)
        ListSlotVMp[#ListSlotVMp + 1] = SlotItemVM
        if PartValue == Value.TypeID then -- 处理数据状态映射
            self.FaceTableIndex = Index
        end
    end
    self.ListFaceTableVM = ListSlotVMp
    self.FaceTableNum = table.size(self.ListFaceTableVM)
end
-- todo 根据数值选中

-- 设置数值
function LoginCreateCustomizeVM:SetAvatarCustomizeByPart(PartKey, Value, bRecord)
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey)
    if self.DefaultCustomData ~= nil and PartValue ~= Value and bRecord ~= false then
        --LoginAvatarMgr:AddHistory(PartKey, Value) -- 加入历史列表
        local HisRecord = {PartKey = PartKey, PartValue = Value, MainType = self.MainType, SubIndex = self.PreSelectSubIndex,
                           bOperateSub = self.bOperateSub, bExpanded = self.bExpanded}
        LoginAvatarMgr:AddHistory(HisRecord)
    end
    LoginAvatarMgr:SetAvatarCustomizeByPart(PartKey, Value)
end

-- Todo选择音色
function LoginCreateCustomizeVM:SelectVoiceType()
    self.bShowPanelType = true
    self.TypeTableIndex = 1
    local VoiceTypeList = LoginAvatarMgr:GetVoiceTypeList(true)
    if VoiceTypeList == nil then
        FLOG_ERROR("VoiceTypeList is nil, please check table")
        return
    end
    local PartKey = self:GetPropertyKey()
    local PartValue = LoginAvatarMgr:GetCurCustomizeValue(PartKey) or VoiceTypeList[1]
    local ListVMp = {}
    for Index = 1, table.size(VoiceTypeList) do
        local TextItemVM = LoginCreateTextSlotItemVM.New()
        local TextData = {Index = Index, DataValue = VoiceTypeList[Index], bSize = false}
        TextItemVM:UpdateData(TextData)
        ListVMp[#ListVMp + 1] = TextItemVM
        if PartValue == VoiceTypeList[Index] then -- 处理数据状态映射
            self.TypeTableIndex = Index
        end
    end
    self.ListTypeTableVM = ListVMp
end
return LoginCreateCustomizeVM