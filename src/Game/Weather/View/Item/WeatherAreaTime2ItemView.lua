---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class NewWeatherAreaTime2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EmptyState NewWeatherEmptyStateItemView
---@field TableViewList UTableView
---@field TextRegionCurrent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherAreaTime2ItemView = LuaClass(UIView, true)

function NewWeatherAreaTime2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EmptyState = nil
	--self.TableViewList = nil
	--self.TextRegionCurrent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherAreaTime2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EmptyState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherAreaTime2ItemView:OnInit()
	self.AdpTableViewTime = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil)
	self.Binder = 
	{
		{ "IsShowTime", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChgShowTime) },
		{ "Name", 					UIBinderSetText.New(self, self.TextRegionCurrent) },
		{ "Times",    				UIBinderUpdateBindableList.New(self, self.AdpTableViewTime) },
	}

	self.WeatherBinder = 
	{
		{ "ShowAreaVMEx", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindShowAreaVMEx) },
	}
end

function NewWeatherAreaTime2ItemView:OnValueChgShowTime(Value)
	if self.IsBanner then
		return
	end

	local Alpha = Value and 1 or 0
	self.ContentPanel:SetRenderOpacity(Alpha)
end

function NewWeatherAreaTime2ItemView:OnDestroy()

end

function NewWeatherAreaTime2ItemView:OnShow()
	if self.IsBanner then
		return
	end

	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	-- _G.FLOG_INFO(string.format('[Weather][NewWeatherAreaTime2ItemView][OnShow] AreaName = %s',tostring(self.VM.Name)))

	_G.WeatherVM:TryUpdTopItem(self.VM.AreaID, true, false)
end

function NewWeatherAreaTime2ItemView:OnHide()
	if self.IsBanner then
		return
	end

    if nil == self.VM then
        return
    end

	-- _G.FLOG_INFO(string.format('[Weather][NewWeatherAreaTime2ItemView][OnHide] AreaName = %s',tostring(self.VM.Name)))

	_G.WeatherVM:TryUpdTopItem(self.VM.AreaID, false, false)
end

function NewWeatherAreaTime2ItemView:OnRegisterUIEvent()

end

function NewWeatherAreaTime2ItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.WeatherMainUIExp, self.OnEveExp)
end

function NewWeatherAreaTime2ItemView:OnRegisterBinder()
	if not self.IsBanner then
		local Params = self.Params
		if nil == Params then
			return
		end

		self.VM = self.Params.Data
		if nil == self.VM then
			return
		end

		self.ItemVMBindID = self:RegisterBinders(self.VM, 				self.Binder)
	else
		self:RegisterBinders(_G.WeatherVM, 				self.WeatherBinder)
	end
end

function NewWeatherAreaTime2ItemView:OnEveExp(IsExp)
	if IsExp then
		self:PlayAnimation(self.AnimUnfold)
	else
		self:PlayAnimation(self.AnimFold)
	end
end

function NewWeatherAreaTime2ItemView:OnBindShowAreaVMEx(New, Old)
	if New then
		self:SetVM(New)
	end
end

function NewWeatherAreaTime2ItemView:SetVM(VM)
	if not VM then 
		return
	end

	if self.VM then
		self:UnRegisterBinders(self.VM, self.Binder)
	end

	self.VM = VM

	self:RegisterBinders(self.VM, 				self.Binder)
end

function NewWeatherAreaTime2ItemView:SetIsBanner(V)
	self.IsBanner = V
end


return NewWeatherAreaTime2ItemView