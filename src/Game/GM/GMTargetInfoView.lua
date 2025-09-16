---
--- Author: chaooren
--- DateTime: 2023-01-09 10:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCS = require ("Protocol/ProtoCS")
local BUFF_REASON = ProtoCS.BUFF_ADD_REASON
local CS_CMD = ProtoCS.CS_CMD
local CS_DEBUG_CMD = ProtoCS.CS_DEBUG_CMD

---@class GMTargetInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content URichTextBox
---@field FButton UFButton
---@field FButton_1 UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMTargetInfoView = LuaClass(UIView, true)

local BuffHideDelay = 2

local MissNum = -1

local function SetColorFormat(Text, Color)
	return string.format("<span color=\"%s\" size=\"20\">%s</>", Color, Text)
end

local function EffectList2Str(Effects)
	local Ret = ""
	if Effects == nil then
		return Ret
	end
	for index, value in ipairs(Effects) do
		Ret = Ret .. tostring(value)
		if index < #Effects then
			Ret = Ret .. ","
		end
	end
	return Ret
end

local function ConvertFormatTime(TimeStamp)
	local TimeSecond = math.floor(TimeStamp / 1000)
	return _G.TimeUtil.GetTimeFormat("%H:%M:%S", TimeSecond) .. string.format(".%d", TimeStamp - TimeSecond * 1000)
end

local function GenFormatAttackValue(Value)
	Value = Value or 0
	if Value == MissNum then
		return SetColorFormat("miss","#fa0003ff")
	end
	return SetColorFormat(string.format("%13d", Value), "#fa0003ff")
end

function GMTargetInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--self.FButton = nil
	--self.FButton_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMTargetInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMTargetInfoView:OnInit()
	self.EntityID = 0
	self.SelectedEntityID = 0
	self.CacheBuffList = {}
end

function GMTargetInfoView:OnDestroy()

end

function GMTargetInfoView:OnShow()
	self.TextBlock_99:SetText(_G.LSTR(1440022)) --监控选中目标
	self.TextBlock:SetText(_G.LSTR(1440023)) --清空监控列表
	self.Content:SetText(_G.LSTR(1440024)) --目标信息监控
	if self.Params ~= nil then
		self.EntityID = tonumber(self.Params.EntityID)
	else
		self.EntityID = _G.TargetMgr:GetMajorSelectedTarget()
	end
end

function GMTargetInfoView:OnHide()

end

function GMTargetInfoView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton, self.OnListenSelectedTargetClick)
	UIUtil.AddOnClickedEvent(self, self.FButton_1, self.OnClearListenClick)
end

function GMTargetInfoView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.GMGetTargetCombatInfo, self.OnGetTargetCombatInfo)
	self:RegisterGameEvent(_G.EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
	--self:RegisterGameEvent(_G.EventID.SelectTarget, self.OnGameEventSelectTarget)
end

function GMTargetInfoView:OnRegisterBinder()

end

function GMTargetInfoView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.2, 0)
end

function GMTargetInfoView:OnTimer()
	self:UpdateBuffHide()
	local MajorTargetID = self.EntityID
	if nil == MajorTargetID or MajorTargetID <= 0 or ActorUtil.GetActorByEntityID(MajorTargetID) == nil then
		return
	end

	self:SendReq(MajorTargetID)
end

function GMTargetInfoView:SendReq(TargetID)
	local MsgID = CS_CMD.CS_CMD_DEBUG
	local MsgBody = {}
	local SubMsgID = CS_DEBUG_CMD.CS_DEBUG_CMD_SKILL_INFO_GET
	local SkillInfoReq = {}
	SkillInfoReq.EntityID = TargetID
	MsgBody.Cmd = SubMsgID
	MsgBody.SkillInfoReq  = SkillInfoReq
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GMTargetInfoView:OnListenSelectedTargetClick()
	if self.SelectedEntityID then
		self.EntityID = self.SelectedEntityID
	end
end

function GMTargetInfoView:OnClearListenClick()
	self.EntityID = 0
	_G.GMMgr:ReqGM("cell skill debug clear")
end

function GMTargetInfoView:OnGetTargetCombatInfo(MsgBody)
	if MsgBody == nil then
		return
	end
	local Split_Line = SetColorFormat("|", "#fa0003ff")
    local SkillInfoRsp = MsgBody.SkillInfoRsp
	local Text = ""
	Text = Text .. SetColorFormat("固定数据", "#a8a800ff") .. "\n"
	Text = Text .. string.format("%s：%d | %s\n", SetColorFormat("实例信息", "#72b8fdff"), SkillInfoRsp.id, SkillInfoRsp.name)
	Text = Text .. string.format("%s：%d\n", SetColorFormat("朝向", "#72b8fdff"), SkillInfoRsp.dir)
	local Cfg = SkillMainCfg:FindCfgByKey(SkillInfoRsp.skill_id)
	local SkillName = ""
	if Cfg then
		SkillName = Cfg.SkillName
	end
	Text = Text .. string.format("%s：%d(%s)\n", SetColorFormat("最后释放技能", "#72b8fdff"), SkillInfoRsp.skill_id, SkillName)
	Text = Text .. string.format("%s：%d\n", SetColorFormat("最后释放技能的子表ID", "#72b8fdff"), SkillInfoRsp.sub_skill_id)
	Text = Text .. string.format("%s：%s\n", SetColorFormat("是否在技能流程中", "#72b8fdff"), SkillInfoRsp.casting_skill == true and "是" or "否")
	Text = Text .. string.format("%s: %s\n\n", SetColorFormat("跑步状态", "#72b8fdff"), SkillInfoRsp.walk == true and "走" or "跑")

	Text = Text .. SetColorFormat("命中信息", "#a8a800ff") .. "\n"
	Text = Text .. string.format("%s：%s\n\n", SetColorFormat("时间", "#72b8fdff"), ConvertFormatTime(SkillInfoRsp.attack_time))
	Text = Text .. string.format("        %s         | %s | %s | %s\n"
		, SetColorFormat("命中目标ID", "#72b8fdff")
		, SetColorFormat("命中目标名称", "#72b8fdff")
		, SetColorFormat("伤害值", "#72b8fdff")
		, SetColorFormat("效果列表", "#72b8fdff"))
	for _, value in ipairs(SkillInfoRsp.attack) do
		Text = Text .. string.format("%d | %25s |%s| %s\n", value.id, value.name, GenFormatAttackValue(value.hurt), EffectList2Str(value.effects))
	end
	Text = Text .. "\n"

	Text = Text .. SetColorFormat("被命中信息", "#a8a800ff") .. "\n"
	Text = Text .. string.format("%s：%s\n\n", SetColorFormat("时间", "#72b8fdff"), ConvertFormatTime(SkillInfoRsp.be_attack_time))
	if #SkillInfoRsp.be_attacked > 0 then
		Text = Text .. string.format("        %s         | %s | %s\n"
			, SetColorFormat("伤害来源ID", "#72b8fdff")
			, SetColorFormat("伤害来源名称", "#72b8fdff")
			, SetColorFormat("效果列表", "#72b8fdff"))
		local Attack_Source = SkillInfoRsp.be_attacked[1]
		Text = Text .. string.format("%d | %20s | %s\n", Attack_Source.id, Attack_Source.name, EffectList2Str(Attack_Source.effects))
		Text = Text .. string.format("        %s         | %s | %s | %s\n"
			, SetColorFormat("命中目标ID", "#72b8fdff")
			, SetColorFormat("命中目标名称", "#72b8fdff")
			, SetColorFormat("伤害值", "#72b8fdff")
			, SetColorFormat("效果列表", "#72b8fdff"))
		for index, value in ipairs(SkillInfoRsp.be_attacked) do
			if index > 1 then
				Text = Text .. string.format("%d | %25s |%s| %s\n", value.id, value.name, GenFormatAttackValue(value.hurt), EffectList2Str(value.effects))
			end
		end
	else
		Text = Text .. "无被命中信息\n"
	end
	Text = Text .. "\n"

	Text = Text .. SetColorFormat("BUFF信息", "#a8a800ff") .. "\n"
	Text = Text .. string.format("%s | %s | %s | %s | %s \n"
		, SetColorFormat("BUFF ID", "#72b8fdff")
		, SetColorFormat("层数", "#72b8fdff")
		, SetColorFormat(string.format("%25s", "施法者"), "#72b8fdff")
		, SetColorFormat("来源", "#72b8fdff")
		, SetColorFormat("已生效技能效果", "#72b8fdff"))

	for _, value in ipairs(SkillInfoRsp.buff) do
		self.CacheBuffList[value.buff_id] = {BuffData = value, LastTime = -1, Type = 0}
	end

	for _, BuffData in pairs(self.CacheBuffList) do
		local value = BuffData.BuffData

		local Caster = tostring(value.giver)
		if MajorUtil.IsMajor(value.giver) then
			Caster = "自身"
		end

		local Source_Format = "其他"
		local Buff_Reason = value.buff_add_reason
		if Buff_Reason == BUFF_REASON.LEVEL then
			Source_Format = string.format("关卡 %d", value.buff_reason_arg1)
		elseif Buff_Reason == BUFF_REASON.SKILL then
			Source_Format = string.format("技能 %d - %d", value.buff_reason_arg1, value.buff_reason_arg2)
		elseif Buff_Reason == BUFF_REASON.BUFF then
			Source_Format = string.format("BUFF %d - %d", value.buff_reason_arg1, value.buff_reason_arg2)
		elseif Buff_Reason == BUFF_REASON.BIRTH then
			Source_Format = string.format("怪物 %d", value.buff_reason_arg1)
		end

		--Text = Text .. string.format("%s | %s | %s | %s\n", tostring(value.buff_id), Caster, Source_Format, EffectList2Str(value.effects))
		if BuffData.Type == 0 then
			BuffData.Type = 1
			Text = Text .. string.format("   %s | %s | %25s | %s | %s\n", tostring(value.buff_id), tostring(value.pile), Caster, Source_Format, EffectList2Str(value.effects))
		elseif BuffData.Type == 1 then
			BuffData.Type = 2
			BuffData.LastTime = BuffHideDelay
			Text = Text .. string.format("   %s | %s | %25s | %s | %s\n", SetColorFormat(tostring(value.buff_id), "#da3dffff"), tostring(value.pile), Caster, Source_Format, EffectList2Str(value.effects))
		else
			Text = Text .. string.format("    %s | %s | %25s | %s | %s\n", SetColorFormat(tostring(value.buff_id), "#da3dffff"), tostring(value.pile), Caster, Source_Format, EffectList2Str(value.effects))
		end
	end

	Text = Text .. SetColorFormat("仇恨列表（前8位）","#a8a800ff") .. "\n"
	Text = Text .. string.format("%s | %s | %s \n"
		, SetColorFormat("仇恨目标ID", "#72b8fdff")
		, SetColorFormat(string.format("%25s", "名称"), "#72b8fdff")
		, SetColorFormat("仇恨值", "#72b8fdff"))
	for _, value in pairs(SkillInfoRsp.enmities) do
		Text = Text .. string.format("%s | %s | %s \n", tostring(value.entity_id), ActorUtil.GetActorName(value.entity_id), tostring(value.value))
	end



	Text = Text .. SetColorFormat("关注列表","#a8a800ff") .. "\n"
	Text = Text .. string.format("%s | %s \n"
	, SetColorFormat("关注目标ID", "#72b8fdff")
	, SetColorFormat(string.format("%25s", "名称"), "#72b8fdff"))
	for _, value in pairs(SkillInfoRsp.interests) do
		Text = Text .. string.format("%s | %s \n", tostring(value.entity_id), ActorUtil.GetActorName(value.entity_id))
	end

	Text = string.gsub(Text, "|", Split_Line)
	self.Content:SetText(Text)
end

function GMTargetInfoView:OnGameEventSelectTarget(Params)
	local EntityID = Params.ULongParam1
	self.EntityID = nil
	self:SendReq(EntityID)
end

function GMTargetInfoView:UpdateBuffHide()
	for key, value in pairs(self.CacheBuffList) do
		if value.Type == 2 then
			value.LastTime = value.LastTime - 0.2
			if value.LastTime < 0 then
				self.CacheBuffList[key] = nil
			end
		end
	end
end

function GMTargetInfoView:OnGameEventTargetChangeMajor(TargetID)
	if TargetID then
		--self.EntityID = TargetID
		self.SelectedEntityID = TargetID
	end
end

return GMTargetInfoView