--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-07-18 20:49:09
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-09-28 23:34:47
FilePath: \Script\Game\Hotel\HotelMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require ("Protocol/ProtoCS")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local ProtoRes = require("Protocol/ProtoRes")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
local MajorUtil = require("Utils/MajorUtil")

local DataReportUtil = require("Utils/DataReportUtil")
local SaveKey = require("Define/SaveKey")
local USaveMgr = _G.UE.USaveMgr

-- @class HotelMgr : MgrBase
local HotelMgr = LuaClass(MgrBase)

local HotelCfg = {
	[1] = ProtoRes.client_global_cfg_id.GLOBAL_CFG_HOTEL_CUT_ZERO,
	[2] = ProtoRes.client_global_cfg_id.GLOBAL_CFG_HOTEL_CUT_ONE,
	[3] = ProtoRes.client_global_cfg_id.GLOBAL_CFG_HOTEL_CUT_TWO,
}

HotelMgr.ReportDefine = {
	Enter = 1,
	Leave = 2
}
function HotelMgr:Ctor()

end

function HotelMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.EnterMapFinish, self.OnEnterWorld)
end

function HotelMgr:OnGameEventLoginRes(Params)
	local bReconnect = Params.bReconnect
	if bReconnect then self.WaitForEnterWorld = false return end
	self.WaitForEnterWorld = true
end

function HotelMgr:OnEnterWorld()
	if self.WaitForEnterWorld then
		self.WaitForEnterWorld = false
		local pWorldCfg =  _G.PWorldMgr:GetCurrPWorldTableCfg()
		if pWorldCfg and next(pWorldCfg) then
			local pWolrdID = pWorldCfg.ID or 0
			for _, value in pairs(HotelCfg) do
				local Cfg = ClientGlobalCfg:FindCfgByKey(value)
				if Cfg and next(Cfg) then
					if Cfg.Value[1] == pWolrdID then
						self:CheckPlayHistory(SaveKey.HotelWake)
						_G.StoryMgr:PlayDialogueSequence(Cfg.Value[2])
						self:SavePlayHistory(SaveKey.HotelWake)
					end
				end
			end
		end
	end
end

function HotelMgr:SavePlayHistory(Key)
	USaveMgr.SetInt(Key, 1, false)
end

function HotelMgr:CheckPlayHistory(Key)
	local SaveValue = USaveMgr.GetInt(Key, 0, false)
	if SaveValue == 1 then
		SequencePlayerVM.bHideAllTopButton = false
	else
		SequencePlayerVM.bHideAllTopButton = true
	end
end

function HotelMgr:CheckNeedReport(ID)
	for _, value in pairs(HotelCfg) do
		local Cfg = ClientGlobalCfg:FindCfgByKey(value)
		if Cfg and next(Cfg) then
			if Cfg.Value[1] == ID then
				DataReportUtil.ReportHotelData("HotelInfo", self.ReportDefine.Enter, ID, _G.UE.UVersionMgr.GetAppVersion())
				return 
			end
		end
	end
end

function HotelMgr:CheckNeedPlaySeq(IsReturnToLogin)
	local pWorldCfg =  _G.PWorldMgr:GetCurrPWorldTableCfg()
	if pWorldCfg and next(pWorldCfg) then
		local pWolrdID = pWorldCfg.ID or 0
		for _, value in pairs(HotelCfg) do
			local Cfg = ClientGlobalCfg:FindCfgByKey(value)
			if Cfg and next(Cfg) then
				if Cfg.Value[1] == pWolrdID then
					self:CheckPlayHistory(SaveKey.HotelWake)
					local AudioUtil = require("Utils/AudioUtil")
					local SaveKey = require("Define/SaveKey")
					_G.UE.UAudioMgr.Get():StopSceneBGM()
					local EntityID = MajorUtil.GetMajorEntityID()
					local AudioID = AudioUtil.SyncLoadAndPlayUISound(EntityID, "/Game/WwiseAudio/Events/sound/zingle/Zingle_Sleep/Play_Zingle_Sleep.Play_Zingle_Sleep")

					local PlaybackSettings = {
						bDisableMovementInput = true,
						bDisableLookAtInput = true,
						bPauseAtEnd = true,
					}
					local CallBack = function()
						if IsReturnToLogin then
							_G.LoginMgr:ReturnToLogin(true)
						else
							_G.LoginMgr:ReturnToSelectRoleView()
						end
						_G.HotelMgr:SavePlayHistory(SaveKey.HotelSleep)
						AudioUtil.StopSound(AudioID)
					end
					if Cfg.Value[3] and Cfg.Value[3] ~= 0 then
						_G.StoryMgr:PlayDialogueSequence(Cfg.Value[3], CallBack, nil, CallBack, PlaybackSettings)
					else
						if IsReturnToLogin then
							_G.LoginMgr:ReturnToLogin(true)
						else
							_G.LoginMgr:ReturnToSelectRoleView()
						end
					end
					return
				end
			end
		end
	end
	if IsReturnToLogin then
		_G.LoginMgr:ReturnToLogin(true)
	else
		_G.LoginMgr:ReturnToSelectRoleView()
	end
end

return HotelMgr