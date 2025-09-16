---
--- Author: chaooren
--- DateTime: 2022-04-07 14:29
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap
local EventID = require("Define/EventID")

local BARD_Click_Success_Range = 0.06
local ProgressBar_EFF_Mask_Min = 0.1
local ProgressBar_EFF_Mask_Max = 0.9

---@class JobSkillPoetView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_UI_Icon_022_Mask_UV1 UImage
---@field EFF_UI_Icon_022_Mask_UV2 UImage
---@field M_EFF_Icon_008_T1 UImage
---@field M_EFF_Icon_008_T1_2 UImage
---@field M_EFF_Icon_008_T1_3 UImage
---@field M_EFF_Icon_009_Mask_UV1 UImage
---@field M_EFF_Icon_009_Mask_UV1_1 UImage
---@field M_EFF_Icon_009_Mask_UV2 UImage
---@field M_EFF_Icon_009_Mask_UV2_1 UImage
---@field MainUIMoveControl_UIBP_1 MainUIMoveControlView
---@field PoetBlock UCanvasPanel
---@field PoetBlock_1 UCanvasPanel
---@field PoetBlock_2 UCanvasPanel
---@field PoetCursor UCanvasPanel
---@field PoetCurve UTextureCurve
---@field ProgressBar_EFF_Mask UProgressBar
---@field ProgressBar_Song02 UProgressBar
---@field ProgressBar_Song03 UProgressBar
---@field ProgressBar_Song04 UProgressBar
---@field SongSwitcher UWidgetSwitcher
---@field Text_Rhythm UTextBlock
---@field Anim_Battery UWidgetAnimation
---@field Anim_Battery_Into UWidgetAnimation
---@field Anim_Battery_Into01 UWidgetAnimation
---@field Anim_Battery_Into02 UWidgetAnimation
---@field Anim_Battery01 UWidgetAnimation
---@field Anim_Battery02 UWidgetAnimation
---@field Anim_Fault UWidgetAnimation
---@field Anim_Perfect UWidgetAnimation
---@field Anim_Poet_Song01 UWidgetAnimation
---@field Anim_Poet_Song02 UWidgetAnimation
---@field Anim_Poet_Song03 UWidgetAnimation
---@field Anim_Poet_Song04 UWidgetAnimation
---@field EffectMaterialList_BARD Image
---@field IconList_BARD Image
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillPoetView = LuaClass(ProfProSkillViewBase, true)
local SkillSpectrum_BARD = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_BARD_1 = LuaClass(SkillSpectrum_BARD, true)
local SkillSpectrum_BARD_2 = LuaClass(SkillSpectrum_BARD, true)
local SkillSpectrum_BARD_3 = LuaClass(SkillSpectrum_BARD, true)
local SkillSpectrum_BARD_NoBlock_1 = LuaClass(SkillSpectrum_BARD, true)
local SkillSpectrum_BARD_NoBlock_2 = LuaClass(SkillSpectrum_BARD, true)
local SkillSpectrum_BARD_NoBlock_3 = LuaClass(SkillSpectrum_BARD, true)

function JobSkillPoetView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_UI_Icon_022_Mask_UV1 = nil
	--self.EFF_UI_Icon_022_Mask_UV2 = nil
	--self.M_EFF_Icon_008_T1 = nil
	--self.M_EFF_Icon_008_T1_2 = nil
	--self.M_EFF_Icon_008_T1_3 = nil
	--self.M_EFF_Icon_009_Mask_UV1 = nil
	--self.M_EFF_Icon_009_Mask_UV1_1 = nil
	--self.M_EFF_Icon_009_Mask_UV2 = nil
	--self.M_EFF_Icon_009_Mask_UV2_1 = nil
	--self.MainUIMoveControl_UIBP_1 = nil
	--self.PoetBlock = nil
	--self.PoetBlock_1 = nil
	--self.PoetBlock_2 = nil
	--self.PoetCursor = nil
	--self.PoetCurve = nil
	--self.ProgressBar_EFF_Mask = nil
	--self.ProgressBar_Song02 = nil
	--self.ProgressBar_Song03 = nil
	--self.ProgressBar_Song04 = nil
	--self.SongSwitcher = nil
	--self.Text_Rhythm = nil
	--self.Anim_Battery = nil
	--self.Anim_Battery_Into = nil
	--self.Anim_Battery_Into01 = nil
	--self.Anim_Battery_Into02 = nil
	--self.Anim_Battery01 = nil
	--self.Anim_Battery02 = nil
	--self.Anim_Fault = nil
	--self.Anim_Perfect = nil
	--self.Anim_Poet_Song01 = nil
	--self.Anim_Poet_Song02 = nil
	--self.Anim_Poet_Song03 = nil
	--self.Anim_Poet_Song04 = nil
	--self.EffectMaterialList_BARD = nil
	--self.IconList_BARD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillPoetView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MainUIMoveControl_UIBP_1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillPoetView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.BARD_1, SkillSpectrum_BARD_NoBlock_1)
	self:BindSpectrumBehavior(SpectrumIDMap.BARD_2, SkillSpectrum_BARD_NoBlock_2)
	self:BindSpectrumBehavior(SpectrumIDMap.BARD_3, SkillSpectrum_BARD_NoBlock_3)
	self:BindSpectrumBehavior(SpectrumIDMap.BARD_1_1, SkillSpectrum_BARD_1)
	self:BindSpectrumBehavior(SpectrumIDMap.BARD_2_1, SkillSpectrum_BARD_2)
	self:BindSpectrumBehavior(SpectrumIDMap.BARD_3_1, SkillSpectrum_BARD_3)
	self.TextUnlock:SetText(_G.LSTR(140079))  -- 战歌量谱
	self.SkillSpectrumState = {}
	self.SkillSpectrumStateCount = 0
end

function JobSkillPoetView:OnDestroy()

end

function JobSkillPoetView:OnShow()
	self.Super:OnShow()
end

function JobSkillPoetView:OnHide()

end

function JobSkillPoetView:OnRegisterUIEvent()

end

function JobSkillPoetView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
end

function JobSkillPoetView:OnRegisterBinder()

end

function JobSkillPoetView:OnMajorUseSkill(Params)
	local SkillID = Params.IntParam1
	local BtnClickMap = _G.MainProSkillMgr.BtnClickMap
	for key, value in pairs(self.SpectrumPair) do
		local BtnClick = BtnClickMap[key]
		if BtnClick then
			local IDTable = string.split(BtnClick, ",")
			for _, value1 in pairs(IDTable) do
				if SkillID == tonumber(value1) and value.Begin == true then
					value:OnSongSkillClick()
					break
				end
			end
		end
	end
end

function JobSkillPoetView:DisableOtherSpectrum(SpectrumID)
	for key, _ in pairs(self.SpectrumPair) do
		if key ~= SpectrumID then
			_G.MainProSkillMgr:OnProSkillEnd(key)
		end
	end
end

function SkillSpectrum_BARD:OnInit()
	self.Super:OnInit()
	self.ProgressBar = nil
	self.BeginBoom = nil
	self.Index = 0
	self.BlockMap = {}
end

function SkillSpectrum_BARD:OnInitAfter()
	self.View.SongSwitcher:SetActiveWidgetIndex(0)
	_G.MainProSkillMgr:SendEventCondition(_G.EventID.SkillSpectrum_BardAnim, false)
	self.ProgressBar:SetPercent(0)
	self.View.ProgressBar_EFF_Mask:SetPercent(ProgressBar_EFF_Mask_Min)
	self.View.PoetCursor.Slot:SetPosition(_G.UE.FVector2D(0, self.View.PoetCurve:Eval(0, 0)) + self.View.PoetCurve.Slot:GetPosition())
	UIUtil.SetIsVisible(self.View.PoetCursor, false)
	for _, value in pairs(self.BlockMap) do
		value.EnterFirst = true
		UIUtil.SetIsVisible(value.BlockPtr, false)
		value.State = 0
	end
end

function SkillSpectrum_BARD:SkillSpectrumOn()
	self.View:DisableOtherSpectrum(self.SpectrumID)
	self:ChangeSongProgressBar(self.ProgressBar)
	self.View.PoetCursor.Slot:SetPosition(_G.UE.FVector2D(0, self.View.PoetCurve:Eval(0, 0)) + self.View.PoetCurve.Slot:GetPosition())
	UIUtil.SetIsVisible(self.View.PoetCursor, true)
	self.View.SkillSpectrumState[self.SpectrumID] = 1
	self.View.SkillSpectrumStateCount = self.View.SkillSpectrumStateCount + 1
end

function SkillSpectrum_BARD:SkillSpectrumOff()
	local NowSkillSpectrumState = self.View.SkillSpectrumState[self.SpectrumID]
	self.View.SkillSpectrumState[self.SpectrumID] = 0
	if NowSkillSpectrumState and NowSkillSpectrumState == 1 then
		self.View.SkillSpectrumStateCount = self.View.SkillSpectrumStateCount - 1
	end
	if self.View.SkillSpectrumStateCount <= 0 then
		self.View:PlayAnimationToEndTime(self.View.Anim_Poet_Song01)
		self:OnInitAfter()
	end
end

function SkillSpectrum_BARD:ValueUpdateEachFunc(CurValue)
	local CurProgressBar = self.ProgressBar
	local Value = (CurValue or 0) / self.SpectrumMaxValue
	self.View.ProgressBar_EFF_Mask:SetPercent(Value * (ProgressBar_EFF_Mask_Max - ProgressBar_EFF_Mask_Min) + ProgressBar_EFF_Mask_Min)

	local CurveSize = self.View.PoetCurve:GetCurveSize()
	local PositionX = Value * CurveSize
	local PositionY = self.View.PoetCurve:Eval(PositionX, 0)
	self.View.PoetCursor.Slot:SetPosition(_G.UE.FVector2D(PositionX, PositionY) + self.View.PoetCurve.Slot:GetPosition())

	for _, value in pairs(self.BlockMap) do
		local Distance = value.BlockX - Value
		if value.EnterFirst == true and Distance < BARD_Click_Success_Range and Distance > 0 then
			value.EnterFirst = false
			self.View:PlayAnimation(value.IntoAnim, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 0.8)
			_G.MainProSkillMgr:SendEventCondition(_G.EventID.SkillSpectrum_BardAnim, true)
		elseif value.EnterFirst == false and Distance < -BARD_Click_Success_Range then
			value.EnterFirst = true
			_G.MainProSkillMgr:SendEventCondition(_G.EventID.SkillSpectrum_BardAnim, false)
		end
	end

	CurProgressBar:SetPercent(Value)
end

function SkillSpectrum_BARD:ChangeSongProgressBar(BuffProgressBar)
	_G.MainProSkillMgr:SendEventCondition(_G.EventID.SkillSpectrum_BardAnim, false)
	if BuffProgressBar == nil then
		return
	end

	self.View.SongSwitcher:SetActiveWidgetIndex(self.Index)
	self.CurrentValue = 0
	self.View.ProgressBar_EFF_Mask:SetPercent(ProgressBar_EFF_Mask_Min)
	if self.Index ~= 0 then
		self.View:PlayAnimationToEndTime(self.BeginBoom)
		BuffProgressBar:SetPercent(0)
		--显示按钮并设置位置
		self:SpawnPoetBlock()
	else
		self.View:PlayAnimationToEndTime(self.View.Anim_Poet_Song01)
		--UIUtil.SetIsVisible(self.View.PoetBlock, false)
	end
end

function SkillSpectrum_BARD:SpawnPoetBlock()
	if self.SpectrumID == SpectrumIDMap.BARD_3_1 then
		self.View:SwitchSpecialMaterial_BARD()
	else
		self.View:SwitchNormalMaterial_BARD()
	end
	for _, value in pairs(self.BlockMap) do
		UIUtil.SetIsVisible(value.BlockPtr, true)
		local CurveSize = self.View.PoetCurve:GetCurveSize()
		local Range = value.Range
		local BlockPosX = math.random(Range[1], Range[2]) / 100
		local BlockPositionX = BlockPosX * CurveSize
		value.BlockX = BlockPosX
		local BlockPositionY = self.View.PoetCurve:Eval(BlockPositionX, 0)
		value.BlockPtr.Slot:SetPosition(_G.UE.FVector2D(BlockPositionX, BlockPositionY) + self.View.PoetCurve.Slot:GetPosition())
		self.View:PlayAnimationToEndTime(value.ShowAnim)
	end
end

function SkillSpectrum_BARD:CheckSongSuccess()
	local CurrentProgressBar = self.ProgressBar
	if CurrentProgressBar == nil then
		return false
	end

	local CurrentPrecent = CurrentProgressBar.Percent
	for _, value in pairs(self.BlockMap) do
		local CurrentBtnPrecent =  value.BlockX
		if math.abs(CurrentBtnPrecent - CurrentPrecent) < BARD_Click_Success_Range and value.State == 0 then
			value.State = 1
			return true
		end
	end
	return false
end

function SkillSpectrum_BARD:OnSongSkillClick()
	self.View:StopAnimation(self.View.Anim_Perfect)
	self.View:StopAnimation(self.View.Anim_Fault)
	if self:CheckSongSuccess() then
		local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
		local MsgBody = {};
		local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SPECTRUM_SUCC
		MsgBody.Cmd = SubMsgID
		MsgBody.SpectrumSuccID = self.SpectrumID
		_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
		self.View.Text_Rhythm:SetText(LSTR("完美"))
		self.View:PlayAnimation(self.View.Anim_Perfect, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
	else
		self.View.Text_Rhythm:SetText(LSTR("失误"))
		self.View:PlayAnimation(self.View.Anim_Fault, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, true)
	end
end

function SkillSpectrum_BARD_1:OnInit()
	self.Super:OnInit()
	self.SpectrumID = SpectrumIDMap.BARD_1_1
	self.ProgressBar = self.View.ProgressBar_Song02
	self.BeginBoom = self.View.Anim_Poet_Song02
	self.Index = 1
	local Param2 = _G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID)
	if Param2 == nil then
		return
	end
	self.BlockMap[1] = {BlockPtr = self.View.PoetBlock, Range = Param2[1], BlockX = 0, IntoAnim = self.View.Anim_Battery_Into
	, ShowAnim = self.View.Anim_Battery, EnterFirst = true, State = 0}
	self:OnInitAfter()
end
function SkillSpectrum_BARD_2:OnInit()
	self.Super:OnInit()
	self.SpectrumID = SpectrumIDMap.BARD_2_1
	self.ProgressBar = self.View.ProgressBar_Song03
	self.BeginBoom = self.View.Anim_Poet_Song03
	self.Index = 2
	local Param2 = _G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID)
	if Param2 == nil then
		return
	end
	self.BlockMap[1] = {BlockPtr = self.View.PoetBlock, Range = Param2[1], BlockX = 0, IntoAnim = self.View.Anim_Battery_Into
	, ShowAnim = self.View.Anim_Battery, EnterFirst = true, State = 0}
	self:OnInitAfter()
end
function SkillSpectrum_BARD_3:OnInit()
	self.Super:OnInit()
	self.SpectrumID = SpectrumIDMap.BARD_3_1
	self.ProgressBar = self.View.ProgressBar_Song04
	self.BeginBoom = self.View.Anim_Poet_Song04
	self.Index = 3
	local Param2 = _G.MainProSkillMgr:GetSpectrumTypeParam2(self.SpectrumID)
	if Param2 == nil then
		return
	end
	self.BlockMap[1] = {BlockPtr = self.View.PoetBlock, Range = Param2[1], BlockX = 0, IntoAnim = self.View.Anim_Battery_Into, ShowAnim = self.View.Anim_Battery, EnterFirst = true, State = 0}
	self.BlockMap[2] = {BlockPtr = self.View.PoetBlock_1, Range = Param2[2], BlockX = 0, IntoAnim = self.View.Anim_Battery_Into01, ShowAnim = self.View.Anim_Battery01, EnterFirst = true, State = 0}
	self.BlockMap[3] = {BlockPtr = self.View.PoetBlock_2, Range = Param2[3], BlockX = 0, IntoAnim = self.View.Anim_Battery_Into02, ShowAnim = self.View.Anim_Battery02, EnterFirst = true, State = 0}
	self:OnInitAfter()
end

function SkillSpectrum_BARD_NoBlock_1:OnInit()
	self.Super:OnInit()
	self.SpectrumID = SpectrumIDMap.BARD_1
	self.ProgressBar = self.View.ProgressBar_Song02
	self.BeginBoom = self.View.Anim_Poet_Song02
	self.Index = 1
	self:OnInitAfter()
end

function SkillSpectrum_BARD_NoBlock_2:OnInit()
	self.Super:OnInit()
	self.SpectrumID = SpectrumIDMap.BARD_2
	self.ProgressBar = self.View.ProgressBar_Song03
	self.BeginBoom = self.View.Anim_Poet_Song03
	self.Index = 2
	self:OnInitAfter()
end

function SkillSpectrum_BARD_NoBlock_3:OnInit()
	self.Super:OnInit()
	self.SpectrumID = SpectrumIDMap.BARD_3
	self.ProgressBar = self.View.ProgressBar_Song04
	self.BeginBoom = self.View.Anim_Poet_Song04
	self.Index = 3
	self:OnInitAfter()
end

return JobSkillPoetView