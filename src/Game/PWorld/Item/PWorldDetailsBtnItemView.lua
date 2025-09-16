--[[
Author: jususchen jususchen@tencent.com
Date: 2025-03-12 15:25
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-05-07 16:30:12
FilePath: \Script\Game\PWorld\Item\PWorldDetailsBtnItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PWorldDetailsBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgIcon UFImage
---@field TextBtn UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldDetailsBtnItemView = LuaClass(UIView, true)

function PWorldDetailsBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgIcon = nil
	--self.TextBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldDetailsBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldDetailsBtnItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickBtnGo)
end

function PWorldDetailsBtnItemView:OnClickBtnGo()
	if self.Callback then
		if self.CallbackParams then
			self.Callback(table.unpack(self.CallbackParams))
		else
			self.Callback()
		end
	end
end

function PWorldDetailsBtnItemView:SetCallback(Callback, ...)
	self.Callback = Callback
	if select('#', ...) > 0 then
		self.CallbackParams = table.pack(...)
	else
		self.CallbackParams = nil
	end
end

function PWorldDetailsBtnItemView:SetIcon(Icon)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Icon)
end

function PWorldDetailsBtnItemView:SetText(Text)
	self.TextBtn:SetText(Text)
end

function PWorldDetailsBtnItemView:OnDestroy()
	self.Callback = nil
	self.CallbackParams = nil
end

return PWorldDetailsBtnItemView