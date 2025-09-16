--
-- Author: liwenjian
-- Date: 2024-09-23
-- Description: 自动测试功能扩展（只适应于测试环境）
--

local LoginVM = require("Game/Login/LoginVM")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local LoginMgr = require("Game/Login/LoginMgr")
local USaveMgr = _G.UE.USaveMgr
local SaveKey = require("Define/SaveKey")

local AutoTestExt = {}

function AutoTestExt.InitAutoTest()
end

function AutoTestExt.Login(OpenID,WorldID)
	local AuthType = 0
	local Channel = 0
	local Token = ""
	local Expire = 0
	local AppID = "10000"
	LoginMgr.OpenID = OpenID
	LoginMgr.WorldID = WorldID

	--[sammrli] 登录使用多地址随机策略
	local URL = LoginMgr:GetServerUrl()

	GameNetworkMgr:Connect(URL, AuthType, AppID, Channel, OpenID, Token, Expire)

	_G.NetworkImplMgr:StartWaiting()

	USaveMgr.SetString(SaveKey.LastLoginOpenID, OpenID, false)
	USaveMgr.SetInt(SaveKey.LastLoginWorldID, WorldID, false)
end

function AutoTestExt.PreGM()
	-- 激活全部宠物||升到50级||解锁所有战斗职业||解锁所有生产职业||解锁系统
	local CmdList="zone companion activateall||zone level set 50||role prof active all||role prof active produce||lua _G.ModuleOpenMgr:OnModuleStateChange()";
	_G.GMMgr:ReqGM0(CmdList)
end

function AutoTestExt.SkipNewGuidePlayer()
	if _G.QuestMgr.EndChapterMap[14028] then
		_G.GMMgr:ReqGM("scene enter 1001005")
	else
		_G.GMMgr:ReqGM("role quest dochapter 14028")
	end
end

return AutoTestExt
