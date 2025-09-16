---
--- Author: eddardchen
--- DateTime: 2021-03-25 16:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD

---@class GMSwitchView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GMSwitch UButton
---@field StateImage UImage
---@field StateText UTextBlock
---@field SwitchText UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMSwitchView = LuaClass(UIView, true)

function GMSwitchView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GMSwitch = nil
	--self.StateImage = nil
	--self.StateText = nil
	--self.SwitchText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMSwitchView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMSwitchView:OnInit()
	
end

function GMSwitchView:OnDestroy()

end

function GMSwitchView:OnShow()
	if nil ~= self.Params.DefaultValue and nil == _G.GMMgr:GetCacheValue(self.Params.ID) then
		_G.GMMgr:SetCacheValue(self.Params.ID, self.Params.DefaultValue)
	end
	if self.Params.Desc ~= nil then
		self.SwitchText:SetText(self.Params.Desc)
	end
	self.onText = "开"
	self.offText = "关"
	self:UpdateView()
end

function GMSwitchView:OnHide()

end

function GMSwitchView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GMSwitch, self.OnSwitchButtonClick)
end

function GMSwitchView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PWorldReady, self.OnWorldReady)
end

function GMSwitchView:OnRegisterTimer()
end

function GMSwitchView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	local Binders =
	{
		-- { "Desc", UIBinderSetText.New(self, self.Desc) },
		-- { "Minimum", UIBinderSetText.New(self, self.Minimum) },
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDValueChangedCallback) },

	}
	self:RegisterBinders(ViewModel, Binders)
end

function GMSwitchView:OnIDValueChangedCallback()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = self.Params.Data
	if nil == self.ViewModel then
		return
	end
	if nil ~= self.ViewModel.Params.DefaultValue and nil == _G.GMMgr:GetCacheValue(self.ViewModel.Params.ID) then
		_G.GMMgr:SetCacheValue(self.ViewModel.Params.ID, self.ViewModel.Params.DefaultValue)
	end
	self.SwitchText:SetText(self.ViewModel.Params.Desc)
	self.onText = "开"
	self.offText = "关"
	self:UpdateView()
end

function GMSwitchView:ReqGM(CmdList)
	if string.find(CmdList, "|") ~= nil then
        CmdList = string.split(CmdList, "|")
        for i = 1, #(CmdList) do
			self:ReqGM(CmdList[i])
        end
    else
        _G.GMMgr:ReqGM(CmdList)
    end
end

function GMSwitchView:OnSwitchButtonClick()
	self:ChangeSwitchButtonState(self.ViewModel.Params)

	if 0 == self.ViewModel.Params.IsServerCmd then
		-- 纯客户端
		local bHaveOnCmdList = self.ViewModel.Params.OnCmdList ~= nil and self.ViewModel.Params.OnCmdList ~= ""
		local bHaveCmd = self.ViewModel.Params.CmdList ~= nil and  self.ViewModel.Params.CmdList ~= ""
		if (not bHaveCmd and bHaveOnCmdList) then
			local Params = self.ViewModel.Params
			if 1 == _G.GMMgr:GetCacheValue(Params.ID, Params.RefreshChangeLevel) then
				-- 如果没有Cmd但是有OnCmd
				_G.GMMgr:ReqGM(self.ViewModel.Params.OnCmdList)
			else
				_G.GMMgr:ReqGM(self.ViewModel.Params.OffCmdList)
			end
		else
			local EventID = require("Define/EventID")
			_G.EventMgr:SendEvent(EventID.GMButtonClick, self.ViewModel.Params)
		end
		
		return
	end

	if 1 == _G.GMMgr:GetCacheValue(self.ViewModel.Params.ID, self.ViewModel.Params.RefreshChangeLevel) then
		self:ReqGM(self.ViewModel.Params.OnCmdList)
	else
		self:ReqGM(self.ViewModel.Params.OffCmdList)
	end
end

-- 服务器执行客户端GM时需要输入对应的params
function GMSwitchView:ChangeSwitchButtonState(params)
	local lastValue = _G.GMMgr:GetCacheValue(params.ID, params.RefreshChangeLevel)
	if nil == lastValue then
		_G.GMMgr:SetCacheValue(params.ID, 0)
		lastValue = 0
	end

	if type(lastValue) ~= "number" then
		FLOG_ERROR("lastValue Tyep error ")
		lastValue = 0
	end
	
	_G.GMMgr:SetCacheValue(params.ID, (lastValue + 1) % 2)
	self:UpdateView()
end

function GMSwitchView:UpdateView()
	local Params = self.ViewModel.Params
	if 1 == _G.GMMgr:GetCacheValue(Params.ID, Params.RefreshChangeLevel) then
		self.StateText:SetText("开")
		UIUtil.ImageSetColorAndOpacity(self.StateImage, 0.0, 0.5, 0.9, 1);
	else
		self.StateText:SetText("关")
		UIUtil.ImageSetColorAndOpacity(self.StateImage, 0.2, 0.2, 0.2, 1);
	end

	if self.Params.Desc ~= nil then
		self.SwitchText:SetText(self.Params.Desc)
	end
end

--function GMSwitchView:OnWorldChanged(MsgID, SubMsgID, MsgBody)
function GMSwitchView:OnWorldReady()
	--if MsgID == CS_CMD.CS_CMD_PWORLD and MsgBody.Cmd == CS_PWORLD_CMD.CS_PWORLD_CMD_READY  and 1 == self.ViewModel.Params.RefreshChangeLevel then
	if 1 == self.ViewModel.Params.RefreshChangeLevel then
		self.StateText:SetText("关")
		UIUtil.ImageSetColorAndOpacity(self.StateImage, 0.2, 0.2, 0.2, 1);
	end
end

return GMSwitchView