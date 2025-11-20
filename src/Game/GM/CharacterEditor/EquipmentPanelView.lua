---
--- Author: richyczhou
--- DateTime: 2025-08-01 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GMCharacterUtil = require("Game/GM/CharacterEditor/GMCharacterUtil")
local GMCharacterEditorMgr = require("Game/GM/CharacterEditor/GMCharacterEditorMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class EquipmentPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DwnButton UButton
---@field DwnComboBox UComboBoxString
---@field DwnImageComboBox UComboBoxString
---@field EarButton UButton
---@field EarComboBox UComboBoxString
---@field EarImageComboBox UComboBoxString
---@field GlvButton UButton
---@field GlvComboBox UComboBoxString
---@field GlvImageComboBox UComboBoxString
---@field MetButton UButton
---@field MetComboBox UComboBoxString
---@field MetImageComboBox UComboBoxString
---@field NekButton UButton
---@field NekComboBox UComboBoxString
---@field NekImageComboBox UComboBoxString
---@field RilButton UButton
---@field RilComboBox UComboBoxString
---@field RilImageComboBox UComboBoxString
---@field RirButton UButton
---@field RirComboBox UComboBoxString
---@field RirImageComboBox UComboBoxString
---@field ShoButton UButton
---@field ShoComboBox UComboBoxString
---@field ShoImageComboBox UComboBoxString
---@field StainColorMaskButton UButton
---@field StainColorPanel UCanvasPanel
---@field StainListPanel UCanvasPanel
---@field StainMaskButton UButton
---@field StainTableView UTableView
---@field TopButton UButton
---@field TopComboBox UComboBoxString
---@field TopImageComboBox UComboBoxString
---@field Weapon1BComboBox UComboBoxString
---@field Weapon1ComboBox UComboBoxString
---@field Weapon1ImageComboBox UComboBoxString
---@field Weapon2BComboBox UComboBoxString
---@field Weapon2ComboBox UComboBoxString
---@field Weapon2ImageComboBox UComboBoxString
---@field WrsButton UButton
---@field WrsComboBox UComboBoxString
---@field WrsImageComboBox UComboBoxString
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentPanelView = LuaClass(UIView, true)

function EquipmentPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DwnButton = nil
	--self.DwnComboBox = nil
	--self.DwnImageComboBox = nil
	--self.EarButton = nil
	--self.EarComboBox = nil
	--self.EarImageComboBox = nil
	--self.GlvButton = nil
	--self.GlvComboBox = nil
	--self.GlvImageComboBox = nil
	--self.MetButton = nil
	--self.MetComboBox = nil
	--self.MetImageComboBox = nil
	--self.NekButton = nil
	--self.NekComboBox = nil
	--self.NekImageComboBox = nil
	--self.RilButton = nil
	--self.RilComboBox = nil
	--self.RilImageComboBox = nil
	--self.RirButton = nil
	--self.RirComboBox = nil
	--self.RirImageComboBox = nil
	--self.ShoButton = nil
	--self.ShoComboBox = nil
	--self.ShoImageComboBox = nil
	--self.StainColorMaskButton = nil
	--self.StainColorPanel = nil
	--self.StainListPanel = nil
	--self.StainMaskButton = nil
	--self.StainTableView = nil
	--self.TopButton = nil
	--self.TopComboBox = nil
	--self.TopImageComboBox = nil
	--self.Weapon1BComboBox = nil
	--self.Weapon1ComboBox = nil
	--self.Weapon1ImageComboBox = nil
	--self.Weapon2BComboBox = nil
	--self.Weapon2ComboBox = nil
	--self.Weapon2ImageComboBox = nil
	--self.WrsButton = nil
	--self.WrsComboBox = nil
	--self.WrsImageComboBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    self.CurMet = nil
    self.CurTop = nil
    self.CurGlv = nil
    self.CurDwn = nil
    self.CurSho = nil
    self.CurEar = nil
    self.CurNek = nil
    self.CurWrs = nil
    self.CurRir = nil
    self.CurRil = nil
    self.CurWeapon1 = nil
    self.CurWeapon2 = nil
end

function EquipmentPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentPanelView:OnInit()
    self.GMCharacterEditorVM = GMCharacterEditorMgr:GetCharacterEditorVM()

    self.StainTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.StainTableView)
    self.ColorTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.StainColorTableView, self.OnColorSelectChanged,false)

    self:InitBinders()
end

function EquipmentPanelView:OnDestroy()

end

function EquipmentPanelView:OnShow()
    FLOG_INFO("[EquipmentPanelView:OnShow]")
    if self.IsInit then
        self:UpdateComboBox()
    else
        self.IsInit = true
        self:ResetData()
    end
end

function EquipmentPanelView:OnHide()

end

function EquipmentPanelView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.MetComboBox, self.OnMetComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.TopComboBox, self.OnTopComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.GlvComboBox, self.OnGlvComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.DwnComboBox, self.OnDwnComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.ShoComboBox, self.OnShoComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.EarComboBox, self.OnEarComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.NekComboBox, self.OnNekComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.WrsComboBox, self.OnWrsComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.RirComboBox, self.OnRirComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.RilComboBox, self.OnRilComboBoxSelectionChanged)

    UIUtil.AddOnSelectionChangedEvent(self, self.MetImageComboBox, self.OnMetImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.TopImageComboBox, self.OnTopImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.GlvImageComboBox, self.OnGlvImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.DwnImageComboBox, self.OnDwnImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.ShoImageComboBox, self.OnShoImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.EarImageComboBox, self.OnEarImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.NekImageComboBox, self.OnNekImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.WrsImageComboBox, self.OnWrsImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.RirImageComboBox, self.OnRirImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.RilImageComboBox, self.OnRilImageComboBoxSelectionChanged)

    UIUtil.AddOnSelectionChangedEvent(self, self.Weapon1ComboBox, self.OnWeapon1ComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.Weapon2ComboBox, self.OnWeapon2ComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.Weapon1BComboBox, self.OnWeapon1BComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.Weapon2BComboBox, self.OnWeapon2BComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.Weapon1ImageComboBox, self.OnWeapon1ImageComboBoxSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.Weapon2ImageComboBox, self.OnWeapon2ImageComboBoxSelectionChanged)

    UIUtil.AddOnClickedEvent(self, self.StainMaskButton, self.OnStainMaskButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.StainColorMaskButton, self.OnStainColorMaskButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.MetButton, self.OnMetButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.TopButton, self.OnTopButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.GlvButton, self.OnGlvButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.DwnButton, self.OnDwnButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.ShoButton, self.OnShoButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.EarButton, self.OnEarButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.NekButton, self.OnNekButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.WrsButton, self.OnWrsButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.RirButton, self.OnRirButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.RilButton, self.OnRilButtonClicked)
end

function EquipmentPanelView:OnRegisterGameEvent()

end

function EquipmentPanelView:OnRegisterBinder()
    self:RegisterBinders(self.GMCharacterEditorVM, self.Binders)
end

function EquipmentPanelView:InitBinders()
    self.Binders = {
        { "MetList", UIBinderValueChangedCallback.New(self, nil, self.OnMetListChanged) },
        { "TopList", UIBinderValueChangedCallback.New(self, nil, self.OnTopListChanged) },
        { "GlvList", UIBinderValueChangedCallback.New(self, nil, self.OnGlvListChanged) },
        { "DwnList", UIBinderValueChangedCallback.New(self, nil, self.OnDwnListChanged) },
        { "ShoList", UIBinderValueChangedCallback.New(self, nil, self.OnShoListChanged) },
        { "EarList", UIBinderValueChangedCallback.New(self, nil, self.OnEarListChanged) },
        { "NekList", UIBinderValueChangedCallback.New(self, nil, self.OnNekListChanged) },
        { "WrsList", UIBinderValueChangedCallback.New(self, nil, self.OnWrsListChanged) },
        { "RirList", UIBinderValueChangedCallback.New(self, nil, self.OnRirListChanged) },
        { "RilList", UIBinderValueChangedCallback.New(self, nil, self.OnRilListChanged) },

        { "MetImageList", UIBinderValueChangedCallback.New(self, nil, self.OnMetImageListChanged) },
        { "TopImageList", UIBinderValueChangedCallback.New(self, nil, self.OnTopImageListChanged) },
        { "GlvImageList", UIBinderValueChangedCallback.New(self, nil, self.OnGlvImageListChanged) },
        { "DwnImageList", UIBinderValueChangedCallback.New(self, nil, self.OnDwnImageListChanged) },
        { "ShoImageList", UIBinderValueChangedCallback.New(self, nil, self.OnShoImageListChanged) },
        { "EarImageList", UIBinderValueChangedCallback.New(self, nil, self.OnEarImageListChanged) },
        { "NekImageList", UIBinderValueChangedCallback.New(self, nil, self.OnNekImageListChanged) },
        { "WrsImageList", UIBinderValueChangedCallback.New(self, nil, self.OnWrsImageListChanged) },
        { "RirImageList", UIBinderValueChangedCallback.New(self, nil, self.OnRirImageListChanged) },
        { "RilImageList", UIBinderValueChangedCallback.New(self, nil, self.OnRilImageListChanged) },

        { "Weapon1List", UIBinderValueChangedCallback.New(self, nil, self.OnWeapon1ListChanged) },
        { "Weapon2List", UIBinderValueChangedCallback.New(self, nil, self.OnWeapon2ListChanged) },
        { "Weapon1BList", UIBinderValueChangedCallback.New(self, nil, self.OnWeapon1BListChanged) },
        { "Weapon2BList", UIBinderValueChangedCallback.New(self, nil, self.OnWeapon2BListChanged) },
        { "Weapon1ImageList", UIBinderValueChangedCallback.New(self, nil, self.OnWeapon1ImageListChanged) },
        { "Weapon2ImageList", UIBinderValueChangedCallback.New(self, nil, self.OnWeapon2ImageListChanged) },

        { "IsShowStainListPanel", UIBinderSetIsVisible.New(self, self.StainListPanel) },
        { "IsShowStainListPanel", UIBinderSetIsVisible.New(self, self.StainMaskButton, false, true) },
        { "IsShowStainColorPanel", UIBinderSetIsVisible.New(self, self.StainColorPanel) },
        { "IsShowStainColorPanel", UIBinderSetIsVisible.New(self, self.StainColorMaskButton, false, true) },

        { "EquipStainList", UIBinderUpdateBindableList.New(self, self.StainTableViewAdapter) },
        { "EquipColorList", UIBinderUpdateBindableList.New(self, self.ColorTableViewAdapter) },
    }
end

function EquipmentPanelView:OnStainMaskButtonClicked()
    self.GMCharacterEditorVM.IsShowStainListPanel = false
end

function EquipmentPanelView:OnStainColorMaskButtonClicked()
    self.GMCharacterEditorVM.IsShowStainColorPanel = false
end

function EquipmentPanelView:OnMetButtonClicked()
    self:OnShowEquipStain("met")
end

function EquipmentPanelView:OnTopButtonClicked()
    self:OnShowEquipStain("top")
end

function EquipmentPanelView:OnGlvButtonClicked()
    self:OnShowEquipStain("glv")
end

function EquipmentPanelView:OnDwnButtonClicked()
    self:OnShowEquipStain("dwn")
end

function EquipmentPanelView:OnShoButtonClicked()
    self:OnShowEquipStain("sho")
end

function EquipmentPanelView:OnEarButtonClicked()
    self:OnShowEquipStain("ear")
end

function EquipmentPanelView:OnNekButtonClicked()
    self:OnShowEquipStain("nek")
end

function EquipmentPanelView:OnWrsButtonClicked()
    self:OnShowEquipStain("wrs")
end

function EquipmentPanelView:OnRirButtonClicked()
    self:OnShowEquipStain("rir")
end

function EquipmentPanelView:OnRilButtonClicked()
    self:OnShowEquipStain("ril")
end

function EquipmentPanelView:OnShowEquipStain(PartName)
    if self.GMCharacterEditorVM.IsShowStainListPanel then
        self.GMCharacterEditorVM.IsShowStainListPanel = false
        return
    end

    self.GMCharacterEditorVM.IsShowStainListPanel = true
    self.GMCharacterEditorVM.IsShowStainColorPanel = false
    GMCharacterEditorMgr.CurStainPartName = PartName

    self.GMCharacterEditorVM:UpdateEquipmentStainTableList(GMCharacterEditorMgr:GetEquipStainList(PartName))
end

function EquipmentPanelView:ResetData()
    self.MetComboBox:SetSelectedIndex(0)
    self.TopComboBox:SetSelectedIndex(0)
    self.GlvComboBox:SetSelectedIndex(0)
    self.DwnComboBox:SetSelectedIndex(0)
    self.ShoComboBox:SetSelectedIndex(0)
    self.EarComboBox:SetSelectedIndex(0)
    self.NekComboBox:SetSelectedIndex(0)
    self.WrsComboBox:SetSelectedIndex(0)
    self.RirComboBox:SetSelectedIndex(0)
    self.RilComboBox:SetSelectedIndex(0)

    self.Weapon1ComboBox:SetSelectedIndex(0)
    self.Weapon2ComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:UpdateComboBox()
    if self.CurWeapon1 == nil or self.CurMet then
        FLOG_WARNING("[EquipmentPanelView:UpdateComboBox] CurWeapon1 or CurMet is nil")
        self:ResetData()
        return
    end

    self.MetComboBox:SetSelectedOption(self.CurMet)
    self.TopComboBox:SetSelectedOption(self.CurTop)
    self.GlvComboBox:SetSelectedOption(self.CurGlv)
    self.DwnComboBox:SetSelectedOption(self.CurDwn)
    self.ShoComboBox:SetSelectedOption(self.CurSho)
    self.EarComboBox:SetSelectedOption(self.CurEar)
    self.NekComboBox:SetSelectedOption(self.CurNek)
    self.WrsComboBox:SetSelectedOption(self.CurWrs)
    self.RirComboBox:SetSelectedOption(self.CurRir)
    self.RilComboBox:SetSelectedOption(self.CurRil)

    self.Weapon1ComboBox:SetSelectedOption(self.CurWeapon1)
    self.Weapon2ComboBox:SetSelectedOption(self.CurWeapon2)
end

--region Equipment =========================================================================================================>>>


function EquipmentPanelView:OnMetListChanged()
    FLOG_INFO("[EquipmentPanelView:OnMetListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.MetComboBox, self.GMCharacterEditorVM.MetList)
end

function EquipmentPanelView:OnTopListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnTopListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.TopComboBox, self.GMCharacterEditorVM.TopList)
end

function EquipmentPanelView:OnGlvListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnGlvListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.GlvComboBox, self.GMCharacterEditorVM.GlvList)
end

function EquipmentPanelView:OnDwnListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnDwnListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.DwnComboBox, self.GMCharacterEditorVM.DwnList)
end

function EquipmentPanelView:OnShoListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnShoListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.ShoComboBox, self.GMCharacterEditorVM.ShoList)
end

function EquipmentPanelView:OnEarListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnEarListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.EarComboBox, self.GMCharacterEditorVM.EarList)
end

function EquipmentPanelView:OnNekListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnNekListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.NekComboBox, self.GMCharacterEditorVM.NekList)
end

function EquipmentPanelView:OnWrsListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnWrsListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.WrsComboBox, self.GMCharacterEditorVM.WrsList)
end

function EquipmentPanelView:OnRirListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnRirListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.RirComboBox, self.GMCharacterEditorVM.RirList)
end

function EquipmentPanelView:OnRilListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnRilListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.RilComboBox, self.GMCharacterEditorVM.RilList)
end

function EquipmentPanelView:OnWeapon1ListChanged()
    FLOG_INFO("[EquipmentPanelView:OnWeapon1ListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.Weapon1ComboBox, self.GMCharacterEditorVM.Weapon1List)
end

function EquipmentPanelView:OnWeapon2ListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnWeapon2ListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.Weapon2ComboBox, self.GMCharacterEditorVM.Weapon2List)
end

function EquipmentPanelView:OnMetComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnMetComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnMetComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurMet = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.MET, SelectedItem)
    self.MetImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnTopComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnTopComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnTopComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurTop = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.TOP, SelectedItem)
    self.TopImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnGlvComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnGlvComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnGlvComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurGlv = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.GLV, SelectedItem)
    self.GlvImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnDwnComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnDwnComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnDwnComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurDwn = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.DWN, SelectedItem)
    self.DwnImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnShoComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnShoComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnShoComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurSho = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.SHO, SelectedItem)
    self.ShoImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnEarComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnEarComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnEarComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurEar = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.EAR, SelectedItem)
    self.EarImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnNekComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnNekComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnNekComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurNek = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.NEK, SelectedItem)
    self.NekImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnWrsComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnWrsComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnWrsComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurWrs = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.WRS, SelectedItem)
    self.WrsImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnRirComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnRirComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnRirComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurRir = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.RIR, SelectedItem)
    self.RirImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnRilComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnRilComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnRilComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurRil = SelectedItem
    GMCharacterEditorMgr:OnEquipChanged(GMCharacterEditorMgr.PartNameMap.RIL, SelectedItem)
    self.RilImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnWeapon1ComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnWeapon1ComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnWeapon1ComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurWeapon1 = SelectedItem
    GMCharacterEditorMgr:OnWeaponChanged(SelectedItem, true)
    self.Weapon1BComboBox:SetSelectedIndex(0)
end


function EquipmentPanelView:OnWeapon2ComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    if SelectedItem == "" then
        FLOG_WARNING("[EquipmentPanelView:OnWeapon2ComboBoxSelectionChanged] SelectedItem is empty")
        return
    end

    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end

    FLOG_INFO("[EquipmentPanelView:OnWeapon2ComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    self.CurWeapon2 = SelectedItem
    GMCharacterEditorMgr:OnWeaponChanged(SelectedItem, false)
    self.Weapon2BComboBox:SetSelectedIndex(0)
end

--endregion Equipment <<<=========================================================================================================

--region Equipment ImageChange =========================================================================================================>>>


function EquipmentPanelView:OnMetImageListChanged()
    FLOG_INFO("[EquipmentPanelView:OnMetImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.MetImageComboBox, self.GMCharacterEditorVM.MetImageList)
end

function EquipmentPanelView:OnTopImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnTopImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.TopImageComboBox, self.GMCharacterEditorVM.TopImageList)
end

function EquipmentPanelView:OnGlvImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnGlvImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.GlvImageComboBox, self.GMCharacterEditorVM.GlvImageList)
end

function EquipmentPanelView:OnDwnImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnDwnImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.DwnImageComboBox, self.GMCharacterEditorVM.DwnImageList)
end

function EquipmentPanelView:OnShoImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnShoImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.ShoImageComboBox, self.GMCharacterEditorVM.ShoImageList)
end

function EquipmentPanelView:OnEarImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnEarImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.EarImageComboBox, self.GMCharacterEditorVM.EarImageList)
end

function EquipmentPanelView:OnNekImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnNekImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.NekImageComboBox, self.GMCharacterEditorVM.NekImageList)
end

function EquipmentPanelView:OnWrsImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnWrsImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.WrsImageComboBox, self.GMCharacterEditorVM.WrsImageList)
end

function EquipmentPanelView:OnRirImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnRirImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.RirImageComboBox, self.GMCharacterEditorVM.RirImageList)
end

function EquipmentPanelView:OnRilImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnRilImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.RilImageComboBox, self.GMCharacterEditorVM.RilImageList)
end

function EquipmentPanelView:OnWeapon1BListChanged()
    FLOG_INFO("[EquipmentPanelView:OnWeapon1BListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.Weapon1BComboBox, self.GMCharacterEditorVM.Weapon1BList)
end

function EquipmentPanelView:OnWeapon2BListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnWeapon2ListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.Weapon2BComboBox, self.GMCharacterEditorVM.Weapon2BList)
end

function EquipmentPanelView:OnWeapon1ImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnWeapon1ImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.Weapon1ImageComboBox, self.GMCharacterEditorVM.Weapon1ImageList)
end

function EquipmentPanelView:OnWeapon2ImageListChanged()
    --FLOG_INFO("[EquipmentPanelView:OnWeapon2ImageListChanged]")
    GMCharacterUtil:AddComboBoxItem(self.Weapon2ImageComboBox, self.GMCharacterEditorVM.Weapon2ImageList)
end

function EquipmentPanelView:OnMetImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnMetImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.MET, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnTopImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnTopImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.TOP, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnGlvImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnGlvImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.GLV, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnDwnImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnDwnImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.DWN, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnShoImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnShoImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.SHO, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnEarImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnEarImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.EAR, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnNekImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnNekImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.NEK, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnWrsImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnWrsImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.WRS, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnRirImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnRirImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.RIR, SelectedItem, SelectionType)
end

function EquipmentPanelView:OnRilImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnRilImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnEquipImageChanged(GMCharacterEditorMgr.PartNameMap.RIL, SelectedItem)
end

function EquipmentPanelView:OnWeapon1BComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnWeapon1BComboBoxSelectionChanged] SelectedItem: %s", SelectedItem, SelectionType)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnWeaponBChanged(SelectedItem, true)
    self.Weapon1ImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnWeapon2BComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnWeapon2BComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnWeaponBChanged(SelectedItem, false)
    self.Weapon2ImageComboBox:SetSelectedIndex(0)
end

function EquipmentPanelView:OnWeapon1ImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnWeapon1ImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnWeaponImageChanged(SelectedItem, true, SelectionType)
end

function EquipmentPanelView:OnWeapon2ImageComboBoxSelectionChanged(self, SelectedItem, SelectionType)
    FLOG_INFO("[EquipmentPanelView:OnWeapon2ImageComboBoxSelectionChanged] SelectedItem: %s", SelectedItem)
    if SelectionType ~= _G.UE.ESelectInfo.Direct then
        GMCharacterEditorMgr.bIsManual = true
    end
    GMCharacterEditorMgr:OnWeaponImageChanged(SelectedItem, false, SelectionType)
end

--endregion Equipment ImageChange <<<=========================================================================================================

function EquipmentPanelView:OnColorSelectChanged(Index, ItemData, ItemView)
    if ItemData == nil then
        FLOG_WARNING("[EquipmentPanelView:OnColorSelectChanged] ItemData is nil")
        return
    end

    local PartName = GMCharacterEditorMgr.CurStainPartName
    local SectionID = GMCharacterEditorMgr.CurStainSectionID

    FLOG_INFO("[EquipmentPanelView:OnColorSelectChanged] PartName: %s, SectionID: %d, ColorID: %d, HexColor: %s", PartName, SectionID, ItemData.ColorID, ItemData.HexColor)
    GMCharacterEditorMgr:SetEquipStainData(PartName, SectionID, ItemData.ColorID, ItemData.HexColor)

    self.GMCharacterEditorVM:UpdateEquipmentStainTableList(GMCharacterEditorMgr:GetEquipStainList(PartName))

    local PosKey = GMCharacterEditorMgr.CurArmorInfo[PartName].PosKey
    GMCharacterEditorMgr:StainPartForSection(PosKey, SectionID, ItemData.ColorID)
end

return EquipmentPanelView