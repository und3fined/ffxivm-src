---
--- Author: richyczhou
--- DateTime: 2025-08-01 10:53
--- Description:
---

local UIView = require("UI/UIView")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local GMCharacterUtil = require("Game/GM/CharacterEditor/GMCharacterUtil")
local GMCharacterEditorMgr = require("Game/GM/CharacterEditor/GMCharacterEditorMgr")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderSetSliderMin = require("Binder/UIBinderSetSliderMin")
local UIBinderSetSliderMax = require("Binder/UIBinderSetSliderMax")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR
local LoginAvatarMgr = _G.LoginAvatarMgr
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class CharacterRacePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AgeComboBox UComboBoxString
---@field Button_133 UButton
---@field ChestSlider USlider
---@field EarComboBox UComboBoxString
---@field EarSlider2 USlider
---@field EyeTableView UTableView
---@field EyebrowTableView UTableView
---@field FaceComboBox UComboBoxString
---@field FaceDecalColorButton CharacterColorButtonView
---@field FaceDecalComboBox UComboBoxString
---@field FaceOptionTableView UTableView
---@field FaceTableView UTableView
---@field GenderComboBox UComboBoxString
---@field HairColorButton CharacterColorButtonView
---@field HairComboBox UComboBoxString
---@field HairVariationColorButton CharacterColorButtonView
---@field HeightSlider USlider
---@field ImgNormal UFImage
---@field LEyeColorButton CharacterColorButtonView
---@field LipColorButton CharacterColorButtonView
---@field LipsTableView UTableView
---@field MaskButton UButton
---@field MuscleSlider USlider
---@field NoneBtn UFButton
---@field NoseTableView UTableView
---@field PanelColor UFCanvasPanel
---@field REyeColorButton CharacterColorButtonView
---@field RaceComboBox UComboBoxString
---@field SkinColorButton CharacterColorButtonView
---@field TableViewColor UTableView
---@field TailComboBox UComboBoxString
---@field TailSlider2 USlider
---@field TextContent UFTextBlock
---@field TribeComboBox UComboBoxString
---@field TypeSwitch CharacterSwitchItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CharacterRacePanelView = LuaClass(UIView, true)

function CharacterRacePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AgeComboBox = nil
	--self.Button_133 = nil
	--self.ChestSlider = nil
	--self.EarComboBox = nil
	--self.EarSlider2 = nil
	--self.EyeTableView = nil
	--self.EyebrowTableView = nil
	--self.FaceComboBox = nil
	--self.FaceDecalColorButton = nil
	--self.FaceDecalComboBox = nil
	--self.FaceOptionTableView = nil
	--self.FaceTableView = nil
	--self.GenderComboBox = nil
	--self.HairColorButton = nil
	--self.HairComboBox = nil
	--self.HairVariationColorButton = nil
	--self.HeightSlider = nil
	--self.ImgNormal = nil
	--self.LEyeColorButton = nil
	--self.LipColorButton = nil
	--self.LipsTableView = nil
	--self.MaskButton = nil
	--self.MuscleSlider = nil
	--self.NoneBtn = nil
	--self.NoseTableView = nil
	--self.PanelColor = nil
	--self.REyeColorButton = nil
	--self.RaceComboBox = nil
	--self.SkinColorButton = nil
	--self.TableViewColor = nil
	--self.TailComboBox = nil
	--self.TailSlider2 = nil
	--self.TextContent = nil
	--self.TribeComboBox = nil
	--self.TypeSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    -- 是否是手动操作
    self.bIsManual = false
    self.IsInit = false

    -- ComboBox当前选中的项
    self.CurAttachType = nil
    self.CurTribeName = nil
    self.CurGenderIndex = -1
    self.CurHair = nil
    self.CurFace = nil
    self.CurFaceDecal = nil
    self.CurEar = nil
    self.CurTail = nil

    -- 颜色面板”浓艳“和”清淡“，是否是左边”浓艳“
    self.IsColorTypeSwitchLeft = true
end

function CharacterRacePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FaceDecalColorButton)
	self:AddSubView(self.HairColorButton)
	self:AddSubView(self.HairVariationColorButton)
	self:AddSubView(self.LEyeColorButton)
	self:AddSubView(self.LipColorButton)
	self:AddSubView(self.REyeColorButton)
	self:AddSubView(self.SkinColorButton)
	self:AddSubView(self.TypeSwitch)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CharacterRacePanelView:OnInit()
    self.GMCharacterEditorVM = GMCharacterEditorMgr:GetCharacterEditorVM()

    self.FaceContourTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.FaceTableView, self.OnFaceContourSelectChanged,false)
    self.EyeTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.EyeTableView, self.OnEyeSelectChanged,false)
    self.EyebrowTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.EyebrowTableView, self.OnEyebrowSelectChanged,false)
    self.NoseTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.NoseTableView, self.OnNoseSelectChanged,false)
    self.LipsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.LipsTableView, self.OnLipsSelectChanged,false)
    self.ColorTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewColor, self.OnColorSelectChanged,false)
    self.FaceOptionTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.FaceOptionTableView, self.OnFaceOptionSelectChanged,false)

    self:InitBinders()
end

function CharacterRacePanelView:OnDestroy()

end

function CharacterRacePanelView:OnShow()
    FLOG_INFO("[CharacterRacePanelView:OnShow]")
    self.GMCharacterEditorVM.IsShowColorPanel = false

    -- 980029浓艳, 980030清淡
    self.TypeSwitch:SetTitleText(LSTR(980029), LSTR(980030))
    self.TextContent:SetText(LSTR(1250040)) --"无"

    self.bIsManual = false
    if self.IsInit then
        self:UpdateComboBox()
    else
        self.IsInit = true
        self:ResetData()
    end
end

function CharacterRacePanelView:OnHide()

end

function CharacterRacePanelView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.RaceComboBox, self.OnRaceComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.TribeComboBox, self.OnTribeComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.GenderComboBox, self.OnGenderComboBoxSelectionChanged)

    UIUtil.AddOnSelectionChangedEvent(self, self.HairComboBox, self.OnHairComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.FaceComboBox, self.OnFaceComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.FaceDecalComboBox, self.OnFaceDecalComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.EarComboBox, self.OnFaceEarComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.TailComboBox, self.OnTailComboBoxSelectionChanged)

    UIUtil.AddOnValueChangedEvent(self, self.HeightSlider, self.OnHeightSliderValueChanged)
    UIUtil.AddOnValueChangedEvent(self, self.ChestSlider, self.OnChestSliderValueChanged)
    UIUtil.AddOnValueChangedEvent(self, self.MuscleSlider, self.OnMuscleSliderValueChanged)
    UIUtil.AddOnValueChangedEvent(self, self.TailSlider2, self.OnTailSliderValueChanged)
    UIUtil.AddOnValueChangedEvent(self, self.EarSlider2, self.OnEarSliderValueChanged)

    UIUtil.AddOnClickedEvent(self, self.MaskButton, self.OnMaskButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.NoneBtn, self.OnNoneBtnClicked)
    UIUtil.AddOnClickedEvent(self, self.SkinColorButton.BtnColor, self.OnSkinColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.HairColorButton.BtnColor, self.OnHairColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.HairVariationColorButton.BtnColor, self.OnHairVariationColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.FaceDecalColorButton.BtnColor, self.OnFaceDecalColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.LEyeColorButton.BtnColor, self.OnLEyeColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.REyeColorButton.BtnColor, self.OnREyeColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.LipColorButton.BtnColor, self.OnLipColorButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.TypeSwitch.ToggleBtn1, self.OnClickedTypeSwitchParam, true)
    UIUtil.AddOnClickedEvent(self, self.TypeSwitch.ToggleBtn2, self.OnClickedTypeSwitchParam, false)
end

function CharacterRacePanelView:OnRegisterGameEvent()
    -- GM Character Editor
    self:RegisterGameEvent(EventID.GMCRaceTribeGenderChanged, self.OnGMCRaceTribeGenderChanged)
end

function CharacterRacePanelView:OnRegisterBinder()
    self:RegisterBinders(self.GMCharacterEditorVM, self.Binders)
end

function CharacterRacePanelView:InitBinders()
    FLOG_INFO("[CharacterRacePanelView:InitBinders]")

    self.Binders = {
        { "AttachTypeList", UIBinderValueChangedCallback.New(self, nil, self.OnAttachTypeListChanged) },
        { "TribeNameList", UIBinderValueChangedCallback.New(self, nil, self.OnTribeNameListChanged) },
        { "GenderList", UIBinderValueChangedCallback.New(self, nil, self.OnGenderListChanged) },

        { "HairList", UIBinderValueChangedCallback.New(self, nil, self.OnHairListChanged) },
        { "FaceList", UIBinderValueChangedCallback.New(self, nil, self.OnFaceListChanged) },
        { "FaceDecalList", UIBinderValueChangedCallback.New(self, nil, self.OnFaceDecalListChanged) },
        { "FaceEarList", UIBinderValueChangedCallback.New(self, nil, self.OnFaceEarListChanged) },
        { "TailList", UIBinderValueChangedCallback.New(self, nil, self.OnTailListChanged) },

        { "FaceContourList", UIBinderUpdateBindableList.New(self, self.FaceContourTableViewAdapter) },
        { "EyeList", UIBinderUpdateBindableList.New(self, self.EyeTableViewAdapter) },
        { "EyebrowList", UIBinderUpdateBindableList.New(self, self.EyebrowTableViewAdapter) },
        { "NoseList", UIBinderUpdateBindableList.New(self, self.NoseTableViewAdapter) },
        { "LipsList", UIBinderUpdateBindableList.New(self, self.LipsTableViewAdapter) },
        { "ColorList", UIBinderUpdateBindableList.New(self, self.ColorTableViewAdapter) },
        { "OptionList", UIBinderUpdateBindableList.New(self, self.FaceOptionTableViewAdapter) },

        { "HeightValue", UIBinderSetSlider.New(self, self.HeightSlider) },
        { "ChestValue", UIBinderSetSlider.New(self, self.ChestSlider) },
        { "MuscleValue", UIBinderSetSlider.New(self, self.MuscleSlider) },
        { "TailValue", UIBinderSetSlider.New(self, self.TailSlider2) },
        { "EarValue", UIBinderSetSlider.New(self, self.EarSlider2) },

        { "IsShowColorPanel", UIBinderSetIsVisible.New(self, self.PanelColor) },
        { "IsShowColorPanel", UIBinderSetIsVisible.New(self, self.MaskButton, false, true) },
        { "IsShowColorPanel", UIBinderValueChangedCallback.New(self, nil, self.OnIsShowColorPanelChanged) },
        { "ShowColorTypeSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch, false, true) },
        { "ShowNoneText", UIBinderSetIsVisible.New(self, self.NoneBtn, false, true) },
        { "SkinColorBtn", UIBinderValueChangedCallback.New(self, nil, self.OnSkinColorChanged)},
        { "HairColorBtn", UIBinderValueChangedCallback.New(self, nil, self.OnHairColorChanged)},
        { "HairVariationBtn", UIBinderValueChangedCallback.New(self, nil, self.OnHairVariationColorChanged)},
        { "FaceDecalColorBtn", UIBinderValueChangedCallback.New(self, nil, self.OnFaceDecalColorChanged)},
        { "LEyeColorBtn", UIBinderValueChangedCallback.New(self, nil, self.OnLEyeColorChanged)},
        { "REyeColorBtn", UIBinderValueChangedCallback.New(self, nil, self.OnREyeColorChanged)},
        { "LipColorBtn", UIBinderValueChangedCallback.New(self, nil, self.OnLipColorChanged)},
    }
end

function CharacterRacePanelView:ResetData()
    FLOG_INFO("[CharacterRacePanelView:ResetData]")

    GMCharacterEditorMgr.CurSkinColorIndex = 1
    GMCharacterEditorMgr.CurHairColorIndex = 1
    GMCharacterEditorMgr.CurHairVariationColorIndex = 1
    GMCharacterEditorMgr.CurFaceDecalColorIndex = 1
    GMCharacterEditorMgr.CurLEyeColorIndex = 1
    GMCharacterEditorMgr.CurREyeColorIndex = 1
    GMCharacterEditorMgr.CurLipColorIndex = 1

    local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
        local AttachType = AvatarComp:GetAttachType()
        self.RaceComboBox:SetSelectedOption(AttachType)

        if GMCharacterEditorMgr.OriginAttachType == nil then
            GMCharacterEditorMgr.OriginAttachType = AttachType
        end
    end

    --self.RaceComboBox:SetSelectedIndex(0)
    --self.TribeComboBox:SetSelectedIndex(0)
    --self.GenderComboBox:SetSelectedIndex(0)

    self.HairComboBox:SetSelectedIndex(0)
    self.FaceComboBox:SetSelectedIndex(0)
    self.FaceDecalComboBox:SetSelectedIndex(0)
    self.EarComboBox:SetSelectedIndex(0)
    self.TailComboBox:SetSelectedIndex(0)

    self.FaceContourTableViewAdapter:SetSelectedIndex(1)
    self.EyeTableViewAdapter:SetSelectedIndex(1)
    self.EyebrowTableViewAdapter:SetSelectedIndex(1)
    self.NoseTableViewAdapter:SetSelectedIndex(1)
    self.LipsTableViewAdapter:SetSelectedIndex(1)
end

function CharacterRacePanelView:UpdateComboBox()
    if self.CurAttachType == nil or self.CurHair then
        FLOG_WARNING("[CharacterRacePanelView:UpdateComboBox] CurAttachType or CurHair is nil")
        self:ResetData()
        return
    end
    FLOG_INFO("[CharacterRacePanelView:UpdateComboBox]")

    self.RaceComboBox:SetSelectedOption(self.CurAttachType)
    self.TribeComboBox:SetSelectedOption(self.CurTribeName)

    self.GenderComboBox:SetSelectedIndex(self.CurGenderIndex)

    self.HairComboBox:SetSelectedOption(self.CurHair)
    self.FaceComboBox:SetSelectedOption(self.CurFace)
    self.FaceDecalComboBox:SetSelectedOption(self.CurFaceDecal)
    self.EarComboBox:SetSelectedOption(self.CurEar)
    self.TailComboBox:SetSelectedOption(self.CurTail)
end

function CharacterRacePanelView:OnHeightSliderValueChanged()
    local NewValue = math.floor(self.HeightSlider:GetValue())
    FLOG_INFO("[CharacterRacePanelView:OnHeightSliderValueChanged] NewValue: " .. NewValue)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarHeightScaleRate, NewValue)
end

function CharacterRacePanelView:OnChestSliderValueChanged()
    local NewValue = math.floor(self.ChestSlider:GetValue())
    FLOG_INFO("[CharacterRacePanelView:OnChestSliderValueChanged] NewValue: " .. NewValue)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarChestSize, NewValue)
end

function CharacterRacePanelView:OnMuscleSliderValueChanged()
    local NewValue = math.floor(self.MuscleSlider:GetValue())
    FLOG_INFO("[CharacterRacePanelView:OnMuscleSliderValueChanged] NewValue: " .. NewValue)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarSpecific1, NewValue)
end

function CharacterRacePanelView:OnTailSliderValueChanged()
    local NewValue = math.floor(self.TailSlider2:GetValue())
    FLOG_INFO("[CharacterRacePanelView:OnTailSliderValueChanged] NewValue: " .. NewValue)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarSpecific1, NewValue)
end

function CharacterRacePanelView:OnEarSliderValueChanged()
    local NewValue = math.floor(self.EarSlider2:GetValue())
    FLOG_INFO("[CharacterRacePanelView:OnEarSliderValueChanged] NewValue: " .. NewValue)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarSpecific1, NewValue)
end

function CharacterRacePanelView:OnMaskButtonClicked()
    self.GMCharacterEditorVM.IsShowColorPanel = false
end

function CharacterRacePanelView:OnNoneBtnClicked()
    local PartKey
    if GMCharacterEditorMgr.CurShowColorPanelType == ProtoCommon.avatar_personal.AvatarLipsColor then
        PartKey = ProtoCommon.avatar_personal.AvatarLipMode
    elseif GMCharacterEditorMgr.CurShowColorPanelType == ProtoCommon.avatar_personal.AvatarHairVariationColor then
        PartKey = ProtoCommon.avatar_personal.AvatarHairVariation
    end
    GMCharacterEditorMgr:OnFaceChanged(PartKey, 0)
end

function CharacterRacePanelView:OnSkinColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarSkinColor
    self.GMCharacterEditorVM.IsShowColorPanel = true
    self.GMCharacterEditorVM.ShowColorTypeSwitch = false
    self.GMCharacterEditorVM.ShowNoneText = false
    FLOG_INFO("[CharacterRacePanelView:OnSkinColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurSkinColorIndex)

    self.GMCharacterEditorVM:UpdateColorTableList("SkinColorBtn", GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarSkinColor))
    self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurSkinColorIndex)
end

function CharacterRacePanelView:OnHairColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarPersonalHairColor
    self.GMCharacterEditorVM.IsShowColorPanel = true
    self.GMCharacterEditorVM.ShowColorTypeSwitch = false
    self.GMCharacterEditorVM.ShowNoneText = false
    FLOG_INFO("[CharacterRacePanelView:OnHairColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurHairColorIndex)

    self.GMCharacterEditorVM:UpdateColorTableList("HairColorBtn", GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarPersonalHairColor))
    self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurHairColorIndex)
end

function CharacterRacePanelView:OnHairVariationColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarHairVariationColor
    self.GMCharacterEditorVM.IsShowColorPanel = true
    self.GMCharacterEditorVM.ShowColorTypeSwitch = false
    self.GMCharacterEditorVM.ShowNoneText = true
    FLOG_INFO("[CharacterRacePanelView:OnHairVariationColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurHairVariationColorIndex)

    self.GMCharacterEditorVM:UpdateColorTableList("HairVariationBtn", GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarHairVariationColor))
    self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurHairVariationColorIndex)
end

function CharacterRacePanelView:OnLEyeColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarLeftEyeColor
    self.GMCharacterEditorVM.IsShowColorPanel = true
    self.GMCharacterEditorVM.ShowColorTypeSwitch = false
    self.GMCharacterEditorVM.ShowNoneText = false
    FLOG_INFO("[CharacterRacePanelView:OnLEyeColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurLEyeColorIndex)

    self.GMCharacterEditorVM:UpdateColorTableList("LEyeColorBtn", GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarLeftEyeColor))
    self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurLEyeColorIndex)
end

function CharacterRacePanelView:OnREyeColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarRightEyeColor
    self.GMCharacterEditorVM.IsShowColorPanel = true
    self.GMCharacterEditorVM.ShowColorTypeSwitch = false
    self.GMCharacterEditorVM.ShowNoneText = false
    FLOG_INFO("[CharacterRacePanelView:OnREyeColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurREyeColorIndex)

    self.GMCharacterEditorVM:UpdateColorTableList("REyeColorBtn", GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarRightEyeColor))
    self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurREyeColorIndex)
end

function CharacterRacePanelView:OnLipColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarLipsColor
    FLOG_INFO("[CharacterRacePanelView:OnLipColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurLipColorIndex)
    self:OnClickedTypeSwitchParam(true)
end

function CharacterRacePanelView:OnFaceDecalColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowColorPanel then
        self.GMCharacterEditorVM.IsShowColorPanel = false
        return
    end

    GMCharacterEditorMgr.CurShowColorPanelType = ProtoCommon.avatar_personal.AvatarFaceDecalColor
    FLOG_INFO("[CharacterRacePanelView:OnFaceDecalColorButtonClicked] ColorType:%d, Index:%d", GMCharacterEditorMgr.CurShowColorPanelType, GMCharacterEditorMgr.CurFaceDecalColorIndex)
    self:OnClickedTypeSwitchParam(true)
end

function CharacterRacePanelView:OnClickedTypeSwitchParam(IsLeft)
    --self.ViewModel:UpdateParamSwitchSelected(IsLeft)
    ---- 切换colorlist选中项
    --local SelectIndex = self.ViewModel.ColorTableIndex
    --if SelectIndex == 0 then
    --    self.ColorTableView:CancelSelected()
    --    self.ColorTableView:ScrollToTop()
    --else
    --    self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
    --    self.ColorTableView:ScrollIndexIntoView(self.ViewModel.ColorTableIndex)
    --end
    --self:SetColorPanelSize()

    FLOG_INFO("[CharacterRacePanelView:OnClickedTypeSwitchParam] IsLeft:%s", IsLeft)
    self.IsColorTypeSwitchLeft = IsLeft
    self.TypeSwitch:SetSwitchState(IsLeft)

    if GMCharacterEditorMgr.CurShowColorPanelType == ProtoCommon.avatar_personal.AvatarLipsColor then
        self.GMCharacterEditorVM.IsShowColorPanel = true
        self.GMCharacterEditorVM.ShowColorTypeSwitch = true
        self.GMCharacterEditorVM.ShowNoneText = true

        local ColorList = GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarLipsColor)
        if IsLeft == true then
            self.GMCharacterEditorVM:UpdateColorTableList("LipColorBtn", ColorList)
        else
            local ModifiedColorList = {}
            for i, v in ipairs(ColorList) do
                ModifiedColorList[i] = { ColorType = v.ColorType, Color = v.Color, DataValue = v.DataValue + 128 }
            end
            self.GMCharacterEditorVM:UpdateColorTableList("LipColorBtn", ModifiedColorList)
        end

        self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurLipColorIndex)

    elseif GMCharacterEditorMgr.CurShowColorPanelType == ProtoCommon.avatar_personal.AvatarFaceDecalColor then
        self.GMCharacterEditorVM.IsShowColorPanel = true
        self.GMCharacterEditorVM.ShowColorTypeSwitch = true
        self.GMCharacterEditorVM.ShowNoneText = false

        local ColorList = GMCharacterEditorMgr:GetColorListByType(ProtoCommon.avatar_personal.AvatarFaceDecalColor)
        if IsLeft == true then
            self.GMCharacterEditorVM:UpdateColorTableList("FaceDecalColorBtn", ColorList)
        else
            local ModifiedColorList = {}
            for i, v in ipairs(ColorList) do
                ModifiedColorList[i] = { ColorType = v.ColorType, Color = v.Color, DataValue = v.DataValue + 128 }
            end
            self.GMCharacterEditorVM:UpdateColorTableList("FaceDecalColorBtn", ModifiedColorList)
        end

        self.ColorTableViewAdapter:SetSelectedIndex(GMCharacterEditorMgr.CurFaceDecalColorIndex)
    end
end

--region Race =========================================================================================================>>>

function CharacterRacePanelView:OnAttachTypeListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnAttachTypeListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.RaceComboBox, self.GMCharacterEditorVM.AttachTypeList)
end

function CharacterRacePanelView:OnTribeNameListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnTribeNameListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.TribeComboBox, self.GMCharacterEditorVM.TribeNameList)
end

function CharacterRacePanelView:OnGenderListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnGenderListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.GenderComboBox, self.GMCharacterEditorVM.GenderList)
end

function CharacterRacePanelView:OnRaceComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[CharacterRacePanelView:OnRaceComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[CharacterRacePanelView:OnRaceComboBoxSelectionChanged] SelectedItem: %s, SelectionType:%d", SelectedItem, SelectionType)
    self.CurAttachType = SelectedItem
    GMCharacterEditorMgr:OnAttachTypeChanged(SelectedItem)

    self.TribeComboBox:SetSelectedIndex(0)
    self.GenderComboBox:SetSelectedIndex(0)
end

function CharacterRacePanelView:OnTribeComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[CharacterRacePanelView:OnTribeComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[CharacterRacePanelView:OnTribeComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurTribeName = SelectedItem
    GMCharacterEditorMgr:OnTribeChanged(SelectedItem)
end

function CharacterRacePanelView:OnGenderComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[CharacterRacePanelView:OnGenderComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    --local Index = self.GenderComboBox:FindOptionIndex(SelectedItem)
    --local Gender = Index + 1
    --FLOG_INFO("[CharacterRacePanelView:OnGenderComboBoxSelectionChanged] SelectedItem: %s, Index:%d", SelectedItem, Index or -1)
    --self.CurGenderIndex = Index
    --GMCharacterEditorMgr:OnGenderChanged(Gender)

    GMCharacterEditorMgr:OnGenderChanged()
end

function CharacterRacePanelView:OnGMCRaceTribeGenderChanged()
    FLOG_INFO("[CharacterRacePanelView:OnGMCRaceTribeGenderChanged]")
    self.HairComboBox:SetSelectedIndex(0)
    self.FaceComboBox:SetSelectedIndex(0)
    self.FaceDecalComboBox:SetSelectedIndex(0)
    self.EarComboBox:SetSelectedIndex(0)
    self.TailComboBox:SetSelectedIndex(0)

    self.FaceContourTableViewAdapter:SetSelectedIndex(1)
    self.EyeTableViewAdapter:SetSelectedIndex(1)
    self.EyebrowTableViewAdapter:SetSelectedIndex(1)
    self.NoseTableViewAdapter:SetSelectedIndex(1)
    self.LipsTableViewAdapter:SetSelectedIndex(1)

    self.GMCharacterEditorVM.HeightValue = 50
    self.HeightSlider:SetMinValue(0)
    self.HeightSlider:SetMaxValue(100)

    UIUtil.SetIsVisible(self.ChestSlider, GMCharacterEditorMgr:IsContainSubType(LoginAvatarMgr.CustomizeSubType.ChestSize), true)
    self.GMCharacterEditorVM.ChestValue = 50
    self.ChestSlider:SetMinValue(0)
    self.ChestSlider:SetMaxValue(100)

    UIUtil.SetIsVisible(self.MuscleSlider, GMCharacterEditorMgr:IsContainSubType(LoginAvatarMgr.CustomizeSubType.BodyType), true)
    self.GMCharacterEditorVM.MuscleValue = 50
    self.MuscleSlider:SetMinValue(0)
    self.MuscleSlider:SetMaxValue(100)

    local TailVisible = GMCharacterEditorMgr:IsContainSubType(LoginAvatarMgr.CustomizeSubType.Tail)
    UIUtil.SetIsVisible(self.TailComboBox, TailVisible, true)
    UIUtil.SetIsVisible(self.TailSlider2, TailVisible, true)
    self.GMCharacterEditorVM.TailValue = 25
    self.TailSlider2:SetMinValue(0)
    self.TailSlider2:SetMaxValue(100)

    local EarVisible = GMCharacterEditorMgr:IsContainSubType(LoginAvatarMgr.CustomizeSubType.Ear)
    UIUtil.SetIsVisible(self.EarComboBox, EarVisible, true)
    UIUtil.SetIsVisible(self.EarSlider2, EarVisible, true)
    self.GMCharacterEditorVM.EarValue = 25
    self.EarSlider2:SetMinValue(0)
    self.EarSlider2:SetMaxValue(100)

    GMCharacterEditorMgr:ResetAllCurColorIndex()
end

--endregion Race <<<=========================================================================================================

--region Face =========================================================================================================>>>

function CharacterRacePanelView:OnHairListChanged()
    FLOG_INFO("[CharacterRacePanelView:OnHairListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.HairComboBox, self.GMCharacterEditorVM.HairList)
end

function CharacterRacePanelView:OnFaceListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnFaceListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.FaceComboBox, self.GMCharacterEditorVM.FaceList)
end

function CharacterRacePanelView:OnFaceDecalListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnFaceDecalListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.FaceDecalComboBox, self.GMCharacterEditorVM.FaceDecalList)
end

function CharacterRacePanelView:OnFaceEarListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnFaceEarListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.EarComboBox, self.GMCharacterEditorVM.FaceEarList)
end

function CharacterRacePanelView:OnTailListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnTailListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.TailComboBox, self.GMCharacterEditorVM.TailList)
end

function CharacterRacePanelView:OnFaceContourListChanged()
    --FLOG_INFO("[CharacterRacePanelView:OnFaceContourListChanged]")

end

function CharacterRacePanelView:OnHairComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    FLOG_INFO("[CharacterRacePanelView:OnHairComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    self.CurHair = SelectedItem
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarPersonalHair, SelectedItem)
end

function CharacterRacePanelView:OnFaceComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    FLOG_INFO("[CharacterRacePanelView:OnFaceComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    self.CurFace = SelectedItem
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarFaceBase, SelectedItem)
end

function CharacterRacePanelView:OnFaceDecalComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    FLOG_INFO("[CharacterRacePanelView:OnFaceDecalComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    self.CurFaceDecal = SelectedItem
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarFaceDecal, SelectedItem)
end

function CharacterRacePanelView:OnFaceEarComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    FLOG_INFO("[CharacterRacePanelView:OnFaceEarComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    self.CurEar = SelectedItem
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarSpecific2, SelectedItem)
end

function CharacterRacePanelView:OnTailComboBoxSelectionChanged(this, SelectedItem, SelectionType)
    FLOG_INFO("[CharacterRacePanelView:OnTailComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    self.CurTail = SelectedItem
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarSpecific2, SelectedItem)
end

function CharacterRacePanelView:OnFaceContourSelectChanged(Index, ItemData, ItemView)
    FLOG_INFO("[CharacterRacePanelView:OnFaceContourSelectChanged] Index: %d, ItemData: %d", Index, ItemData.ItemData)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarFaceContour, ItemData.ItemData)
end

function CharacterRacePanelView:OnEyeSelectChanged(Index, ItemData, ItemView)
    FLOG_INFO("[CharacterRacePanelView:OnEyeSelectChanged] Index: %d, ItemData: %d", Index, ItemData.ItemData)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarEye, ItemData.ItemData)
end

function CharacterRacePanelView:OnEyebrowSelectChanged(Index, ItemData, ItemView)
    FLOG_INFO("[CharacterRacePanelView:OnEyebrowSelectChanged] Index: %d, ItemData: %d", Index, ItemData.ItemData)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarEyeBrow, ItemData.ItemData)
end

function CharacterRacePanelView:OnNoseSelectChanged(Index, ItemData, ItemView)
    FLOG_INFO("[CharacterRacePanelView:OnNoseSelectChanged] Index: %d, ItemData: %d", Index, ItemData.ItemData)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarNose, ItemData.ItemData)
end

function CharacterRacePanelView:OnLipsSelectChanged(Index, ItemData, ItemView)
    FLOG_INFO("[CharacterRacePanelView:OnLipsSelectChanged] Index: %d, ItemData: %d", Index, ItemData.ItemData)
    GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarLips, ItemData.ItemData)
end

function CharacterRacePanelView:OnFaceOptionSelectChanged(Index, ItemData, ItemView)

end

function CharacterRacePanelView:OnColorSelectChanged(Index, ItemData, ItemView)
    if ItemData == nil then
        FLOG_WARNING("[CharacterRacePanelView:OnColorSelectChanged] ItemData is nil")
        return
    end

    local ColorList = GMCharacterEditorMgr:GetColorListByType(ItemData.ColorType)
    if ColorList == nil then
        FLOG_WARNING("[CharacterRacePanelView:OnColorSelectChanged] ColorList is nil")
        return
    end

    local ColorInfo = ColorList[Index]
    if ColorInfo == nil then
        FLOG_WARNING("[CharacterRacePanelView:OnColorSelectChanged] ColorInfo is nil")
        return
    end

    if ItemData.ColorType == ProtoCommon.avatar_personal.AvatarSkinColor then
        self.GMCharacterEditorVM.SkinColorBtn = ColorInfo
        GMCharacterEditorMgr.CurSkinColorIndex = Index
    elseif ItemData.ColorType == ProtoCommon.avatar_personal.AvatarPersonalHairColor then
        self.GMCharacterEditorVM.HairColorBtn = ColorInfo
        GMCharacterEditorMgr.CurHairColorIndex = Index
    elseif ItemData.ColorType == ProtoCommon.avatar_personal.AvatarHairVariationColor then
        self.GMCharacterEditorVM.HairVariationBtn = ColorInfo
        GMCharacterEditorMgr.CurHairVariationColorIndex = Index
        GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarHairVariation, 128)
    elseif ItemData.ColorType == ProtoCommon.avatar_personal.AvatarFaceDecalColor then
        if self.IsColorTypeSwitchLeft == false and ColorInfo.DataValue < 128 then
            ColorInfo.DataValue = ColorInfo.DataValue + 128
        end
        self.GMCharacterEditorVM.FaceDecalColorBtn = ColorInfo
        GMCharacterEditorMgr.CurFaceDecalColorIndex = Index
    elseif ItemData.ColorType == ProtoCommon.avatar_personal.AvatarLeftEyeColor then
        self.GMCharacterEditorVM.LEyeColorBtn = ColorInfo
        GMCharacterEditorMgr.CurLEyeColorIndex = Index
    elseif ItemData.ColorType == ProtoCommon.avatar_personal.AvatarRightEyeColor then
        self.GMCharacterEditorVM.REyeColorBtn = ColorInfo
        GMCharacterEditorMgr.CurREyeColorIndex = Index
    elseif ItemData.ColorType == ProtoCommon.avatar_personal.AvatarLipsColor then
        if self.IsColorTypeSwitchLeft == false and ColorInfo.DataValue < 128 then
            ColorInfo.DataValue = ColorInfo.DataValue + 128
        end
        self.GMCharacterEditorVM.LipColorBtn = ColorInfo
        GMCharacterEditorMgr.CurLipColorIndex = Index
        GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarLipMode, 1)
    end

    FLOG_INFO("[CharacterRacePanelView:OnColorSelectChanged] ColorType:%d, Index: %d, DataValue:%d", ItemData.ColorType, Index, ColorInfo.DataValue)
    GMCharacterEditorMgr:OnFaceChanged(ItemData.ColorType, ColorInfo.DataValue)
end

function CharacterRacePanelView:OnIsShowColorPanelChanged(NewValue)

end

function CharacterRacePanelView:OnSkinColorChanged(NewValue)
    self.SkinColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarSkinColor)
end

function CharacterRacePanelView:OnHairColorChanged(NewValue)
    self.HairColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarPersonalHairColor)
end

function CharacterRacePanelView:OnHairVariationColorChanged(NewValue)
    self.HairVariationColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarHairVariationColor)
end

function CharacterRacePanelView:OnFaceDecalColorChanged(NewValue)
    self.FaceDecalColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarFaceDecalColor)
end

function CharacterRacePanelView:OnLEyeColorChanged(NewValue)
    self.LEyeColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarLeftEyeColor)
end

function CharacterRacePanelView:OnREyeColorChanged(NewValue)
    self.REyeColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarRightEyeColor)
end

function CharacterRacePanelView:OnLipColorChanged(NewValue)
    self.LipColorButton:OnColorChanged(NewValue, ProtoCommon.avatar_personal.AvatarLipsColor)
end

--endregion Face <<<=========================================================================================================

function CharacterRacePanelView:OnShowColorPanel(bShow)
    UIUtil.SetIsVisible(self.PanelColor, bShow)
    UIUtil.SetIsVisible(self.MaskButton, bShow)
end

return CharacterRacePanelView