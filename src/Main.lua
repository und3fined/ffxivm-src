--
-- Author: anypkvcai
-- Date: 2020-08-06 10:38:10
-- Description:
--



require("Common/LuaRequire")
require("LuaDebug")

_G.Main =
{

}

---OnInit
function Main.OnInit()
    FLOG_INFO("Main.OnInit")
end

---OnBegin
function Main.OnBegin()
    FLOG_INFO("Main.OnBegin")
        
    local LocDBMgr = require("DB/LocDBMgr")
    LocDBMgr.Init()
    local DBMgr = require("DB/DBMgr")
    DBMgr.Init()
    local MajorUtil = require("Utils/MajorUtil")
    MajorUtil.Init()
    local ActorUtil = require("Utils/ActorUtil")
    ActorUtil.Init()
    local CppCallLua = require("Common/CppCallLua")
    CppCallLua.Init()

    collectgarbage("incremental", 120)
end

---EndMgr
function Main.OnEnd()
    FLOG_INFO("Main.OnEnd")
end

---Shutdown
function Main.OnShutdown()
    FLOG_INFO("Main.OnShutdown")
end