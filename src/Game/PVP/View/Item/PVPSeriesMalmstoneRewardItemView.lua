---
--- Author: Administrator
--- DateTime: 2024-11-18 11:06
--- Description:
---

local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

local UIViewMgr = _G.UIViewMgr
local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

---@class PVPSeriesMalmstoneRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBreakThrough CommBtnXSView
---@field ImgReachLevel UFImage
---@field ImgUnreachLevel UFImage
---@field PanelProbar UFCanvasPanel
---@field ProgressBar UProgressBar
---@field SlotItem PVPSeriesMalmstoneSlotItemView
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPSeriesMalmstoneRewardItemView = LuaClass(UIView, true)

function PVPSeriesMalmstoneRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBreakThrough = nil
	--self.ImgReachLevel = nil
	--self.ImgUnreachLevel = nil
	--self.PanelProbar = nil
	--self.ProgressBar = nil
	--self.SlotItem = nil
	--self.TextLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPSeriesMalmstoneRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBreakThrough)
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPSeriesMalmstoneRewardItemView:OnInit()
	self.Binders = {
		{ "IsBreakThroughLevel", UIBinderValueChangedCallback.New(self, nil, self.OnIsBreakThroughLevelChanged) },
		{ "IsBrokeThrough", UIBinderValueChangedCallback.New(self, nil, self.OnIsBrokeThroughChanged) },
		{ "IsReachLevel", UIBinderSetIsVisible.New(self, self.ImgReachLevel) },
		{ "IsReachLevel", UIBinderSetIsVisible.New(self, self.ImgUnreachLevel, true) },
		{ "Level", UIBinderSetText.New(self, self.TextLevel) },
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLevel) },
		{ "IsLevelMax", UIBinderSetIsVisible.New(self, self.PanelProbar, true) },
		{ "Percent", UIBinderSetPercent.New(self, self.ProgressBar) },
	}
end

function PVPSeriesMalmstoneRewardItemView:OnDestroy()

end

function PVPSeriesMalmstoneRewardItemView:OnShow()

end

function PVPSeriesMalmstoneRewardItemView:OnHide()

end

function PVPSeriesMalmstoneRewardItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBreakThrough, self.OnClickBtnBreakThrough)
end

function PVPSeriesMalmstoneRewardItemView:OnRegisterGameEvent()

end

function PVPSeriesMalmstoneRewardItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPSeriesMalmstoneRewardItemView:OnIsBreakThroughLevelChanged(NewValue, OldValue)
	local IsShowBtn = false
	if NewValue then
		local Params = self.Params
		if Params == nil then return end

		local ViewModel = Params.Data
		if ViewModel == nil then return end

		if ViewModel.IsBrokeThrough then
			IsShowBtn = true
		else
			local CurLevel = PVPInfoMgr:GetSeriesMalmstoneLevel()
			if CurLevel >= ViewModel.Level - 1 then -- 至少到达突破等级的前一级才展示按钮
				IsShowBtn = true
			end
		end
	end

	UIUtil.SetIsVisible(self.BtnBreakThrough, IsShowBtn, true)
end

function PVPSeriesMalmstoneRewardItemView:OnIsBrokeThroughChanged(NewValue, OldValue)
	if NewValue then
		self.BtnBreakThrough:SetIsDoneState(NewValue, LSTR(130045))
		self.BtnBreakThrough.Button:SetIsEnabled(true) -- 正常设置Done状态按钮enable会变为false，为了让按钮仍能点击手动改为true
	else
		self.BtnBreakThrough:SetText(LSTR(130041))
		self.BtnBreakThrough:SetIsRecommendState(true)
	end
end

function PVPSeriesMalmstoneRewardItemView:OnClickBtnBreakThrough()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	local OptionList = {}

	-- 系列赛经验选项
	local CurExp = PVPInfoMgr:GetCurSeriesMalmstoneExp()
	local MaxExpFactor = 1
	local MaxExpCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_STARROADSIGNS_MAXSAVEEXP)
	if MaxExpCfg then
		MaxExpFactor = MaxExpCfg.Value[1] / 10000
	end
	local DescText = CurExp >= MaxExpFactor * ViewModel.UpExp and LSTR(130053) or LSTR(130065)
	local ExpOption = {
		Title = string.format(LSTR(130052)),
		Desc = 	string.format(DescText, CurExp, ViewModel.UpExp),
	}
	table.insert(OptionList, ExpOption)

	-- 突破目标选项
	for Index, TargetData in pairs(ViewModel.BreakThroughTargetList) do
        local Option = {
			Title = string.format(LSTR(130055), Index),
			Desc = string.format(LSTR(130056), TargetData.Description, TargetData.TargetCurCount, TargetData.TargetMaxCount),
			IsDone = TargetData.IsTargetBrokeThrough,
			Callback = function()
				if TargetData.GameType ~= 0 then
					PWorldEntUtil.ShowPWorldEntView(TargetData.GameType)
				end
			end,
		}
		table.insert(OptionList, Option)
    end
	
	local ViewParams = {
		Title = string.format(LSTR(130008), ViewModel.Level),
		OptionList = OptionList
	}
	UIViewMgr:ShowView(UIViewID.PVPOptionListPanel, ViewParams)
end

function PVPSeriesMalmstoneRewardItemView:OnSelectChanged(IsSelected)
	self.SlotItem:OnSelectChanged(IsSelected)
end

return PVPSeriesMalmstoneRewardItemView