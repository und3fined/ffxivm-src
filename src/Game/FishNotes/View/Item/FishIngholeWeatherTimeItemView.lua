--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2023-12-08 09:26:58
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-08-09 10:12:58
FilePath: \Client\Source\Script\Game\FishNotes\View\Item\FishIngholeWeatherTimeItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2023-03-29 12:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")


local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")

---@class FishIngholeWeatherTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewWeather UTableView
---@field TextTime UFTextBlock
---@field TextTimeTitle UFTextBlock
---@field TextUnit UFTextBlock
---@field TextWeather UFTextBlock
---@field TextWeatherTitle UFTextBlock
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeWeatherTimeItemView = LuaClass(UIView, true)

function FishIngholeWeatherTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewWeather = nil
	--self.TextTime = nil
	--self.TextTimeTitle = nil
	--self.TextUnit = nil
	--self.TextWeather = nil
	--self.TextWeatherTitle = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeWeatherTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeWeatherTimeItemView:OnInit()
	self.TableViewWeatherAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewWeather)
	self.Binders = {
        { "FishDetailConditionWeatherName", UIBinderSetText.New(self, self.TextWeather) },
		{ "FishDetailWeatherList", UIBinderUpdateBindableList.New(self, self.TableViewWeatherAdapter) },
	}
end

function FishIngholeWeatherTimeItemView:OnDestroy()

end

function FishIngholeWeatherTimeItemView:OnShow()
	self.TextWeatherTitle:SetText(_G.LSTR(180051))--天气
	self.TextTimeTitle:SetText(_G.LSTR(180052))--时间
end

function FishIngholeWeatherTimeItemView:OnHide()

end

function FishIngholeWeatherTimeItemView:OnRegisterUIEvent()

end

function FishIngholeWeatherTimeItemView:OnRegisterGameEvent()

end

function FishIngholeWeatherTimeItemView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

return FishIngholeWeatherTimeItemView