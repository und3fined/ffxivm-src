--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 17:15:07
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-20 15:00:45
FilePath: \Client\Source\Script\Game\FishNotesNew\View\Item\FishTime3ItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-07 20:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TipsUtil = require("Utils/TipsUtil")

---@class FishTime3ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrow UFImage
---@field TableViewWeather1 UTableView
---@field TableViewWeather2 UTableView
---@field TextWeather UFTextBlock
---@field TextWeatherText UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTime3ItemView = LuaClass(UIView, true)

function FishTime3ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrow = nil
	--self.TableViewWeather1 = nil
	--self.TableViewWeather2 = nil
	--self.TextWeather = nil
	--self.TextWeatherText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTime3ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTime3ItemView:OnInit()
	self.TextWeather:SetText(_G.LSTR(180102))--"天气要求"
	self.PreWeatherAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewWeather1, self.OnItemSelected)
	self.WeatherAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewWeather2, self.OnItemSelected)
	self.Binders = {
		{"FishPreWeatherList", UIBinderUpdateBindableList.New(self, self.PreWeatherAdapter)},
		{"FishWeatherList", UIBinderUpdateBindableList.New(self, self.WeatherAdapter)},
		{"bImgArrowVisible", UIBinderSetIsVisible.New(self, self.ImgArrow, false, true)},
		{"bImgArrowVisible", UIBinderSetIsVisible.New(self, self.TableViewWeather1, false, true)},
		{"FishDetailConditionWeatherName", UIBinderSetText.New(self, self.TextWeatherText)},
	}
end

function FishTime3ItemView:OnDestroy()

end

function FishTime3ItemView:OnShow()

end

function FishTime3ItemView:OnHide()

end

function FishTime3ItemView:OnRegisterUIEvent()

end

function FishTime3ItemView:OnRegisterGameEvent()

end

function FishTime3ItemView:OnRegisterBinder()
	self:RegisterBinders(_G.FishIngholeVM, self.Binders)
end

function FishTime3ItemView:OnItemSelected(ItemData, ItemView)
	TipsUtil.ShowInfoTips(ItemData.Name, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
end

return FishTime3ItemView