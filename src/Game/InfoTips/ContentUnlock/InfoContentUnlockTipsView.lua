---
--- Author: Administrator
--- DateTime: 2024-08-29 19:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local ObjectGCType = require("Define/ObjectGCType")

local SoundPath = "/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Unlock.Play_Zingle_Unlock"

---@class InfoContentUnlockTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconSubTitle UFImage
---@field ImgImportant UFImage
---@field ImgImportantMask1 UFImage
---@field PanelIconSubTitle USizeBox
---@field PanelImportant UFCanvasPanel
---@field PanelOrdinary UFCanvasPanel
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimInImportant UWidgetAnimation
---@field AnimInOrdinary UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoContentUnlockTipsView = LuaClass(UIView, true)

function InfoContentUnlockTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconSubTitle = nil
	--self.ImgImportant = nil
	--self.ImgImportantMask1 = nil
	--self.PanelIconSubTitle = nil
	--self.PanelImportant = nil
	--self.PanelOrdinary = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.AnimInImportant = nil
	--self.AnimInOrdinary = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoContentUnlockTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoContentUnlockTipsView:OnInit()

end

function InfoContentUnlockTipsView:OnDestroy()

end

function InfoContentUnlockTipsView:OnShow()
	if self.Params == nil then
		return
	end
	local Params = self.Params
	self:SetImgImportantMask1(Params)
	if string.isnilorempty(Params.SubTitleIcon)	then
		UIUtil.SetIsVisible(self.IconSubTitle, false)
	else
		UIUtil.SetIsVisible(self.IconSubTitle, true)
		UIUtil.ImageSetBrushFromAssetPath(self.IconSubTitle, Params.IconSubTitle)
	end
	
	AudioUtil.LoadAndPlayUISound(SoundPath)
	if not string.isnilorempty(Params.Icon)	then
		UIUtil.SetIsVisible(self.PanelImportant, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgImportant, Params.Icon)
		self:PlayAnimation(self.AnimInImportant)
	else
		UIUtil.SetIsVisible(self.PanelImportant, false)
		self:PlayAnimation(self.AnimInOrdinary)
	end
	self.TextTitle:SetText(Params.SysNotice)
	self.TextSubTitle:SetText(Params.SubSysNotice)
	--显示2.8s消失
	self:RegisterTimer(function()
		if Params == nil or Params.IsMentorTrigger then 
			self:Hide()
			return
		end
		_G.ModuleOpenMgr:OnAllMotionOver() 
		self:Hide()
	end, 2.8)
end

function InfoContentUnlockTipsView:OnHide()
	
end

function InfoContentUnlockTipsView:OnRegisterUIEvent()

end

function InfoContentUnlockTipsView:OnRegisterGameEvent()

end

function InfoContentUnlockTipsView:OnRegisterBinder()

end

function InfoContentUnlockTipsView:SetImgImportantMask1(Params)
	-- 默认使用传奇武器的
	local IconMask = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_AncientWeapons.T_DX_Mask_AncientWeapons'" 
	if Params.IsMentorTrigger then
		IconMask = Params.IconMask
	end
	local Object = _G.ObjectMgr:LoadObjectSync(IconMask, ObjectGCType.LRU)
	if Object == nil  then
		return
	end
	local DynamicMat = self.ImgImportantMask1:GetDynamicMaterial()
	if nil == DynamicMat then
		_G.FLOG_ERROR("InfoContentUnlockTipsView.ImgImportantMask1 Invalid DynamicMaterial.")
		return
	end

	DynamicMat:SetTextureParameterValue("Mask", Object)
	self.ImgImportantMask1:SetBrushFromMaterial(DynamicMat)
end



return InfoContentUnlockTipsView