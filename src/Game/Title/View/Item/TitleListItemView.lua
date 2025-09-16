local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TitleDefine = require("Game/Title/TitleDefine")

local EToggleButtonState = _G.UE.EToggleButtonState
local TitleMgr = _G.TitleMgr

---@class TitleListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBarNormal UFImage
---@field ImgFavorite UFImage
---@field ImgIcon UFImage
---@field ImgUsed UFImage
---@field PanelTitle UFCanvasPanel
---@field RedDot CommRedDotSlotView
---@field RedDot2 CommonRedDot2View
---@field TextItem UFTextBlock
---@field ToggleBtn UToggleButton
---@field AnimFavoriteShow UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimToggleBtnChecked UWidgetAnimation
---@field AnimUsedShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TitleListItemView = LuaClass(UIView, true)

function TitleListItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBarNormal = nil
	--self.ImgFavorite = nil
	--self.ImgIcon = nil
	--self.ImgUsed = nil
	--self.PanelTitle = nil
	--self.RedDot = nil
	--self.RedDot2 = nil
	--self.TextItem = nil
	--self.ToggleBtn = nil
	--self.AnimFavoriteShow = nil
	--self.AnimIn = nil
	--self.AnimToggleBtnChecked = nil
	--self.AnimUsedShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TitleListItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TitleListItemView:OnInit()
    self.Binders = {
        {"ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDChanged)},
        {"IsFavorite", UIBinderValueChangedCallback.New(self, nil, self.OnIsFavoriteChanged)},
        {"TitleText", UIBinderSetText.New(self, self.TextItem)},
        {"IsUnLock", UIBinderValueChangedCallback.New(self, nil, self.OnIsUnLockChanged)},
        {"IsUsed", UIBinderValueChangedCallback.New(self, nil, self.OnIsUsedChanged)},
        {"IsNew", UIBinderSetIsVisible.New(self, self.RedDot)},
        {"ToggleBtnState", UIBinderSetCheckedState.New(self, self.ToggleBtn)}
    }
end

function TitleListItemView:OnDestroy()
end

function TitleListItemView:OnShow()
    self.ImgFavorite:SetRenderScale(_G.UE.FVector2D(1, 1))
end

function TitleListItemView:OnHide()
end

function TitleListItemView:OnRegisterUIEvent()

end

function TitleListItemView:OnRegisterGameEvent()
end

function TitleListItemView:OnRegisterBinder()
    if nil == self.Params or nil == self.Params.Data then
        return
    end
    local ViewModel = self.Params.Data

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function TitleListItemView:OnIDChanged(NewValue, OldValue)
    UIUtil.SetIsVisible(self.PanelTitle, (NewValue or 0) ~= 0)  
	if TitleMgr:CheckNewTitle(NewValue) then
		self.RedDot2:SetRedDotNameByString(TitleDefine.RedDotName .. '/' .. tostring(NewValue or ""))
	else
		self.RedDot2:SetRedDotNameByString("")
	end
end

function TitleListItemView:OnIsFavoriteChanged(NewValue, OldValue)
    UIUtil.SetIsVisible(self.ImgFavorite, NewValue or NewValue == nil )
    local ViewModel = self.ViewModel or {}
    if NewValue == nil and ViewModel then
       self:PlayAnimation(self.AnimFavoriteShow)
       ViewModel.IsFavorite = true
    end
end

function TitleListItemView:OnIsUsedChanged(NewValue, OldValue)
    UIUtil.SetIsVisible(self.ImgUsed, NewValue or NewValue == nil )
    local ViewModel = self.ViewModel
    if NewValue == nil and ViewModel then
        self:PlayAnimation(self.AnimUsedShow)
        ViewModel.IsUsed = true
    end
end

function TitleListItemView:OnIsUnLockChanged(NewValue, OldValue)
    if NewValue then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgBarNormal, "Texture2D'/Game/UI/Texture/Title/UI_Title_Img_ListUnLock.UI_Title_Img_ListUnLock'")
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon,  "PaperSprite'/Game/UI/Atlas/Title/Frames/UI_Title_Icon_Normal_png.UI_Title_Icon_Normal_png'")
    else
        UIUtil.ImageSetBrushFromAssetPath(self.ImgBarNormal,  "Texture2D'/Game/UI/Texture/Title/UI_Title_Img_ListNormal.UI_Title_Img_ListNormal'")
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon,  "PaperSprite'/Game/UI/Atlas/Title/Frames/UI_Title_Icon_UnLock_png.UI_Title_Icon_UnLock_png'")
    end
end

function TitleListItemView:OnSelectChanged(IsSelected, IsByClick)
    local ViewModel = self.ViewModel
    if ViewModel == nil then
        return
    end
	if IsByClick then
		self.RedDot2:SetRedDotNameByString("")
		TitleMgr:RemoveNewTitle(ViewModel.ID)
	end

    if IsSelected then
        if ViewModel.ToggleBtnState == EToggleButtonState.Unchecked then
            ViewModel.ToggleBtnState = EToggleButtonState.Checked
        end
    else
        if ViewModel.ToggleBtnState == EToggleButtonState.Checked then
            ViewModel.ToggleBtnState = EToggleButtonState.Unchecked
        end
    end
end

return TitleListItemView
