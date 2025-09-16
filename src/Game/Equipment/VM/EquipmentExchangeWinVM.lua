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

---@class EquipmentExchangeWinVM : UIViewModel
local EquipmentExchangeWinVM = LuaClass(UIViewModel)

---Ctor
function EquipmentExchangeWinVM:Ctor()
	self.SpeedLevel = 1
	self.TabList = {}
	self.TotalSelectNum = 0
	self.TotalExchangeNum = 0
end


return EquipmentExchangeWinVM