local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local DialogueUtil = require("Utils/DialogueUtil")
local SaveKey = require("Define/SaveKey")
local CommonUtil = require("Utils/CommonUtil")
local StoryDefine = require("Game/Story/StoryDefine")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local USaveMgr = _G.UE.USaveMgr

---@class EquipmentSwitchWinVM : UIViewModel
local EquipmentSwitchWinVM = LuaClass(UIViewModel)

---Ctor
function EquipmentSwitchWinVM:Ctor()
	self.Title = _G.LSTR(1050029)
	self.TabList = {}
end


return EquipmentSwitchWinVM