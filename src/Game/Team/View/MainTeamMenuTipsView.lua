--[[
Author: anypkvcai
Date: 2020-11-16 19:46:25
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-20 15:08:14
FilePath: \Script\Game\Team\View\MainTeamMenuTipsView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local MainTeamMenuTipsView = LuaClass(UIView, true)

function MainTeamMenuTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommPopupBG = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainTeamMenuTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPopupBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainTeamMenuTipsView:OnInit()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function MainTeamMenuTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.RoleID = Params.RoleID

	for i, v in ipairs(Params.Items) do
		v.ShowLine = i < #Params.Items
	end

	self.AdapterTableView:UpdateAll(Params.Items)

	UIUtil.CanvasSlotSetPosition(self, Params.Pos)

	-- UIUtil.AdjustTipsPosition(self.Root, ItemView, Params.Offset)
end

function MainTeamMenuTipsView:OnHide()
	_G.EventMgr:SendEvent(EventID.TeamMemberShowSelect)
end

function MainTeamMenuTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamUpdateMember, function()
		self:Hide()
	end)

	self:RegisterGameEvent(EventID.TeamCaptainChanged, function()
		self:Hide()
	end)
end

return MainTeamMenuTipsView