--
-- Author: anypkvcai
-- Date: 2020-08-10 15:28:25
-- Description: 和Cpp的GameTools功能对应 其他函数不要在此文件添加
--

local PathMgr = require("Path/PathMgr")
local LogMgr = require("Log/LogMgr")
local DBMgr = require("DB/DBMgr")

---@class GameTools
local GameTools = {

}

--路径相关
_G.FDIR_PERSISTENT = PathMgr.PersistentDir
_G.FDIR_PERSISTENT_RELATIVE = PathMgr.PersistentDirRelative
_G.FDIR_CONTENT = PathMgr.ContentDir
_G.FDIR_CONTENT_RELATIVE = PathMgr.ContentDirRelative
_G.FDIR_LOG = PathMgr.LogDir
_G.FDIR_LOG_RELATIVE = PathMgr.LogDir
_G.FDIR_SAVED = PathMgr.SavedDir
_G.FDIR_SAVED_RELATIVE = PathMgr.SavedDirRelative
_G.FDIR_PAK = PathMgr.PakDir
_G.FDIR_PAK_RELATIVE = PathMgr.PakDirRelative
_G.FDIR_EXISTFILE = PathMgr.ExistFile

--DB相关
_G.FDB_GETROW = DBMgr.GetOneRow
_G.FDB_GETROWBYINDEX = DBMgr.GetOneRowByIndex
_G.FDB_GETCOLUMNTYPE = DBMgr.GetColumnType
_G.FDB_GETCOLUMNTYPEBYINDEX = DBMgr.GetColumnTypeByIndex
_G.FDB_GETROWS = DBMgr.GetMultiRow
_G.FDB_GETCOUNT = DBMgr.GetCount
_G.FDB_MOVETO = DBMgr.MoveTo
_G.FDB_NEXT = DBMgr.Next
_G.FDB_RESET = DBMgr.Reset
_G.FDB_DESTROY = DBMgr.Destroy
_G.FDB_GETINT32 = DBMgr.GetInt32
_G.FDB_GETINT64 = DBMgr.GetInt64
_G.FDB_GETFLOAT = DBMgr.GetFloat
_G.FDB_GETSTRING = DBMgr.GetString

--ping Value
_G.PING_SHOW = 0

function FWORLD()
    return _G.UE.UFGameInstance.Get():GetWorld()
end

return GameTools