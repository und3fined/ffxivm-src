--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local Log = require("Game/MagicCard/Module/Log")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

---@class CardsPrepareMainPanelVM : UIViewModel
local CardsPrepareMainPanelVM = LuaClass(UIViewModel)

---Ctor
function CardsPrepareMainPanelVM:Ctor()
	-- self.LocalString = nil
	-- self.TextColor = nil
	-- self.ProfID = nil
	-- self.GenderID = nil
	-- self.IsVisible = nil
	local LeftTablIconList = {} -- 左边的Icon list
	local _tempPath1 = "/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Tab_Decks02_png.UI_Cards_Icon_Tab_Decks02_png"
	table.insert(LeftTablIconList, {IconPath = _tempPath1})
	local _tempPath2 = "/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Tab_EmoAc02_png.UI_Cards_Icon_Tab_EmoAc02_png"
	table.insert(LeftTablIconList, {IconPath = _tempPath2})
	self.LeftTablIconList = LeftTablIconList
	self.LeftTabSelectIndex = 1
end

function CardsPrepareMainPanelVM:SetLeftTabSelectIndex(IndexValue)
	self.LeftTabSelectIndex = IndexValue
end

--- func desc
---@param TargetVM CardsSingleCardVM
function CardsPrepareMainPanelVM:CanCardClick(TargetVM)
	return false
end

--要返回当前类
return CardsPrepareMainPanelVM