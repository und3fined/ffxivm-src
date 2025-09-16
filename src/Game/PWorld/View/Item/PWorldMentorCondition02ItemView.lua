--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-29 15:31:24
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-29 16:37:22
FilePath: \Script\Game\PWorld\Item\PWorldMentorCondition02ItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PWorldMentorCondition02ItemView : UIView
---@field VM PWorldDirectorListItemVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgArrow UFImage
---@field ImgBanner UFImage
---@field ImgStateIcon UFImage
---@field ImgStateIcon02 UFImage
---@field ImgWarning UFImage
---@field PanelLock UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field TextName02 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMentorCondition02ItemView = LuaClass(UIView, true)

function PWorldMentorCondition02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgArrow = nil
	--self.ImgBanner = nil
	--self.ImgStateIcon = nil
	--self.ImgStateIcon02 = nil
	--self.ImgWarning = nil
	--self.PanelLock = nil
	--self.PanelNormal = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextName02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMentorCondition02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMentorCondition02ItemView:OnInit()
	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgStateIcon)},
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgStateIcon02)},
		{"BannerImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
		{"Name", UIBinderSetText.New(self, self.TextName)},
		{"bPreConditonFinished", UIBinderSetIsVisible.New(self, self.PanelNormal, false, true)},
		{"bPreConditonFinished", UIBinderSetIsVisible.New(self, self.PanelLock, true)},
		{"bPass", UIBinderSetIsVisible.New(self, self.ImgWarning, true)},
		{"bPass", UIBinderSetIsVisible.New(self, self.ImgArrow)},
		{"bPreConditonFinished", UIBinderSetIsVisible.New(self, self.BtnClick, false, true)},
		{"Level", UIBinderSetText.New(self, self.TextLevel)},
	}

	self.TextName02:SetText(_G.LSTR(1320135))
end

function PWorldMentorCondition02ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, function ()
		if self.VM and self.VM.PWorldID and self.VM.EntType then
			_G.UIViewMgr:HideView(_G.UIViewID.PWorldDirectorListPannel)
			_G.UIViewMgr:HideView(_G.UIViewID.PWorldEntranceSelectPanel)
			require("Game/PWorld/Entrance/PWorldEntUtil").ShowPWorldEntView(self.VM.EntType, self.VM.PWorldID)
		end
	end)
end

function PWorldMentorCondition02ItemView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self.VM = self.Params.Data
		self:RegisterBinders(self.VM, self.Binders)
	end
end

return PWorldMentorCondition02ItemView