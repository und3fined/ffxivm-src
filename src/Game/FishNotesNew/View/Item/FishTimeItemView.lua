--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 15:52:26
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-17 16:31:05
FilePath: \Client\Source\Script\Game\FishNotesNew\View\Item\FishTimeItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FishTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgServerBg UFImage
---@field Server UFCanvasPanel
---@field TextServer UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime2 UFTextBlock
---@field TextWeather UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTimeItemView = LuaClass(UIView, true)

function FishTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgServerBg = nil
	--self.Server = nil
	--self.TextServer = nil
	--self.TextTime = nil
	--self.TextTime2 = nil
	--self.TextWeather = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTimeItemView:OnInit()
	self.TextServer:SetText(_G.LSTR(1500015))--"本"
	self.TextWeather:SetText(_G.LSTR(180071))--"天气变化"
	self.TextTime2:SetText(_G.LSTR(180072))--"持续时间"
	self.Binders = {
		{ "StartDate", UIBinderSetText.New(self, self.TextTime) },
	}
end

function FishTimeItemView:OnDestroy()

end

function FishTimeItemView:OnShow()

end

function FishTimeItemView:OnHide()

end

function FishTimeItemView:OnRegisterUIEvent()

end

function FishTimeItemView:OnRegisterGameEvent()

end

function FishTimeItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return FishTimeItemView