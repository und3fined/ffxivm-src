---
--- Author: muyanli
--- DateTime: 2025-06-21 10:58
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LocationImgDef = {
    [1] = "Texture2D'/Game/UI/Texture/House/UI_BG_HouseInfo_Location002.UI_BG_HouseInfo_Location002'",
    [2] = "Texture2D'/Game/UI/Texture/House/UI_BG_HouseInfo_Location003.UI_BG_HouseInfo_Location003'",
    [3] = "Texture2D'/Game/UI/Texture/House/UI_BG_HouseInfo_Location001.UI_BG_HouseInfo_Location001'"
}

---@class HouseMineBGView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommTab CommTabsView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field HouseTab House2TabPanelView
---@field ImgLocation UFImage
---@field PanelMain UNamedSlot
---@field PanelServerTag UOverlay
---@field TextHint UFTextBlock
---@field TextServer UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseMineBGView = LuaClass(UIView, true)

function HouseMineBGView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CloseBtn = nil
    -- self.CommTab = nil
    -- self.CommonBkg02_UIBP = nil
    -- self.CommonBkgMask_UIBP = nil
    -- self.CommonTitle = nil
    -- self.HouseTab = nil
    -- self.ImgLocation = nil
    -- self.PanelMain = nil
    -- self.PanelServerTag = nil
    -- self.TextHint = nil
    -- self.TextServer = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseMineBGView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CloseBtn)
    self:AddSubView(self.CommTab)
    self:AddSubView(self.CommonBkg02_UIBP)
    self:AddSubView(self.CommonBkgMask_UIBP)
    self:AddSubView(self.CommonTitle)
    self:AddSubView(self.HouseTab)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseMineBGView:OnInit()
    UIUtil.SetIsVisible(self.TextHint, false)
    self.OnSelectionChangedCallback = nil
end

function HouseMineBGView:OnDestroy()

end

function HouseMineBGView:OnShow()
    UIUtil.SetIsVisible(self.ImgLocation, false)
end

function HouseMineBGView:OnHide()

end

function HouseMineBGView:OnRegisterUIEvent()
     UIUtil.AddOnSelectionChangedEvent(self, self.HouseTab, self.OnSelectionChangedCommMenu)
end

function HouseMineBGView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseInfoOpenPage, self.OnHouseInfoOpenPage)
    self:RegisterGameEvent(_G.EventID.HouseMineBGLocationAni, self.OnHouseMineBGLocationAni)
end

function HouseMineBGView:OnRegisterBinder()

end

function HouseMineBGView:SetTitleInfo(TitleName, HelpInfoID)
    if TitleName ~= nil then
        self.CommonTitle:SetTextTitleName(TitleName)
    end

    if HelpInfoID then
        self.CommonTitle.CommInforBtn:SetHelpInfoID(HelpInfoID)
        self.CommonTitle:SetCommInforBtnIsVisible(true)
    else
        self.CommonTitle:SetCommInforBtnIsVisible(false)
    end
    self.TextServer:SetText(_G.LSTR(LoginNewVM:GetCurWorldName() or ""))
end

function HouseMineBGView:SetCommTabInfo(ListData,CallBack,SelectedIndex,selfObj)
    self.CommTab:SetTabStyle(1)
    self.CommTab:UpdateItems(ListData, SelectedIndex)
	self.CommTab:SetCallBack(selfObj, CallBack)
end

function HouseMineBGView:SetTextHint(Str)
    UIUtil.SetIsVisible(self.TextHint, true)
    self.TextHint:SetText(Str)
end

function HouseMineBGView:SetTabView(TabList, CurrentKey)
    self.HouseTab:UpdateItems(TabList, false)
    self.HouseTab:SetSelectedKey(CurrentKey, true)
end

function HouseMineBGView:SetOnSelectionChangedCallback(Callback,selfObj)
    self.OnSelectionChangedCallback = Callback
    self.OnSelectionChangedCallbackselfObj = selfObj
end

function HouseMineBGView:OnSelectionChangedCommMenu(Index, ItemData, ItemView, MainKey, SubKey)
    UIUtil.SetIsVisible(self.ImgLocation, false)
    if self.OnSelectionChangedCallbackselfObj and self.OnSelectionChangedCallback then
        self.OnSelectionChangedCallback(self.OnSelectionChangedCallbackselfObj,Index, ItemData, ItemView, MainKey, SubKey)
    end
end

function HouseMineBGView:OnHouseInfoOpenPage(Key)
    self.HouseTab:SetSelectedKey(Key)
end

function HouseMineBGView:OnHouseMineBGLocationAni(Addr)
    local EstateID = Addr.EstateID or 1
    UIUtil.SetIsVisible(self.ImgLocation, true)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgLocation, LocationImgDef[EstateID])
    self:PlayAnimation(self.AnimSwitch)
end

return HouseMineBGView
