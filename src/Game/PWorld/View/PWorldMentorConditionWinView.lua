--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-29 15:13:40
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-29 16:58:26
FilePath: \Script\Game\PWorld\View\PWorldMentorConditionWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PWorldMentorConditionWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field FCanvasPanel_131 UFCanvasPanel
---@field Text02 UFTextBlock
---@field TextTitle UFTextBlock
---@field TreeViewCondition UFTreeView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMentorConditionWinView = LuaClass(UIView, true)

function PWorldMentorConditionWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.FCanvasPanel_131 = nil
	--self.Text02 = nil
	--self.TextTitle = nil
	--self.TreeViewCondition = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMentorConditionWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMentorConditionWinView:OnInit()
	self.AdpPWorldList = UIAdapterTreeView.CreateAdapter(self, self.TreeViewCondition)

	self.Binders = {
		{"DirectorPworldListVMs", UIBinderUpdateBindableList.New(self, self.AdpPWorldList)},
		{"bOnDirectorPannel", UIBinderValueChangedCallback.New(self, nil, function (_, NewValue)
			if not NewValue then
				self:Hide()
			end
		end)}
	}

	self.TextTitle:SetText(_G.LSTR(1320129))
	self.Text02:SetText(_G.LSTR(1320130))
end

function PWorldMentorConditionWinView:OnRegisterBinder()
	self:RegisterBinders(_G.PWorldEntDetailVM, self.Binders)
end

function PWorldMentorConditionWinView:OnMouseButtonDown(InGeometry, InTouchEvent)
	local MousePosition = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	if not UIUtil.IsUnderLocation(self.FCanvasPanel_131, MousePosition) then
		self:Hide()
		-- return _G.UE.UWidgetBlueprintLibrary.Handled()
	end

	return _G.UE.UWidgetBlueprintLibrary.Unhandled()
end

return PWorldMentorConditionWinView