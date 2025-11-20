---
--- Author: Administrator
--- DateTime: 2024-07-08 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local TouringBandDefine = require("Game/TouringBand/TouringBandDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class TouringBandTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconFansLogo UFImage
---@field ImgLock UFImage
---@field ImgMain UFImage
---@field PanelFocus UFCanvasPanel
---@field RedDot CommonRedDot2View
---@field TextSequence UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandTabItemView = LuaClass(UIView, true)

function TouringBandTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconFansLogo = nil
	--self.ImgLock = nil
	--self.ImgMain = nil
	--self.PanelFocus = nil
	--self.RedDot = nil
	--self.TextSequence = nil
	--self.AnimClick = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandTabItemView:OnInit()
end

function TouringBandTabItemView:OnDestroy()

end

function TouringBandTabItemView:OnShow()
	if not self.VM then
		return
	end
	
	local RedDotName = TouringBandDefine.RED_DOT_NAME .. '/' .. tostring(self.VM.BandID)
	self.RedDot:SetRedDotNameByString(RedDotName)
end

function TouringBandTabItemView:OnHide()

end

function TouringBandTabItemView:OnRegisterUIEvent()

end

function TouringBandTabItemView:OnRegisterGameEvent()

end

function TouringBandTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	if nil == Data then
		return
	end

	local ViewModel = Data
	self.VM = ViewModel

	local Binders = {
		{ "UnLockAlbum", UIBinderSetBrushFromAssetPath.New(self, self.ImgMain) },
		{ "LockAlbum", UIBinderSetBrushFromAssetPath.New(self, self.ImgLock) },
		{ "IsUnLock", UIBinderSetIsVisible.New(self, self.ImgLock, true) },
		{ "IsUnLock", UIBinderSetIsVisible.New(self, self.ImgMain) },
		{ "IsFans", UIBinderSetIsVisible.New(self, self.IconFansLogo) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.PanelFocus) },
		{ "BandNumber", UIBinderSetText.New(self, self.TextSequence)},
	}
	self:RegisterBinders(ViewModel, Binders)
end

function TouringBandTabItemView:OnSelectChanged(Value)
	if self.VM ~= nil then
		self.VM:SetSelect(Value)
		if Value then
			self:DelRedDot()
			self:PlayAnimation(self.AnimClick)
			self:PlayAnimLoop(self.AnimLoop)
		else
			self:StopAnimLoop(self.AnimLoop)
		end
	end
end

function TouringBandTabItemView:DelRedDot()
	if self.VM == nil or self.VM.BandID == nil then
		return
	end

	_G.TouringBandMgr:RemoveBandRecord(self.VM.BandID, TouringBandDefine.RECORD_TYPE.UNLOCK)
	local RedDotName = _G.TouringBandMgr:GetRedDotName(self.VM.BandID)
	local IsSaveDel = _G.RedDotMgr:GetIsSaveDelRedDotByName(RedDotName)
	if not IsSaveDel then
		_G.RedDotMgr:DelRedDotByName(RedDotName)
	end
end

return TouringBandTabItemView