local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class MusicPerformanceMemberItemVM : UIViewModel
local MusicPerformanceMemberItemVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceMemberItemVM:Ctor()
	self.Name = ""
	self.Level = ""
	self.RoleID = ""
	self.IsMajor = nil
	
	self.ImgBgNormalConfirmVisible = false
	self.ImgBgSelfConfirmVisible = false
	self.ImgBgSelfVisible = false
	self.ImgLeaderVisible = false
	self.ImgReadyVisible = false
	self.ImgCancelVisible = false

	self.ConfirmStatus = MPDefines.ConfirmStatus.ConfirmStatusNone
end

function MusicPerformanceMemberItemVM:OnInit()
end

function MusicPerformanceMemberItemVM:OnBegin()
end

function MusicPerformanceMemberItemVM:OnEnd()
end

function MusicPerformanceMemberItemVM:OnShutdown()
end

return MusicPerformanceMemberItemVM