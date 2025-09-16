--[[
Author: hugo_lightpaw
Date: 2025-03-10 11:54:25
FilePath: \Script\Game\PWorld\Entrance\ItemVM\PWorldEntPVPVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AEo
--]]
local LuaClass = require("Core/LuaClass")
local PWorldEntTypeVM = require("Game/PWorld/Entrance/ItemVM/PWorldEntTypeVM")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local PWorldEntPVPVM = LuaClass(PWorldEntTypeVM)

local PWorldMatchMgr = _G.PWorldMatchMgr

function PWorldEntPVPVM:UpdMatch()
	local EntSet = {}
	local IsMatching = false
	if PWorldEntUtil.IsCrystalline(self.TypeID) then
		local ExercisePWorld = SceneEnterTypeCfg:GetPWorldEntIDs(ProtoCommon.ScenePoolType.ScenePoolPVPCrystal)
		local RankPWorld = SceneEnterTypeCfg:GetPWorldEntIDs(ProtoCommon.ScenePoolType.ScenePoolPVPCrystalRank)
		local CustomPWorld = SceneEnterTypeCfg:GetPWorldEntIDs(ProtoCommon.ScenePoolType.ScenePoolPVPCrystalCustom)
		EntSet = table.merge_table(EntSet, ExercisePWorld)
		EntSet = table.merge_table(EntSet, RankPWorld)
		EntSet = table.merge_table(EntSet, CustomPWorld)
		local CrystallineMatches = PWorldMatchMgr:GetCrystallineItems()
		IsMatching = table.set_has_overlap(EntSet, CrystallineMatches)
	elseif PWorldEntUtil.IsFrontline(self.TypeID) then
		EntSet = SceneEnterTypeCfg:GetPWorldEntIDs(self.TypeID)
		local FrontlineMatches = PWorldMatchMgr:GetFrontlineItems()
		IsMatching = table.set_has_overlap(EntSet, FrontlineMatches)
	end
	self.IsMatching = IsMatching
	self:UpdateStatus()
end

function PWorldEntPVPVM:UpdateStatus()
	self.bShowStatus = self.IsMatching or (not self.IsUnlock)
	if self.IsMatching then
		self.StatusImage = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061517_png.UI_Icon_061517_png'"
		self.StatusText = _G.LSTR(1320008)
	elseif not self.IsUnlock then
		self.StatusImage = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Go_png.UI_Icon_Hud_Plus_Go_png'"
		self.StatusText = _G.LSTR(1320088)
	end
end

return PWorldEntPVPVM