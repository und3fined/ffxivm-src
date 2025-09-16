--
-- Author: ds_yangyumian
-- Date: 2024-06-3 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local ProtoCS = require("Protocol/ProtoCS")
local CompanyType = ProtoRes.grand_company_type
local LSTR = _G.LSTR
local ScoreMgr = _G.ScoreMgr
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS



---@class CompanySealTextItemVM : UIViewModel
local CompanySealTextItemVM = LuaClass(UIViewModel)

---Ctor
function CompanySealTextItemVM:Ctor()
	self.Desc = nil
	self.RedDot2Visible = false
	self.IconUpVisible = nil
end

function CompanySealTextItemVM:OnInit()

end

function CompanySealTextItemVM:OnBegin()

end

function CompanySealTextItemVM:OnEnd()

end

---UpdateVM
---@param List table
function CompanySealTextItemVM:UpdateVM(List)
	if List.IsLeft then
		self.Desc = string.format("<span color=\"#D5D5D5\">%s</>", List.Desc)
		self.RedDot2Visible = false
		self.IconUpVisible = false
	else
		self:SetDescState(List)
	end
end

function CompanySealTextItemVM:SetDescState(List)
	self.RedDot2Visible = List.IsUnlock
	self.IconUpVisible = List.IsUp
	self.Desc = string.format("<span color=\"#FFF4D0\">%s</>", List.Desc)
end


return CompanySealTextItemVM