---
--- Author: henghaoli
--- DateTime: 2024-01-09 09:50
--- Description:
---

local UIView = require("UI/UIView")
local UIViewMgr = require("UI/UIViewMgr")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CrafterCulinarianElementItemVM = require("Game/Crafter/View/Culinarian/CrafterCulinarianElementItemVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoRes = require("Protocol/ProtoRes")
local culinary_element_type = ProtoRes.culinary_element_type

local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local EElementItemViewType = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN].EElementItemViewType



---@class CrafterCulinarianElementItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Drop UFCanvasPanel
---@field ImgColor UFImage
---@field ImgElement UFImage
---@field PanelElement UFCanvasPanel
---@field Anim0 UWidgetAnimation
---@field AnimBenchEliminate UWidgetAnimation
---@field AnimColor1 UWidgetAnimation
---@field AnimColor2 UWidgetAnimation
---@field AnimColor3 UWidgetAnimation
---@field AnimColor4 UWidgetAnimation
---@field AnimColor5 UWidgetAnimation
---@field AnimColor6 UWidgetAnimation
---@field AnimDownShow UWidgetAnimation
---@field AnimEmpty UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimLightColor1 UWidgetAnimation
---@field AnimLightColor2 UWidgetAnimation
---@field AnimLightColor3 UWidgetAnimation
---@field AnimLightColor4 UWidgetAnimation
---@field AnimLightColor5 UWidgetAnimation
---@field AnimLightColor6 UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimShineHide UWidgetAnimation
---@field AnimShineShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterCulinarianElementItemView = LuaClass(UIView, true)

function CrafterCulinarianElementItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Drop = nil
	--self.ImgColor = nil
	--self.ImgElement = nil
	--self.PanelElement = nil
	--self.Anim0 = nil
	--self.AnimBenchEliminate = nil
	--self.AnimColor1 = nil
	--self.AnimColor2 = nil
	--self.AnimColor3 = nil
	--self.AnimColor4 = nil
	--self.AnimColor5 = nil
	--self.AnimColor6 = nil
	--self.AnimDownShow = nil
	--self.AnimEmpty = nil
	--self.AnimHide = nil
	--self.AnimLightColor1 = nil
	--self.AnimLightColor2 = nil
	--self.AnimLightColor3 = nil
	--self.AnimLightColor4 = nil
	--self.AnimLightColor5 = nil
	--self.AnimLightColor6 = nil
	--self.AnimLoop = nil
	--self.AnimShineHide = nil
	--self.AnimShineShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianElementItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianElementItemView:OnInit()

end

function CrafterCulinarianElementItemView:OnDestroy()

end

function CrafterCulinarianElementItemView:OnShow()
	local VM = self.VM
	if VM and VM.ElementItemViewType == EElementItemViewType.StormItem then
		VM.bIsVisible = true
	end
end

function CrafterCulinarianElementItemView:OnHide()

end

function CrafterCulinarianElementItemView:OnRegisterUIEvent()

end

function CrafterCulinarianElementItemView:OnRegisterGameEvent()

end

function CrafterCulinarianElementItemView:OnRegisterBinder()
	local Params = self.Params
	local VM = nil
	if Params then
		VM = Params.Data
	end

	-- 说明是非TableView的Element, 在AfflatusItemView里面或者味之本源里面
	if type(VM) ~= "table" then
		VM = CrafterCulinarianElementItemVM.New()
		VM.bIsVisible = true

		local Name = self:GetName()
		if Name == "Element" then
			local ParentView = self.ParentView
			ParentView.ElementVM = VM
			VM.ElementItemViewType = EElementItemViewType.AfflatusItem
		elseif Name == "ElementDrop" then
			VM.ElementItemViewType = EElementItemViewType.DropItem
		else
			VM.ElementItemViewType = EElementItemViewType.SourceItem
		end
	end
	self.VM = VM

	local Binders = {
		{ "ElementType", UIBinderValueChangedCallback.New(self, nil, self.OnElementTypeChanged) },
		{ "bIsVisible", UIBinderValueChangedCallback.New(self, nil, self.OnVisibleChanged) },
		{ "ImgColorIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor, false, false, true) },
		{ "bShine", UIBinderValueChangedCallback.New(self, nil, self.OnIsShineChanged) },
	}
	self:RegisterBinders(VM, Binders)
end

local ElementColorAnimMap = {
	[culinary_element_type.CULINARY_ELEMENT_TYPE_NONE] = "AnimHide",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY] = "AnimEmpty",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_COLOR] = "AnimColor1",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_SWEET] = "AnimColor2",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_TASTE] = "AnimColor3",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_TEXTURE] = "AnimColor4",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_SMELL] = "AnimColor5",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM] = "AnimColor6",
}

local ElementLightColorAnimMap = {
	[culinary_element_type.CULINARY_ELEMENT_TYPE_NONE] = "AnimHide",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY] = "AnimEmpty",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_COLOR] = "AnimLightColor1",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_SWEET] = "AnimLightColor2",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_TASTE] = "AnimLightColor3",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_TEXTURE] = "AnimLightColor4",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_SMELL] = "AnimLightColor5",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM] = "AnimLightColor6",
}

local ElementIconPathMap = {
	[culinary_element_type.CULINARY_ELEMENT_TYPE_NONE] = "",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY] = "",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_COLOR] = "Texture2D'/Game/UI/Texture/Crafter/UI_Culinarian_Img_Color.UI_Culinarian_Img_Color'",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_SWEET] = "Texture2D'/Game/UI/Texture/Crafter/UI_Culinarian_Img_Aroma.UI_Culinarian_Img_Aroma'",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_TASTE] = "Texture2D'/Game/UI/Texture/Crafter/UI_Culinarian_Img_Taste.UI_Culinarian_Img_Taste'",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_TEXTURE] = "Texture2D'/Game/UI/Texture/Crafter/UI_Culinarian_Img_Texture.UI_Culinarian_Img_Texture'",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_SMELL] = "Texture2D'/Game/UI/Texture/Crafter/UI_Culinarian_Img_Flavor.UI_Culinarian_Img_Flavor'",
	[culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM] = "",
}

function CrafterCulinarianElementItemView:OnElementTypeChanged(ElementType)
	if ElementType == nil then
		return
	end

	local Animation
	local VM = self.VM
	local ElementItemViewType = VM.ElementItemViewType
	local CrafterCulinarianMainPanelView = UIViewMgr:FindVisibleView(_G.UIViewID.CrafterCulinarianMainPanel)
	local CachedOriginElements = {}
	local bIsTriggerOrigin = false
	if CrafterCulinarianMainPanelView then
		CachedOriginElements = CrafterCulinarianMainPanelView.CachedOriginElements
		bIsTriggerOrigin = CrafterCulinarianMainPanelView.CrafterCulinarianVM.bIsPanelSourceVisible
	end

	if ElementItemViewType == EElementItemViewType.AfflatusItem and
	   (CachedOriginElements[ElementType] or ElementType == culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM) and
	   bIsTriggerOrigin then
		Animation = ElementLightColorAnimMap[ElementType]
	else
		Animation = ElementColorAnimMap[ElementType]
	end

	-- 新手引导抛事件
	if ElementItemViewType == EElementItemViewType.AfflatusItem then
		if ElementType == culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM or
		   ElementType == culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY then
			local EventParams = _G.EventMgr:GetEventParams()
			EventParams.Type = TutorialDefine.TutorialConditionType.SpecialCookerStatus --新手引导触发类型
			_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
		end
	end

	if CrafterCulinarianMainPanelView then
		local CrafterCulinarianVM = CrafterCulinarianMainPanelView.CrafterCulinarianVM or {}
		local bIsMenphinaState = CrafterCulinarianVM.bIsMenphinaState

		if bIsMenphinaState and CrafterCulinarianVM.bHasAfflatusFirstly and
		   ElementType == culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY and
		   ElementItemViewType == EElementItemViewType.AfflatusItem then
			Animation = "Menphina"
		end
	end

	if self.CurrentAnimation == Animation then
		return
	end
	self.CurrentAnimation = Animation

	VM.ImgColorIconPath = ElementIconPathMap[ElementType] or ""
	if Animation == "Menphina" then
		local UE = _G.UE
		local CallbackProxy = UE.UWidgetAnimationPlayCallbackProxy.CreatePlayAnimationProxyObject(
			nil, self, self.AnimLightColor6, 0, 1, UE.EUMGSequencePlayMode.PingPong)
		local Ref = UnLua.Ref(CallbackProxy)
		CallbackProxy.Finished:Add(self, function()
			UnLua.Unref(CallbackProxy)
			Ref = nil
			self:PlayAnimation(self.AnimEmpty)
		end)
	else
		self:PlayAnimation(self[Animation])
	end
end

function CrafterCulinarianElementItemView:OnVisibleChanged(bIsVisible, bLastVisible)
	UIUtil.SetIsVisible(self.PanelElement, bIsVisible, false, true)

	if self.VM.ElementItemViewType == EElementItemViewType.TableItem then
		if bIsVisible then
			self:PlayAnimation(self.AnimDownShow)
		elseif bLastVisible ~= nil then
			self:PlayAnimation(self.AnimBenchEliminate)
		end
	end
end

function CrafterCulinarianElementItemView:OnIsShineChanged(bShine)
	if bShine then
		self:PlayAnimation(self.AnimShineShow)
	else
		self:PlayAnimation(self.AnimShineHide)
	end
end

return CrafterCulinarianElementItemView