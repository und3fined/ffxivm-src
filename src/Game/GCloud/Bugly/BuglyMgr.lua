--
-- Author: lipengzha
-- Date: 2021-04-07 14:47:07
-- Description:
--

-- local LuaClass = require("Core/LuaClass")
-- local MgrBase = require("Common/MgrBase")
-- local ProtoCS = require("Protocol/ProtoCS")
-- local RaceCfg = require("TableCfg/RaceCfg")
-- local MajorUtil = require("Utils/MajorUtil")

-- ---@class BuglyMgr : MgrBase
-- local BuglyMgr = LuaClass(MgrBase)


-- function BuglyMgr:OnInit()
--     print("buglymgr lua OnInit")
-- end

-- function BuglyMgr:OnBegin()
-- end

-- function BuglyMgr:OnEnd()
-- end

-- function BuglyMgr:OnShutdown()
--     -- GameNetworkMgr:UnRegisterMsg(self, CS_CMD.CS_CMD_QUERY_ROLELIST, self.OnNetMsgQueryRoleListByOpenIDRes)
--     -- GameNetworkMgr:UnRegisterMsg(self, CS_CMD.CS_CMD_REGISTER, self.OnNetMsgRegisterRoleRes)

-- end


-- function BuglyMgr:OnGameLogined()
--     --print("buglymgr on Game logined"..MajorUtil.GetMajorName())
--     FLOG_WARNING("buglymgr on Game logined")
--     FLOG_WARNING("buglymgr: LOGINED user name is %s",MajorUtil.GetMajorName())
--     FLOG_WARNING("buglymgr: AppVer %s",_G.UE.UVersionMgr.GetAppVersion())
--     FLOG_WARNING("buglymgr: SrcVer %s",_G.UE.UVersionMgr.GetResourceVersion())
--     _G.UE.UBuglyBlueprintLibrary.PutUserData("UserName",MajorUtil.GetMajorName())
--     _G.UE.UBuglyBlueprintLibrary.PutUserData("AppVer",_G.UE.UVersionMgr.GetAppVersion())
--     _G.UE.UBuglyBlueprintLibrary.PutUserData("SrcVer",_G.UE.UVersionMgr.GetResourceVersion())
-- end

-- function BuglyMgr:OnRegisterGameEvent()
--     local EventID = require("Define/EventID")
--     --print("bugly "..tostring(EventID.RoleLoginRes))
--     self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameLogined)
-- end

-- return BuglyMgr
