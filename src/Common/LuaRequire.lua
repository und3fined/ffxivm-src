--
-- Author: anypkvcai
-- Date: 2020-09-12 09:38:45
-- Description: 尽量通过require来访问 少用全局的table
--


require("UnLua")
local LuaRequire = {}

_G.LuaClass = require("Core/LuaClass")
_G.StringTools = require("Common/StringTools")

_G.CommonDefine = require("Define/CommonDefine")
_G.EventID = require("Define/EventID")
-- _G.GameMgrID = require("Define/GameMgrID")
_G.UIViewID = require("Define/UIViewID")

_G.GameTools = require("Common/GameTools")
_G.CommonUtil = require("Utils/CommonUtil")
_G.LocalizationUtil = require("Utils/LocalizationUtil")
_G.GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
_G.TimeUtil = require("Utils/TimeUtil")
_G.DBUtil = require("Utils/DBUtil")
_G.UIUtil = require("Utils/UIUtil")
_G.MsgBoxUtil = require("Utils/MsgBoxUtil")
_G.MsgTipsUtil = require("Utils/MsgTipsUtil")
_G.AccountUtil = require("Utils/AccountUtil")
_G.EffectUtil = require("Utils/EffectUtil")

_G.TableTools = require("Common/TableTools")
_G.MathTools = require("Common/MathTools")

_G.DateTimeTools = require("Common/DateTimeTools")
-- _G.GameMgr = require("Common/GameMgr")

_G.CppCallLua = require("Common/CppCallLua")

_G.AutoTest = require("AutoTest")
_G.LifeMgrModule = require("Common/LifeMgrModule")

local Num, _ = require("U2pm/Define/GameMgrConfig")
local mgrName = nil
for i = 1, Num do
	if math.fmod(i, 5) == 1 then
		mgrName = GameMgrConfig[i]
	end

	if math.fmod(i, 5) == 4 then
		local path = GameMgrConfig[i]
		-- FLOG_INFO("mgrpath: %s, name:%s", path, mgrName)
		local mgr = require(path)
		_G[mgrName] = mgr
		mgr:StaticConstructor()
		mgr:SetName(mgrName)
	end
end

return LuaRequire