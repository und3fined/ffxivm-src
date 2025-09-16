--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-30 19:27:40
FilePath: \Script\Game\PWorld\Entrance\ItemVM\PWorldEntTypeVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AEo
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local PWorldEntTypeVM = LuaClass(UIViewModel)

function PWorldEntTypeVM:Ctor()
    self.TypeName = ""
	self.TypeID = 0
	self.TypeIcon = ""
	self.Type = 0
	self.IsMatching = false
	self.IsUnlock = true
	self.LockBG = ""
	self.UnlockBG = ""
	self.bShowStatus = false
	self.StatusImage = ""
	self.StatusText = ""
end

function PWorldEntTypeVM:UpdateVM(Data)
	self.TypeID = Data.ID
	local Cfg = SceneEnterTypeCfg:FindCfgByKey(Data.ID)
	if not Cfg then
		return
	end

	self.TypeName = Cfg.Name
	self.TypeIcon = Cfg.Icon
	self.UnlockBG = Cfg.BG
    self.Type = Cfg.Type
	self.FrameImage = Cfg.FrameImage or ""
	self.LockBG = Cfg.LockBG

	self:UpdMatch()
	self:UpdLock()

	self:UpdateStatus()
end

function PWorldEntTypeVM:UpdMatch()
	local EntSet = SceneEnterTypeCfg:GetPWorldEntIDs(self.TypeID)
	local Matches = _G.PWorldMatchMgr:GetMatchItems()
	local CrystallineMatches = _G.PWorldMatchMgr:GetCrystallineItems()
	local FrontlineMatches = _G.PWorldMatchMgr:GetFrontlineItems()
	local HasOverlap = table.set_has_overlap(EntSet, Matches) or
						table.set_has_overlap(EntSet, CrystallineMatches) or
						table.set_has_overlap(EntSet, FrontlineMatches)
	self.IsMatching = HasOverlap
	self:UpdateStatus()
end

function PWorldEntTypeVM:UpdLock()
	local EntSet = SceneEnterTypeCfg:GetPWorldEntIDs(self.TypeID)
	local Rlt = false
	for _, EntID in pairs(EntSet) do
		local Pol = PWorldEntUtil.GetPol(EntID, self.TypeID)
		local IsCheckOK = Pol and Pol:CheckFilter(EntID)
		Rlt = Rlt or IsCheckOK
		if Rlt then
			break
		end
	end

	self.IsUnlock = Rlt
	self:UpdateStatus()
end


function PWorldEntTypeVM:UpdateStatus()
	self.bShowStatus = self.IsMatching or (not self.IsUnlock)
	if self.IsMatching then
		self.StatusImage = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061517_png.UI_Icon_061517_png'"
		self.StatusText = _G.LSTR(1320008)
	elseif not self.IsUnlock then
		self.StatusImage = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Main_Go_png.UI_Icon_Hud_Main_Go_png'"
		self.StatusText = _G.LSTR(1320088)
	end
end

function PWorldEntTypeVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.TypeID
end

return PWorldEntTypeVM