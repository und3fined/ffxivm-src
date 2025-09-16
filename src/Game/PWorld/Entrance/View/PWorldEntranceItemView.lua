--[[
Author: v_hggzhang
Date: 2023-04-19 14:38
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-30 19:25:05
FilePath: \Script\Game\PWorld\Entrance\View\PWorldEntranceItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE 
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class PWorldEntranceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgFrame UFImage
---@field ImgIcon UFImage
---@field ImgLock UFImage
---@field ImgLock_1 UFImage
---@field ImgMask UFImage
---@field ImgPic UFImage
---@field PanelLock UFCanvasPanel
---@field PanelStatus UFCanvasPanel
---@field StatusImage UFImage
---@field StatusText UFTextBlock
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMatchingIn UWidgetAnimation
---@field AnimMatchingLoop UWidgetAnimation
---@field AnimMatchingOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldEntranceItemView = LuaClass(UIView, true)

function PWorldEntranceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgFrame = nil
	--self.ImgIcon = nil
	--self.ImgLock = nil
	--self.ImgLock_1 = nil
	--self.ImgMask = nil
	--self.ImgPic = nil
	--self.PanelLock = nil
	--self.PanelStatus = nil
	--self.StatusImage = nil
	--self.StatusText = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--self.AnimMatchingIn = nil
	--self.AnimMatchingLoop = nil
	--self.AnimMatchingOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldEntranceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldEntranceItemView:OnInit()
	self.Binders = {
		{ "TypeName",    	UIBinderSetText.New(self, self.TextName) },
		{ "UnlockBG",    		UIBinderSetBrushFromAssetPath.New(self, self.ImgPic) },
		{ "TypeIcon",    	UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "bShowStatus",    	UIBinderSetIsVisible.New(self, self.PanelStatus) },
		{ "IsUnlock",    	UIBinderSetIsVisible.New(self, self.PanelLock, true, true) },
		{ "IsUnlock",    	UIBinderSetIsVisible.New(self, self.ImgPic) },
		{ "LockBG",    		UIBinderSetBrushFromAssetPath.New(self, self.ImgMask) },
		{ "FrameImage",		UIBinderSetBrushFromAssetPath.New(self, self.ImgFrame)},
		{ "StatusImage",    UIBinderSetBrushFromAssetPath.New(self, self.StatusImage)},
		{ "StatusText",    UIBinderSetText.New(self, self.StatusText)},
		{ "IsMatching", UIBinderValueChangedCallback.New(self, nil, function (_, NewValue, OldValue)
			if NewValue then
				self:PlayAnimation(self.AnimMatchingIn)
			else
				self:PlayAnimation(self.AnimMatchingOut)
			end
		end)},
	}
end

function PWorldEntranceItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function PWorldEntranceItemView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self.VM = self.Params.Data
		self:RegisterBinders(self.VM, self.Binders)
	end
end

local LockTips <const> = {
	[1] = 146079,
	[2] = 146080,
	[3] = 146081,
	[4] = 146082,
	[9] = 338037,	-- 水晶冲突练习赛，理论上水晶冲突只用到这个，下面两个是为了保险一起加的
	[10] = 338037,	-- 水晶冲突段位赛
	[11] = 338037,	-- 水晶冲突自定赛
}

function PWorldEntranceItemView:OnClickButtonItem()
	if self.VM and not self.VM.IsUnlock then
		_G.MsgTipsUtil.ShowTipsByID(self.VM.TypeID and LockTips[self.VM.TypeID] or nil)
		return
	end

    local Adapter = self.Params and self.Params.Adapter
	if self.VM and self.VM.IsUnlock and Adapter then
		Adapter:SetSelectedIndex(self.Params.Index)
	end
end

return PWorldEntranceItemView