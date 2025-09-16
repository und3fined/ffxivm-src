local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local StoryDefine = require("Game/Story/StoryDefine")
local NPCDefine = require("Game/Npc/NpcDefine")

---@class NpcDialogGMPanelVM : UIViewModel
local NpcDialogGMPanelVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR

function NpcDialogGMPanelVM:Ctor()
    self.bIsDebugging = false
	self.ViewType = StoryDefine.UIType.NpcDialog
	self.DialogTargetType = NPCDefine.DialogTargetType.DialogNPC
	self.TextTitle = LSTR(1520001)
	self.TextCamType = LSTR(1520002)
	self.TextDialogTarget = LSTR(1520003)
	self.TextPlayerEID = LSTR(1520004)
	self.TextNPCEID = LSTR(1520005)
	self.TextCamDistance = LSTR(1520006)
	self.TextCamRotation = LSTR(1520007)
	self.TextCamOffset = LSTR(1520008)
	self.TextFOV = LSTR(1520009)
	self.TextViewID = LSTR(1520010)
	self.TextDebugging = LSTR(1520014)
	self.TextPitch = LSTR(1520015)
	self.TextYaw = LSTR(1520016)
	self.TextRoll = LSTR(1520017)
	self.TextOffsetX = LSTR(1520018)
	self.TextOffsetY = LSTR(1520019)
	self.TextOffsetZ = LSTR(1520020)
end

return NpcDialogGMPanelVM