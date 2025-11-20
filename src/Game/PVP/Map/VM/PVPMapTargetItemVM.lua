
--
-- Author: peterxie
-- Date:
-- Description: PVP地图可选目标
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapDefine = require("Game/Map/MapDefine")


---@class PVPMapTargetItemVM : UIViewModel
---@field MemberVM TeamMemberVM
local PVPMapTargetItemVM = LuaClass(UIViewModel)

function PVPMapTargetItemVM:Ctor()
	self.ID = 0 -- 玩家RoleID 或者 怪物ResID
	self.MemberVM = nil -- 玩家队伍成员VM
	self.IsPlayer = true -- 是否是玩家，否则是水晶
	self.IsColosseumCrystal = false -- 是否是PVP地图水晶bnpc
	self.IconBgPath = nil -- 职业图标背景

	self.IsInVision = true -- 敌方成员是否在我方队伍视野内，非主角视野
	self.RenderOpacity = 1

	self.IsSelected = false -- 是否选中
	self.TipsContent = "" -- 提示内容
end

function PVPMapTargetItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end

function PVPMapTargetItemVM:UpdateVM(Value, Params)
	self.ID = Value.ID
	self.IsPlayer = Value.IsPlayer
	self.IsColosseumCrystal = Value.IsColosseumCrystal

	if self.IsPlayer then
		self.MemberVM = Value.MemberVM

		-- 队伍成员所属红蓝方
		local bIsMyTeam = _G.PVPColosseumMgr:IsMyTeamByCampID(self.MemberVM.CampID)
		if bIsMyTeam then
			self.IconBgPath = MapDefine.MapIconConfigs.PVPPlayerBlueBg
		else
			self.IconBgPath = MapDefine.MapIconConfigs.PVPPlayerRedBg
		end
	end
end

function PVPMapTargetItemVM:UpdateRenderOpacity()
	if not self.IsPlayer then
		return
	end

	if self.MemberVM:IsMajorRole() then
		return
	end

	self.IsInVision = _G.PVPTeamMgr:IsInVisionByRoleID(self.MemberVM.RoleID)
	self.RenderOpacity = self.IsInVision and 1 or 0.6
end

function PVPMapTargetItemVM:SetIsSelected(IsSelected)
	self.IsSelected = IsSelected
end

function PVPMapTargetItemVM:SetTipsContent(Text)
	self.TipsContent = Text
end

return PVPMapTargetItemVM