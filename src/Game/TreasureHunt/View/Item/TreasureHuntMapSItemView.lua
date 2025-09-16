---
--- Author: Administrator
--- DateTime: 2023-11-15 14:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapUtil = require("Game/Map/MapUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local MapDefine = require("Game/Map/MapDefine")
local MapContentType = MapDefine.MapContentType

---@class TreasureHuntMapSItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnGOMap UFButton
---@field BtnSelect UFButton
---@field ImgManySelect UFImage
---@field ImgMapAdvanced UFImage
---@field ImgMapOrdinary UFImage
---@field ImgUninterpretedAdvanced UFImage
---@field ImgUninterpretedOrdinary UFImage
---@field MaskBoxMapAdvanced UMaskBox
---@field MaskBoxMapOrdinary UMaskBox
---@field P_DX_TreasureHunt UUIParticleEmitter
---@field PanelAdvancedFocus UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field PanelFocus UFCanvasPanel
---@field PanelGPS UFCanvasPanel
---@field PanelInterpretedAdvanced UFCanvasPanel
---@field PanelInterpretedOrdinary UFCanvasPanel
---@field PanelMapAdvanced UFCanvasPanel
---@field PanelMapOrdinary UFCanvasPanel
---@field PanelMarkerAdvanced UFCanvasPanel
---@field PanelMarkerOrdinary UFCanvasPanel
---@field PanelMiniMapAdvanced UFCanvasPanel
---@field PanelMiniMapOrdinary UFCanvasPanel
---@field PanelNearTips1 UFCanvasPanel
---@field PanelNotOwned UFCanvasPanel
---@field PanelNotOwnedFocus UFCanvasPanel
---@field PanelOrdinaryFocus UFCanvasPanel
---@field PanelParticle UFCanvasPanel
---@field PanelSensor UFCanvasPanel
---@field PanelUninterpreted UFCanvasPanel
---@field PanelUserName UFCanvasPanel
---@field RichTextBox1 URichTextBox
---@field TextPeople UFTextBlock
---@field TextPlaceName UFTextBlock
---@field TextUserName UFTextBlock
---@field AnimIn_1 UWidgetAnimation
---@field AnimIn_2 UWidgetAnimation
---@field AnimNear1_loop UWidgetAnimation
---@field AnimNear1_start UWidgetAnimation
---@field AnimNear2_loop UWidgetAnimation
---@field AnimNear3_loop UWidgetAnimation
---@field AnimNear4_loop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntMapSItemView = LuaClass(UIView, true)

function TreasureHuntMapSItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGOMap = nil
	--self.BtnSelect = nil
	--self.ImgManySelect = nil
	--self.ImgMapAdvanced = nil
	--self.ImgMapOrdinary = nil
	--self.ImgUninterpretedAdvanced = nil
	--self.ImgUninterpretedOrdinary = nil
	--self.MaskBoxMapAdvanced = nil
	--self.MaskBoxMapOrdinary = nil
	--self.P_DX_TreasureHunt = nil
	--self.PanelAdvancedFocus = nil
	--self.PanelContent = nil
	--self.PanelFocus = nil
	--self.PanelGPS = nil
	--self.PanelInterpretedAdvanced = nil
	--self.PanelInterpretedOrdinary = nil
	--self.PanelMapAdvanced = nil
	--self.PanelMapOrdinary = nil
	--self.PanelMarkerAdvanced = nil
	--self.PanelMarkerOrdinary = nil
	--self.PanelMiniMapAdvanced = nil
	--self.PanelMiniMapOrdinary = nil
	--self.PanelNearTips1 = nil
	--self.PanelNotOwned = nil
	--self.PanelNotOwnedFocus = nil
	--self.PanelOrdinaryFocus = nil
	--self.PanelParticle = nil
	--self.PanelSensor = nil
	--self.PanelUninterpreted = nil
	--self.PanelUserName = nil
	--self.RichTextBox1 = nil
	--self.TextPeople = nil
	--self.TextPlaceName = nil
	--self.TextUserName = nil
	--self.AnimIn_1 = nil
	--self.AnimIn_2 = nil
	--self.AnimNear1_loop = nil
	--self.AnimNear1_start = nil
	--self.AnimNear2_loop = nil
	--self.AnimNear3_loop = nil
	--self.AnimNear4_loop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntMapSItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntMapSItemView:OnInit()
	if (self.Binders == nil) then
		self.Binders = { 
			{"PanelOwnerNameVisible", UIBinderSetIsVisible.New(self, self.PanelUserName,false, true) },
			{"OwnerName", UIBinderSetText.New(self, self.TextUserName)},
			{"PanelSelected", UIBinderValueChangedCallback.New(self, nil, self.OnPanelSelectedChange)},

			{"PanelNotOwnedVisible", UIBinderSetIsVisible.New(self, self.PanelNotOwned,false, true) },
			{"PanelNotOwnedFocusVisible", UIBinderSetIsVisible.New(self, self.PanelNotOwnedFocus,false, true) },

			{"PanelUninterpretedVisible", UIBinderSetIsVisible.New(self, self.PanelUninterpreted,false, true) },
			{"ImgUninterpretedOrdinaryVisible", UIBinderSetIsVisible.New(self, self.ImgUninterpretedOrdinary,false, true) },
			{"ImgUninterpretedAdvancedVisible", UIBinderSetIsVisible.New(self, self.ImgUninterpretedAdvanced,false, true) },
			{"PanelFocusVisible", UIBinderSetIsVisible.New(self, self.PanelFocus,false, true) },

			{"PanelSingleVisible", UIBinderSetIsVisible.New(self, self.PanelInterpretedOrdinary,false, true) },
			{"MapPath1", UIBinderSetBrushFromAssetPath.New(self, self.ImgMapOrdinary, false, true, true) },
			{"SingleSelectVisible", UIBinderSetIsVisible.New(self, self.PanelOrdinaryFocus,false, true) },

			{"PanelManyVisible", UIBinderSetIsVisible.New(self, self.PanelInterpretedAdvanced,false, true) },
			{"MapPath2", UIBinderSetBrushFromAssetPath.New(self, self.ImgMapAdvanced, false, true, true) },
			{"ManySelectVisible", UIBinderSetIsVisible.New(self, self.PanelAdvancedFocus,false, true) },

			{"PanelGPSVisible", UIBinderSetIsVisible.New(self, self.PanelGPS,false, true) },
			{"BtnSelectVisible", UIBinderSetIsVisible.New(self, self.BtnSelect,false, true) },
			{"BtnGOMapVisible", UIBinderSetIsVisible.New(self, self.BtnGOMap,false, true) },
			{"BtnCloseVisible", UIBinderSetIsVisible.New(self, self.BtnClose,false, true) },
			{"PanelSensorVisible", UIBinderSetIsVisible.New(self, self.PanelSensor,false, true) },
			{"TextNear", UIBinderSetText.New(self, self.RichTextBox1)},

			{"PanelContentVisible", UIBinderSetIsVisible.New(self, self.PanelContent,false, true) },
			{"TextPeople", UIBinderSetText.New(self, self.TextPeople)}, 
			{"TextPlace", UIBinderSetText.New(self, self.TextPlaceName)},
			---------------------------------------------------------------
			{"PanelNearTips1Visible", UIBinderSetIsVisible.New(self, self.PanelNearTips1,false, true) },
			{"Anim1Start", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimNear1_start,true) },
			{"Anim1Loop", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimNear1_loop,true) },
			{"Anim2Loop", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimNear2_loop,true) },
			{"Anim3Loop", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimNear3_loop,true) },
			{"Anim4Loop", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimNear4_loop,true) },

			{ "TreasureBoxPos", UIBinderValueChangedCallback.New(self, nil, self.OnTreasureBoxPosChange) },

			{"MapOrdinaryPath", UIBinderSetBrushFromAssetPath.New(self, self.MapOrdinary, false, true, true) },
			{"MapAdvancedPath", UIBinderSetBrushFromAssetPath.New(self, self.MapAdvanced, false, true, true) },
		}
	end
end

function TreasureHuntMapSItemView:OnDestroy()

end

function TreasureHuntMapSItemView:OnShow()
	self:ShowMapContent()
end

function TreasureHuntMapSItemView:OnHide()
	if self:IsAnimationPlaying(self.AnimNear1_start) then
        self:StopAnimation(self.AnimNear1_start)
    end
	if self:IsAnimationPlaying(self.AnimNear1_loop) then
        self:StopAnimation(self.AnimNear1_loop)
    end
	if self:IsAnimationPlaying(self.AnimNear2_loop) then
        self:StopAnimation(self.AnimNear2_loop)
    end
	if self:IsAnimationPlaying(self.AnimNear3_loop) then
        self:StopAnimation(self.AnimNear3_loop)
    end
	if self:IsAnimationPlaying(self.AnimNear4_loop) then
        self:StopAnimation(self.AnimNear4_loop)
    end
end

function TreasureHuntMapSItemView:OnRegisterUIEvent()
end

function TreasureHuntMapSItemView:OnRegisterGameEvent()

end

function TreasureHuntMapSItemView:OnRegisterBinder()
    if self.ViewModel ~= nil and self.Binders ~= nil then 
        self:RegisterBinders(self.ViewModel, self.Binders)
    end
end

function TreasureHuntMapSItemView:ShowMapContent()
	if self.ViewModel == nil then return end

	local Pos = self.ViewModel:GetTreasureBoxPos()
	if Pos == nil then 
		return 
	end

	local X, Y = MapUtil.ConvertMapPos2UI(Pos.X, Pos.Y, 0, 0, 100, false)

	local Position =  _G.UE.FVector2D(X,Y)
	local selfMapImgPosition = _G.UE.FVector2D(0, 0)
	selfMapImgPosition.X = -Position.X
	selfMapImgPosition.Y = -Position.Y

	--[[
	if self.ViewModel:IsMulti() then
		self.MaskBoxMapAdvanced:RequestRender()
		UIUtil.CanvasSlotSetPosition(self.PanelMapAdvanced, selfMapImgPosition)
		UIUtil.CanvasSlotSetPosition(self.PanelMarkerAdvanced, selfMapImgPosition)
	else
		self.MaskBoxMapOrdinary:RequestRender()
		UIUtil.CanvasSlotSetPosition(self.PanelMapOrdinary, selfMapImgPosition)
		UIUtil.CanvasSlotSetPosition(self.PanelMarkerOrdinary, selfMapImgPosition)
	end
	--]]
end

function TreasureHuntMapSItemView:OnPanelSelectedChange(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelParticle, NewValue)
	-- 切换选中的地图时, 播放当前地图的UI特效, 清掉上个地图的UI特效
	if NewValue then
		self.P_DX_TreasureHunt:Play()
	else
		self.P_DX_TreasureHunt:Stop()
		self.P_DX_TreasureHunt:ResetParticle()
	end
end

function TreasureHuntMapSItemView:OnTreasureBoxPosChange()
	self:ShowMapContent()
end

function TreasureHuntMapSItemView:ShowMainPanel()
	self:PlayAnimation(self.AnimIn_1)
end

function TreasureHuntMapSItemView:ShowSkillPanel()
	self:PlayAnimation(self.AnimIn_2)
end

return TreasureHuntMapSItemView