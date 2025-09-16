---
--- Author: Administrator
--- DateTime: 2024-09-23 19:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class CommonSubNumAndTextRedDotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPlusYellow UFImage
---@field PanelRedDot UFCanvasPanel
---@field PanelYellowL UFCanvasPanel
---@field TextFull_1 UFTextBlock
---@field TextNumYellow UFTextBlock
---@field RedDotID int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonSubNumAndTextRedDotView = LuaClass(UIView, true)

function CommonSubNumAndTextRedDotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPlusYellow = nil
	--self.PanelRedDot = nil
	--self.PanelYellowL = nil
	--self.TextFull_1 = nil
	--self.TextNumYellow = nil
	--self.RedDotID = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonSubNumAndTextRedDotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonSubNumAndTextRedDotView:OnInit()
	-- if self.Binders == nil then
	-- 	self.Binders = {
	-- 		{ "IsVisible", UIBinderSetIsVisible.New(self, self.PanelRedDot)},
	-- 		{ "Text", UIBinderSetText.New(self, self.TextFull_1)},
	-- 		{ "Num", UIBinderSetText.New(self,self.TextNumYellow)},
	-- 		{ "IsShowMax", UIBinderSetIsVisible.New(self,self.ImgPlusYellow)},
	-- 		{ "RedDotStyle", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotStyleChange) },
	-- 	}
	-- end
	-- LSTR string:满
	self.TextFull_1:SetText(LSTR(1220002))
end

function CommonSubNumAndTextRedDotView:OnRedDotStyleChange(InRedDotStyle)
	if InRedDotStyle == RedDotDefine.RedDotStyle.NumStyle then
		UIUtil.SetIsVisible(self.TextNumYellow, true)
		UIUtil.SetIsVisible(self.TextFull_1, false)
	elseif InRedDotStyle == RedDotDefine.RedDotStyle.TextStyle then
		UIUtil.SetIsVisible(self.TextNumYellow, false)
		UIUtil.SetIsVisible(self.TextFull_1, true)
	end
end

function CommonSubNumAndTextRedDotView:OnDestroy()

end

function CommonSubNumAndTextRedDotView:OnShow()
	
end

function CommonSubNumAndTextRedDotView:OnHide()

end

function CommonSubNumAndTextRedDotView:OnRegisterUIEvent()

end

function CommonSubNumAndTextRedDotView:OnRegisterGameEvent()

end

function CommonSubNumAndTextRedDotView:OnRegisterBinder()
	-- if self.Params and self.Params.Data and self.Params.Data.VM then
	-- 	self:RegisterBinders(self.Params.Data.VM, self.Binders)
	-- end
end

----OnRegisterBinder获取到的Params不是CreateView时传递的，在这里做UI整体更新处理
---@param VM RedDotItemVM
function CommonSubNumAndTextRedDotView:UIUpdataShowByVM(VM)
	if VM == nil then
		return
	end
	if VM.Text then
		self.TextFull_1:SetText(VM.Text)
	end
	if VM.Num then
		self.TextNumYellow:SetText(VM.Num)
	end
	if VM.RedDotStyle then
		if VM.RedDotStyle == RedDotDefine.RedDotStyle.NumStyle then
			UIUtil.SetIsVisible(self.TextNumYellow, true)
			UIUtil.SetIsVisible(self.TextFull_1, false)
		elseif VM.RedDotStyle == RedDotDefine.RedDotStyle.TextStyle then
			UIUtil.SetIsVisible(self.TextNumYellow, false)
			UIUtil.SetIsVisible(self.TextFull_1, true)
		end
	end
	UIUtil.SetIsVisible(self.ImgPlusYellow, VM.IsShowMax)
end

function CommonSubNumAndTextRedDotView:OnTextChanged(Text)
	if Text then
		self.TextFull_1:SetText(Text)
	end
end

function CommonSubNumAndTextRedDotView:OnNumChanged(Num)
	if Num then
		self.TextNumYellow:SetText(Num)
	end
end

function CommonSubNumAndTextRedDotView:OnIsShowMaxChanged(IsShowMax)
	UIUtil.SetIsVisible(self.ImgPlusYellow, IsShowMax)
end

return CommonSubNumAndTextRedDotView