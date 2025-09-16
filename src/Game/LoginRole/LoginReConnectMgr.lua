local LuaClass = require("Core/LuaClass")

local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require ("Utils/MajorUtil")

-- local ProtoCommon = require("Protocol/ProtoCommon")

local LoginRoleShowPageVM = require("Game/LoginRole/LoginRoleShowPageVM")
local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

local LoginConfig = require("Define/LoginConfig")
-- local RaceFaceCfg = require("TableCfg/RaceFaceCfg")
local CommonUtil = require("Utils/CommonUtil")
local LoginMapTodparamCfg = require("TableCfg/LoginMapTodparamCfg")

local ProtoRes = require ("Protocol/ProtoRes")
local SaveKey = require("Define/SaveKey")

local Json = require("Core/Json")
local LSTR = _G.LSTR

---@class LoginReConnectMgr
local LoginReConnectMgr = LuaClass()

LoginReConnectMgr.SaveData = {
	CurPhase = 0,
	MaxDonePhase = 0,

	--选种族
	RaceID = 0,
	Gender = 0,
	--选部族
	TribID = 0,
	--选择外貌
	--自定义外貌
	AvatarFace = {},
	--创建日
	MonthIndex = 0,
	DayIndex = 0,
	--保护神
	GodID = 0,
	--选择职业
	ProfID = 0,
	--设置昵称
	RoleName = "",
	--历史数据
	HistoryRecordList = {},
	--理发屋的一级页签  头发/妆容
	HairCutSubMenu = "头发",
	--理发屋的二级页签 1/2/3/4/5/6……
	HairCutSubMenuSelect = 1,
	--理发屋的色板切换情况
	HairCutColorIsLeft = true,
}

function LoginReConnectMgr:OnInit()
end

function LoginReConnectMgr:OnBegin()
end

function LoginReConnectMgr:OnEnd()
end

function LoginReConnectMgr:OnShutdown()
end

function LoginReConnectMgr:Reset()
end

function LoginReConnectMgr:HaveNotFinishCreate()
    self.SavePath = string.format("%s/GameData/LoginReconnect_%s.txt", _G.FDIR_SAVED_RELATIVE(), _G.LoginMgr:GetOpenID())
    local SaveData = CommonUtil.LoadJsonFile(self.SavePath)
    if not SaveData or SaveData.CurPhase and SaveData.CurPhase < 1 then
        return false
    end

	self.SaveData = SaveData
    return true
end

function LoginReConnectMgr:ExitCreateRole()
	self.SaveData = {}
	
	_G.UE.USaveMgr.SetInt(SaveKey.MajorBornRoleID, 0, false)
    CommonUtil.DeleteFile(self.SavePath)
end

function LoginReConnectMgr:SaveValue(Key, Value, bNotSaveToFile)
	if _G.LoginMapMgr.CurLoginMapType ~= _G.LoginMapType.Login and _G.LoginMapMgr.CurLoginMapType ~= _G.LoginMapType.HairCut then
		return
	end
	
	if Value == nil then
		FLOG_ERROR("LoginReConnectMgr:Save  Key:%s Value is nil", tostring(Key))
		return 
	end

	self.SaveData[Key] = Value
	if Key == "CurPhase" then
		local MaxDonePhase = self.SaveData.MaxDonePhase or 0
		if Value > MaxDonePhase then
			self.SaveData.MaxDonePhase = Value
		end
	end

	if not bNotSaveToFile then
		CommonUtil.SaveJsonFile(self.SavePath, self.SaveData)
	end
end

function LoginReConnectMgr:GetValue(Key)
	return self.SaveData[Key]
end

return LoginReConnectMgr