local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local MSDKDefine = require("Define/MSDKDefine")

local EventID = require("Define/EventID")
local LogableMgr = require("Common/LogableMgr")

local CS_CMD = ProtoCS.CS_CMD
local LSTR = _G.LSTR

---@class SDKMgr : LogableMgr
local SDKMgr = LuaClass(LogableMgr)

function SDKMgr:OnInit()
	self.MainPanel = nil
	self:SetLogName("SDKMgr")
end

function SDKMgr:OnBegin()
end

function SDKMgr:OnEnd()
end

function SDKMgr:OnShutdown()
end

function SDKMgr:OnRegisterNetMsg()
end

function SDKMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MSDKLoginRetNotify, self.OnGameEventLoginRetNotify)
	self:RegisterGameEvent(EventID.MSDKBaseRetNotify, self.OnGameEventBaseRetNotify)
	self:RegisterGameEvent(EventID.MSDKDeliverMessageNotify, self.OnGameEventMessageNotify)
	self:RegisterGameEvent(EventID.MSDKWebViewOptNotify, self.OnGameEventWebViewOptNotify)
end

function SDKMgr:OnGameEventLoginRetNotify(LoginRet)
	self:AppendToInfo("LoginRet = ", LoginRet, MSDKDefine.ClassMembers.LoginRetData)
end

function SDKMgr:OnGameEventBaseRetNotify(BaseRet)
	self:AppendToInfo("BaseRet = ", BaseRet, MSDKDefine.ClassMembers.BaseRet)
end

---@param BaseRet FAccountBaseRet
function SDKMgr:OnGameEventMessageNotify(BaseRet)
	-- print("SDKMgr:OnGameEventMessageNotify ", BaseRet.RetCode, BaseRet.MethodNameID)
	-- log anyway
	do
		self:LogInfo("SDKMgr:OnGameEventMessageNotify RetCode: %s ThirdCode %s MethodNameID: %s ExtraJson: %s", BaseRet.RetCode, BaseRet.ThirdCode, BaseRet.MethodNameID, BaseRet.ExtraJson)
	end
	self:AppendToInfo("BaseRet = ", BaseRet, MSDKDefine.ClassMembers.BaseRet)
end

function SDKMgr:OnGameEventFriendNotify(FriendRet)
	local FriendNames = {}
	for _, PersonInfo in pairs(FriendRet.FriendInfoList:ToTable()) do
		table.insert(FriendNames, PersonInfo.UserName)
	end
	self:AppendToInfo("FriendList = ", table.concat(FriendNames, ","))
end

function SDKMgr:OnGameEventWebViewOptNotify(WebViewRet)
	local MethodNameID = WebViewRet[MSDKDefine.ClassMembers.WebViewRet.MethodNameID]
	-- 不要调用CallJS
	--if MethodNameID == MSDKDefine.MethodName.kMethodNameWebViewJsCall or MethodNameID == MSDKDefine.MethodName.kMethodNameWebViewJsShare then
	--	_G.UE.UAccountMgr.Get():CallJS(WebViewRet:ToJson())
	--end
end

function SDKMgr:AppendToInfo(Prefix, Param, Members)
	self:AppendToLog(Prefix, Param, Members, "AppendInfo")
end

function SDKMgr:AppendToError(Prefix, Param, Members)
	self:AppendToLog(Prefix, Param, Members, "AppendError")
end

function SDKMgr:AppendToWarn(Prefix, Param, Members)
	self:AppendToLog(Prefix, Param, Members, "AppendWarn")
end

function SDKMgr:AppendInfo(Log)
	if self.MainPanel then
		self.MainPanel:AppendInfo(Log)
	end
end

function SDKMgr:AppendWarn(Log)
	if self.MainPanel then
		self.MainPanel:AppendWarn(Log)
	end
end

function SDKMgr:AppendError(Log)
	if self.MainPanel then
		self.MainPanel:AppendError(Log)
	end
end

-- 输出至Log
-- 当Members不为空时 会输出 Param[v in Members]
function SDKMgr:AppendToLog(Prefix, Param, Members, GMLogFuncName)
	local GMLogFunc = self[GMLogFuncName]
	if Members == nil then
		GMLogFunc(self, Param)
	else
		local LogInfos = {}
		for _, v in pairs(Members) do
			local Value = type(Param[v]) == "string" and (string.format("\"%s\"", Param[v])) or Param[v]
			table.insert(LogInfos, string.format("{%s = %s}", v, Value))
		end
		GMLogFunc(self, Prefix .. table.concat(LogInfos, ", "))
	end
end

function SDKMgr:GetGameMode()
	local SDKGameModeInst = require("Game/SDK/SDKGameMode").Get()
	return SDKGameModeInst
end

function SDKMgr:ShowMainPanel()
	self.MainPanel = _G.UIViewMgr:ShowView(_G.UIViewID.SDKMainPanel)
end

return SDKMgr