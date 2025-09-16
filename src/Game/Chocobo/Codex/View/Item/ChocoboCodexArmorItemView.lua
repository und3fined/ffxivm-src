---
--- Author: Administrator
--- DateTime: 2023-12-25 14:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local RichTextUtil = require("Utils/RichTextUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
--local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")

---@class ChocoboCodexArmorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgMask UFImage
---@field ImgSelect UFImage
---@field ImgShow UFImage
---@field PanelShow UFCanvasPanel
---@field PanelShowSelect UFCanvasPanel
---@field TableViewPart UTableView
---@field TextArmorName URichTextBox
---@field TextOwnNum URichTextBox
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboCodexArmorItemView = LuaClass(UIView, true)

function ChocoboCodexArmorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgMask = nil
	--self.ImgSelect = nil
	--self.ImgShow = nil
	--self.PanelShow = nil
	--self.PanelShowSelect = nil
	--self.TableViewPart = nil
	--self.TextArmorName = nil
	--self.TextOwnNum = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorItemView:OnInit()
	self.ArmorPartTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewPart)
end

function ChocoboCodexArmorItemView:OnDestroy()

end

function ChocoboCodexArmorItemView:OnShow()

end

function ChocoboCodexArmorItemView:OnHide()

end

function ChocoboCodexArmorItemView:OnRegisterUIEvent()
	
end

function ChocoboCodexArmorItemView:OnRegisterGameEvent()

end

function ChocoboCodexArmorItemView:OnRegisterBinder()
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.Binders = {
		{"ArmorName", UIBinderSetText.New(self, self.TextArmorName)}, 
		{"TextOwnNum", UIBinderSetText.New(self, self.TextOwnNum)}, 
		{"ImgShow", UIBinderSetImageBrush.New(self, self.ImgShow)},
        {"IsMask", UIBinderSetIsVisible.New(self, self.ImgMask)},
		--{"ItemColorAndOpacity",UIBinderSetColorAndOpacity.New(self, self.ImgShow)},
		{"ImgShowVisible", UIBinderSetIsVisible.New(self, self.PanelShow)},
		{"ImgSelectVisible", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{"ArmorPartList", UIBinderUpdateBindableList.New(self, self.ArmorPartTableView)},
        {"PanelShowSelectVisible", UIBinderSetIsVisible.New(self, self.PanelShowSelect)},
	}

	self:RegisterBinders(ViewModel, self.Binders)
end

function ChocoboCodexArmorItemView:OnSelectChanged(Value)
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end
	if string.len(ViewModel.ArmorName) == 0 then 
		ViewModel.ImgSelectVisible = false
		return
	 end 

	ViewModel.ImgSelectVisible = Value
    ViewModel.PanelShowSelectVisible = Value
	if Value then 
		self:PlayAnimation(self.AnimSelect)
	end
end

return ChocoboCodexArmorItemView