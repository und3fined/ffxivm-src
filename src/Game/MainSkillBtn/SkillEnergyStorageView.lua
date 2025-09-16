---
--- Author: chaooren
--- DateTime: 2022-03-07 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")

local ProgressLength = 378

local EnergyAnimOutType = {
	Faild = 1,
	Release = 2,
	ReleaseNotFull = 3,
}

---@class SkillEnergyStorageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Block1 UFImage
---@field Block2 UFImage
---@field Block3 UFImage
---@field BlockLightEffect UFCanvasPanel
---@field EFF_Highlight UFImage
---@field EnergyStorage UFCanvasPanel
---@field ProBarSetion1 UProgressBar
---@field ProBarSetion2 UProgressBar
---@field ProBarSetion3 UProgressBar
---@field ProBarSetion4 UProgressBar
---@field AnimBlockLight UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOutFaild UWidgetAnimation
---@field AnimOutRelease UWidgetAnimation
---@field AnimOutReleaseNotFull UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillEnergyStorageView = LuaClass(UIView, true)

function SkillEnergyStorageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Block1 = nil
	--self.Block2 = nil
	--self.Block3 = nil
	--self.BlockLightEffect = nil
	--self.EFF_Highlight = nil
	--self.EnergyStorage = nil
	--self.ProBarSetion1 = nil
	--self.ProBarSetion2 = nil
	--self.ProBarSetion3 = nil
	--self.ProBarSetion4 = nil
	--self.AnimBlockLight = nil
	--self.AnimIn = nil
	--self.AnimOutFaild = nil
	--self.AnimOutRelease = nil
	--self.AnimOutReleaseNotFull = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillEnergyStorageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillEnergyStorageView:OnInit()
	self.AnimOutResult = EnergyAnimOutType.Faild
	self.bFull = false

	self.BlockList = {
		[1] = self.Block1,
		[2] = self.Block2,
		[3] = self.Block3,
	}

	self.ProBarSetionList = {
		[1] = self.ProBarSetion1,
		[2] = self.ProBarSetion2,
		[3] = self.ProBarSetion3,
		[4] = self.ProBarSetion4,
	}

end

function SkillEnergyStorageView:OnDestroy()

end

function SkillEnergyStorageView:OnShow()
	local Params = self.Params

	if not Params or Params.LevelCount <= 0 then
		FLOG_WARNING("[SkillEnergyStorageView] Storage Data ERROR")
		return
	end
	local ShortenTimeCoefficient = Params.ShortenTimeCoefficient
	self.BeginTime = TimeUtil.GetLocalTimeMS()
	self.MaxTime = Params.LevelList[Params.LevelCount].MaxTime * ShortenTimeCoefficient - Params.WeakTime
	self.PercentList = {}
	self.BlockPositionList = {}
	for i = 1, 3 do
		local Block = self.BlockList[i]
		if i < Params.LevelCount then
			local Percent = (Params.LevelList[i].MaxTime * ShortenTimeCoefficient - Params.WeakTime) / self.MaxTime
			table.insert(self.PercentList, Percent)
			local Pos = _G.UE.FVector2D(Percent * ProgressLength, 0)
			table.insert(self.BlockPositionList, Pos)
			UIUtil.CanvasSlotSetPosition(Block, Pos)
			UIUtil.SetIsVisible(Block, true)
		else
			UIUtil.SetIsVisible(Block, false)
		end
	end
	rawset(self, "CurProbarIndex", 1)
	
	for i = 1, 4 do
		local Probar = self.ProBarSetionList[i]
		Probar:SetPercent(0)
	end
	UIUtil.CanvasSlotSetPosition(self.EFF_Highlight, _G.UE.FVector2D(0, 0))
	self:RegisterTimer(self.OnTimer, 0, 0.05, 0)
	self.Count = 0
end

function SkillEnergyStorageView:OnHide(Params)
	self.AnimOutResult = EnergyAnimOutType.Faild
	local Result = Params and Params.Result or false
	if Result then
		if self.bFull then
			self.AnimOutResult = EnergyAnimOutType.Release
		else
			self.AnimOutResult = EnergyAnimOutType.ReleaseNotFull
		end
	end
end

function SkillEnergyStorageView:OnRegisterUIEvent()

end

function SkillEnergyStorageView:OnRegisterGameEvent()

end

function SkillEnergyStorageView:OnRegisterBinder()

end


function SkillEnergyStorageView:OnTimer()
	local Time = TimeUtil.GetLocalTimeMS() - self.BeginTime
	local CurPercent = Time / self.MaxTime
	local Index = rawget(self, "CurProbarIndex")
	for i = #self.PercentList, 1, -1 do
		if self.PercentList[i] <= CurPercent then
			Index = i + 1
			break
		end
	end
	if Index ~= rawget(self, "CurProbarIndex") then
		rawset(self, "CurProbarIndex", Index)
		local Pos = self.BlockPositionList[Index - 1]
		UIUtil.CanvasSlotSetPosition(self.BlockLightEffect, Pos)
		self:PlayAnimationToEndTime(self.AnimBlockLight)
		self.Count = self.Count + 1
	end

	if CurPercent < 0.98 then
		self.bFull = false
	else
		self.bFull = true
	end

	local Probar = self.ProBarSetionList[Index]
	Probar:SetPercent(CurPercent)
	local SizeX = UIUtil.GetLocalSize(self.EFF_Highlight).X
	UIUtil.CanvasSlotSetPosition(self.EFF_Highlight, _G.UE.FVector2D(CurPercent * ProgressLength - SizeX, 0))
end

--两种退出动画表现，重写基类方法
function SkillEnergyStorageView:GetAnimOut()
	if self.AnimOutResult == EnergyAnimOutType.Faild then
		return self.AnimOutFaild
	elseif self.AnimOutResult == EnergyAnimOutType.Release then
		return self.AnimOutRelease
	elseif self.AnimOutResult == EnergyAnimOutType.ReleaseNotFull then
		return self.AnimOutReleaseNotFull
	end
end

return SkillEnergyStorageView