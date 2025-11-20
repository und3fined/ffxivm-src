--
-- Author: peterxie
-- Date:
-- Description: PVP小地图
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PVPMapTargetItemVM = require("Game/PVP/Map/VM/PVPMapTargetItemVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")

local MapDefine = require("Game/Map/MapDefine")
local MapMarkerType = MapDefine.MapMarkerType

local ProtoRes = require ("Protocol/ProtoRes")
local PVPCommunicateCommand = ProtoRes.PVPCommunicateCommand
local PVPCommunicateMethod = ProtoRes.PVPCommunicateMethod
local PVPCommunicateTarget = ProtoRes.PVPCommunicateTarget

local LSTR = _G.LSTR
local PVPColosseumMgr ---@type PVPColosseumMgr
local PVPTeamMgr ---@type PVPTeamMgr


---@class PVPMapVM : UIViewModel
local PVPMapVM = LuaClass(UIViewModel)

function PVPMapVM:Ctor()
	 -- 是否拖拽缩放地图中
	self.MapDragScale = false

	-- 可选目标列表
	self.TargetVMList = UIBindableList.New(PVPMapTargetItemVM)

	-- 沟通信息类型
	self.CommandType = PVPCommunicateCommand.PVPCommunicateCommandNone
end

function PVPMapVM:OnInit()

end

function PVPMapVM:OnBegin()
	PVPColosseumMgr = _G.PVPColosseumMgr
	PVPTeamMgr = _G.PVPTeamMgr
end

function PVPMapVM:OnEnd()

end

function PVPMapVM:OnShutdown()

end


---更新可选目标列表
function PVPMapVM:UpdateTargetList()
	local TargetList = {}
	local TargetItem

	-- 所有敌人
	local EnemyMemberVMList = PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberList()
	for i = 1, EnemyMemberVMList:Length() do
		local MemberVM = EnemyMemberVMList:Get(i)
		if MemberVM then
			TargetItem = { ID = MemberVM.RoleID, IsPlayer = true, MemberVM = MemberVM, }
			table.insert(TargetList, TargetItem)
		end
	end

	-- 水晶
	TargetItem = { ID = PVPColosseumDefine.ColosseumConstant.EXD_BNPC_BASE_MKS_CRYSTAL, IsColosseumCrystal = true, }
	table.insert(TargetList, TargetItem)

	-- 主角自己
	local PlayerMemberVMList = PVPTeamMgr:GetPVPTeamVM():GetTeamMemberList()
	for i = 1, PlayerMemberVMList:Length() do
		local MemberVM = PlayerMemberVMList:Get(i)
		if MemberVM and MemberVM:IsMajorRole() then
			TargetItem = { ID = MemberVM.RoleID, IsPlayer = true, MemberVM = MemberVM, }
			table.insert(TargetList, TargetItem)
			break
		end
	end

	self.TargetVMList:UpdateByValues(TargetList)
end


---直接点击沟通
function PVPMapVM:SendCommunicateInfoByClick()
	local PVPCommunicateInfo = {}
	PVPCommunicateInfo.SendRoleID = MajorUtil.GetMajorRoleID()
	PVPCommunicateInfo.Command = self.CommandType
	PVPCommunicateInfo.Method = PVPCommunicateMethod.PVPCommunicateMethodClick

	if PVPCommunicateInfo.Command == PVPCommunicateCommand.PVPCommunicateCommandLimit then
		-- 极限技进度百分比
		local MajorMemberVM = PVPTeamMgr:FindMemberVMByRoleID(MajorUtil.GetMajorRoleID())
		if not MajorMemberVM then
			return
		end
		PVPCommunicateInfo.ParamID = math.floor(MajorMemberVM.LBPercent * 100)
	end
	PVPCommunicateInfo.Target = PVPCommunicateTarget.PVPCommunicateTargetNone

	PVPColosseumMgr:SendColosseumCommunicate(PVPCommunicateInfo)
end

---拖拽选中小地图目标沟通
---@param MapMarker MapMarkerMonster | MapMarkerPVPPlayer
function PVPMapVM:SendCommunicateInfoByMiniMap(MapMarker)
	local PVPCommunicateInfo = {}
	PVPCommunicateInfo.SendRoleID = MajorUtil.GetMajorRoleID()
	PVPCommunicateInfo.Command = self.CommandType
	PVPCommunicateInfo.Method = PVPCommunicateMethod.PVPCommunicateMethodMiniMap

	local TargetType
	local MarkerType = MapMarker:GetType()
	if MarkerType == MapMarkerType.Monster and MapMarker.IsColosseumCrystal then
		TargetType = PVPCommunicateTarget.PVPCommunicateTargetCrystal
		PVPCommunicateInfo.ParamID = MapMarker:GetResID()
	elseif MarkerType == MapMarkerType.PVPPlayer then
		TargetType = PVPCommunicateTarget.PVPCommunicateTargetPlayerInView
		PVPCommunicateInfo.ParamID = MapMarker:GetRoleID()
	end
	PVPCommunicateInfo.Target = TargetType

	PVPColosseumMgr:SendColosseumCommunicate(PVPCommunicateInfo)
end

---拖拽选中目标列表沟通
---@param TargetItemVM PVPMapTargetItemVM
function PVPMapVM:SendCommunicateInfoByTargetList(TargetItemVM)
	local PVPCommunicateInfo = {}
	PVPCommunicateInfo.SendRoleID = MajorUtil.GetMajorRoleID()
	PVPCommunicateInfo.Command = self.CommandType
	PVPCommunicateInfo.Method = PVPCommunicateMethod.PVPCommunicateMethodTargetList

	local TargetType
	if TargetItemVM.IsColosseumCrystal then
		TargetType = PVPCommunicateTarget.PVPCommunicateTargetCrystal
		PVPCommunicateInfo.ParamID = TargetItemVM.ID
	elseif TargetItemVM.IsPlayer then
		if TargetItemVM.IsInVision then
			TargetType = PVPCommunicateTarget.PVPCommunicateTargetPlayerInView
		else
			TargetType = PVPCommunicateTarget.PVPCommunicateTargetPlayerOutView
		end
		PVPCommunicateInfo.ParamID = TargetItemVM.ID
	end
	PVPCommunicateInfo.Target = TargetType

	PVPColosseumMgr:SendColosseumCommunicate(PVPCommunicateInfo)
end



---@enum 选中目标分类
local SelectTargetClassification =
{
	Click = 0, -- 直接点击，不需选中目标
	Crystal = 1, -- 选中水晶
	PlayerSelf = 2, -- 选中自己，即沟通信息发送者
	PlayerTeammate = 3, -- 选中队友
	PlayerEnemyInView = 4, -- 选中视野内敌人
	PlayerEnemyOutView = 5, -- 选中视野外敌人
}

---选中目标配置
local SelectTargetConfig =
{
	[SelectTargetClassification.Click] =
	{
		[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "发起进攻",
		[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "大家先撤退",
		[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "大家集合",
		[PVPCommunicateCommand.PVPCommunicateCommandLimit] = "极限技准备就绪",
		[PVPCommunicateCommand.PVPCommunicateCommandLimit + 1] = "充能%d%%",
	},

	[SelectTargetClassification.Crystal] =
	{
		[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "夺回水晶",
		[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "暂时撤退",
		[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "集合护送水晶",
	},

	[SelectTargetClassification.PlayerSelf] =
	{
		[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "我要进攻了",
		[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "我先退后调整",
		[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "大家集合",
	},

	[SelectTargetClassification.PlayerTeammate] =
	{
		[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "发起进攻",
		[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "大家先撤退",
		[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "大家集合",
	},

	[SelectTargetClassification.PlayerEnemyInView] =
	{
		[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "攻击",
		[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "撤退",
		[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "集火",
	},

	[SelectTargetClassification.PlayerEnemyOutView] =
	{
		[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "敌人消失",
		[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "敌人消失",
		[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "敌人消失",
	},
}

---沟通信息音效配置
local CommandAudioConfig =
{
	[PVPCommunicateCommand.PVPCommunicateCommandAttack] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp02/Play_SE_Vfx_Monster_m0769_stlp02.Play_SE_Vfx_Monster_m0769_stlp02'",
	[PVPCommunicateCommand.PVPCommunicateCommandRetreat] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp03/Play_SE_Vfx_Monster_m0769_stlp03.Play_SE_Vfx_Monster_m0769_stlp03'",
	[PVPCommunicateCommand.PVPCommunicateCommandMuster] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp04/Play_SE_Vfx_Monster_m0769_stlp04.Play_SE_Vfx_Monster_m0769_stlp04'",
	[PVPCommunicateCommand.PVPCommunicateCommandLimit] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp04/Play_SE_Vfx_Monster_m0769_stlp04.Play_SE_Vfx_Monster_m0769_stlp04'",
}


---获取沟通信息提示
---@return string
function PVPMapVM:GetCommunicateInfoTips(SendRoleID, CommandType, SendMethod, TargetType, ParamID)
	local TipsText = ""

	if SendMethod == PVPCommunicateMethod.PVPCommunicateMethodClick then
		local TargetClassification = SelectTargetClassification.Click
		local CommandConfig = SelectTargetConfig[TargetClassification]
		TipsText = CommandConfig[CommandType]

		if CommandType == PVPCommunicateCommand.PVPCommunicateCommandLimit then
			local LBPercent = ParamID
			if LBPercent <= 100 then
				TipsText = CommandConfig[PVPCommunicateCommand.PVPCommunicateCommandLimit + 1]
				TipsText = string.format(TipsText, LBPercent)
			end
		end

	elseif SendMethod == PVPCommunicateMethod.PVPCommunicateMethodMiniMap
		or SendMethod == PVPCommunicateMethod.PVPCommunicateMethodTargetList then
		local TargetClassification
		if TargetType == PVPCommunicateTarget.PVPCommunicateTargetCrystal then
			TargetClassification = SelectTargetClassification.Crystal

		elseif TargetType == PVPCommunicateTarget.PVPCommunicateTargetPlayerInView then
			local TargetRoleID = ParamID
			if TargetRoleID == SendRoleID then
				TargetClassification = SelectTargetClassification.PlayerSelf
			elseif PVPTeamMgr:IsTeamMemberByRoleID(TargetRoleID) then
				TargetClassification = SelectTargetClassification.PlayerTeammate
			elseif PVPTeamMgr:IsEnemyTeamMemberByRoleID(TargetRoleID) then
				TargetClassification = SelectTargetClassification.PlayerEnemyInView
			end

		elseif TargetType == PVPCommunicateTarget.PVPCommunicateTargetPlayerOutView then
			TargetClassification = SelectTargetClassification.PlayerEnemyOutView
		end

		local CommandConfig = SelectTargetConfig[TargetClassification]
		if CommandConfig then
			TipsText = CommandConfig[CommandType]
		end
	end

	return TipsText
end

---播放沟通信息音效
function PVPMapVM:PlayCommunicateInfoAudio(CommandType)
	local CommandAudioPath = CommandAudioConfig[CommandType]
	if CommandAudioPath then
		AudioUtil.LoadAndPlay2DSound(CommandAudioPath)
	end
end


return PVPMapVM