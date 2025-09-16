---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class NewWeatherBallIArrowLItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDown NewWeatherDropDownItemView
---@field ImgLine UFImage
---@field TableViewList UTableView
---@field TextRegion UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherBallIArrowLItemView = LuaClass(UIView, true)

function NewWeatherBallIArrowLItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDown = nil
	--self.ImgLine = nil
	--self.TableViewList = nil
	--self.TextRegion = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherBallIArrowLItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDown)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherBallIArrowLItemView:OnInit()
	
	self.AdpTableViewBall = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil)
	self.Binder = 
	{
		{ "BallList",    	UIBinderUpdateBindableList.New(self, self.AdpTableViewBall) },
		{ "Name",    		UIBinderSetText.New(self, self.TextRegion) },
		{ "IsExp", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindIsExp) },
		{ "IsExp", 			UIBinderSetIsChecked.New(self, self.DropDown.DropDownPanel) },
	}
end

function NewWeatherBallIArrowLItemView:OnDestroy()

end


function NewWeatherBallIArrowLItemView:OnShow()
	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	if self.VM.IsLastOne then
		local AreaID = self.VM.ParentAreaVM.AreaID
		-- _G.FLOG_INFO(string.format('[Weather][NewWeatherBallIArrowLItemView][OnShow]  MapName = %s, AreaName = %s',
		-- 	tostring(self.VM.Name),
		-- 	tostring(self.VM.ParentAreaVM.Name)
		-- ))
		_G.WeatherVM:TryUpdTopItem(AreaID, true, true)
	end

	self:UpdStat()
end

function NewWeatherBallIArrowLItemView:UpdStat()
	if _G.WeatherVM.IsShowExp then
		self:PlayAnimToEnd(self.AnimUnfold)
	else
		self:PlayAnimToEnd(self.AnimFold)
	end

	if self.VM then
		local IsExp = self.VM.IsExp

		local GloExpMapID = _G.WeatherVM.ExpMapID
		if GloExpMapID then
			IsExp = GloExpMapID == self.VM.MapID
		end
		
		-- print(tostring(self.VM.Name) .. " Item UpdStat Exp " .. tostring(IsExp))
		local DesireSizeY = IsExp and 413 or 112
		local DesireEntryHeight = IsExp and 102 or 82

		self.TableViewList.EntryHeight = DesireEntryHeight
		local Size = UIUtil.CanvasSlotGetSize(self.TableViewList)
		Size.Y = DesireSizeY
		UIUtil.CanvasSlotSetSize(self.TableViewList, Size)

		if IsExp then
			self:PlayAnimToEnd(self.AnimDropDownOpen)
			self.DropDown:PlayAnimToEnd(self.DropDown.AnimDropDownOpen)
			self:SetIsExp(true)
		else
			self:SetIsExp(false)
			self:PlayAnimToEnd(self.AnimDropDownClose)
			self.DropDown:PlayAnimToEnd(self.DropDown.AnimDropDownClose)
		end

		-- local EH = self.TableViewList.EntryHeight
		-- local SizeY = UIUtil.CanvasSlotGetSize(self.TableViewList).Y

		-- _G.FLOG_INFO(string.format('[Weather][NewWeatherBallIArrowLItemView][UpdStat] EntryHeight = %s, SizeY = %s',
		-- 	tostring(EH),
		-- 	tostring(SizeY)
		-- ))
	end
end

function NewWeatherBallIArrowLItemView:OnHide()
	if nil == self.VM then
        return
    end

	if self.VM.IsLastOne then
		local AreaID = self.VM.ParentAreaVM.AreaID
		-- _G.FLOG_INFO(string.format('[Weather][NewWeatherBallIArrowLItemView][OnHide]  MapName = %s, AreaName = %s',
		-- 	tostring(self.VM.Name),
		-- 	tostring(self.VM.ParentAreaVM.Name)
		-- ))
		_G.WeatherVM:TryUpdTopItem(AreaID, false, true)
	end

	self:EndAnimEveTimer()
end

function NewWeatherBallIArrowLItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.DropDown.DropDownPanel, self.OnTogExp)
end

function NewWeatherBallIArrowLItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.WeatherMainUIExp, 			self.OnEveExp)
	self:RegisterGameEvent(_G.EventID.WeatherMainUIDSeltIdxChg, 	self.OnEveRegionSeltChg)
	self:RegisterGameEvent(_G.EventID.WeatherMainUIExpMapChg, 		self.OnEveDropDownMapID)
end

function NewWeatherBallIArrowLItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	self:RegisterBinders(self.VM, 				self.Binder)
end

-------------------------------------------------------------------------------------------------------
---@see UIEveHandle

function NewWeatherBallIArrowLItemView:OnTogExp(Tog, Stat)
	self.IsChecked = UIUtil.IsToggleButtonChecked(Stat)

	if self.IsChecked then
		self:PlayAnimation(self.AnimDropDownOpen)
		self.DropDown:PlayAnimation(self.DropDown.AnimDropDownOpen)
		self:SetIsExp(true)
	else
		self:PlayAnimation(self.AnimDropDownClose)
		self.DropDown:PlayAnimation(self.DropDown.AnimDropDownClose)
		self:RegisterTimer(self.OnTimerExp, 0.32, 0)
	end

	self:StartAnimEveTimer()
end

function NewWeatherBallIArrowLItemView:StartAnimEveTimer()
	self:EndAnimEveTimer()

	self.AnimEveTimerHdl = self:RegisterTimer(function ()
		_G.EventMgr:SendEvent(_G.EventID.WeatherArrowBallAnimFinished)
	end, 0.1, 0.1, 2)
end

function NewWeatherBallIArrowLItemView:EndAnimEveTimer()
	if self.AnimEveTimerHdl then
		self:UnRegisterTimer(self.AnimEveTimerHdl)
		self.AnimEveTimerHdl = nil
	end
end

function NewWeatherBallIArrowLItemView:OnTimerExp()
	self:SetIsExp(false)
end

function NewWeatherBallIArrowLItemView:SetIsExp(V)
	self.VM:SetIsExp(V)
	if V then
		_G.WeatherVM.ExpMapID = self.VM.MapID
		_G.EventMgr:SendEvent(_G.EventID.WeatherMainUIExpMapChg, self.VM.MapID)
	end
end

function NewWeatherBallIArrowLItemView:OnEveExp(IsExp)
	if IsExp then
		self:PlayAnimation(self.AnimUnfold)
	else
		self:SetIsExp(false)
		self:ResetExpStat()
		self:PlayAnimation(self.AnimFold)
	end
end

function NewWeatherBallIArrowLItemView:OnEveRegionSeltChg(Idx)
	self:ResetExpStat()
end

function NewWeatherBallIArrowLItemView:OnEveDropDownMapID(DropDownMapID)
	if self.VM then
		local IsEqual = DropDownMapID == self.VM.MapID
		if not IsEqual and (self.IsChecked) then
			self:PlayAnimation(self.AnimDropDownClose)
			self.DropDown:PlayAnimation(self.DropDown.AnimDropDownClose)
			self:RegisterTimer(self.OnTimerExp, 0.32, 0)
			self.IsChecked = false
		end
	end
end

-------------------------------------------------------------------------------------------------------
---@see BinderHandle

function NewWeatherBallIArrowLItemView:OnBindIsExp(IsExp)
	if IsExp then
	-- 	self.DropDown:PlayAnimation(self.DropDown.AnimDropDownClose)
	-- else
	end
end

-------------------------------------------------------------------------------------------------------
---@region Logic

function NewWeatherBallIArrowLItemView:ResetExpStat()
	self.DropDown:PlayAnimation(self.DropDown.AnimDropDownClose, 0.3)
	self:PlayAnimation(self.AnimDropDownClose, 0.3)
	self.IsChecked = false
end

return NewWeatherBallIArrowLItemView