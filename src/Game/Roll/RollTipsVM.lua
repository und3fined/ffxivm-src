---
--- Author: v_zanchang
--- DateTime: 2021-04-06 14:24
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
-- local ActorMgr = require("Game/Actor/ActorMgr")
local BagMgr = require("Game/Bag/BagMgr")
local ItemVM = require("Game/Item/ItemVM")
local ItemCfg = require("TableCfg/ItemCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
-- local ItemDefine = require("Game/Item/ItemDefine")
-- local ItemTipsUtil = require("Utils/ItemTipsUtil")

local EquipmentMgr = _G.EquipmentMgr
local FLOG_WARNING = _G.FLOG_WARNING

---@class RollTipsVM : UIViewModel
local RollTipsVM = LuaClass(UIViewModel)

---Ctor
---@field BindableListMember UIBindableList
---@field JoinRedDotVisible boolean
---@field FunctionBarVisible boolean
---@field TextVoice string
function RollTipsVM:Ctor()
    self.AwardList = UIBindableList.New(ItemVM) --奖励物列

	self.TeamID = 2              -- 当前队伍ID
	self.IsOperated = nil

	self.IsBind = false
	self.IsUnique = false
	self.Icon = ""
	self.EquipName = ""
	self.EquipType = 0
	self.ItemLevel = 0
	self.ProfNameTitle = _G.LSTR("品级")
	self.ProfName = ""
	self.ProfSimpleIcon = ""
	self.GradeTitle = _G.LSTR("等级")
	self.Grade = 0
end

function RollTipsVM:OnInit()
	--self:SetMajorInfo()
    --品级
    -- ItemCfg.ItemLevel
    -- --等级
    -- ItemCfg.Grade
    ---职业类型限制ProfLimit[0]
end

function RollTipsVM:UpdateVM(Value)
	if true then
		return --临时废弃
	end
	self.Item = Value
	self.ResID = Value.ResID
	self.Num = Value.Num
	--self.IsNew = Value.IsNew
	local ValueAwardID = Value.AwardID
	local ValueResID = Value.ResID
	if ValueAwardID ~= nil then
		self.AwardID = ValueAwardID
		self.ExpireTime = Value.ExpireTime
	end
	local Cfg = ItemCfg:FindCfgByKey(ValueResID)
	if nil == Cfg then
		FLOG_WARNING("ItemVM:UpdateVM can't find item cfg, ResID=%d", ValueResID)
		return
	end
	self.EquipName = ItemCfg:GetItemName(ValueResID)
	self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
	self.IsUnique = Cfg.IsUnique > 0
	-- self.IsBind = Cfg.IsBind > 0
	self.EquipType = ItemTypeCfg:GetTypeName(Cfg.ItemType)

	local GradeDiffValue = BagMgr:CalculateItemGradeDiffValueAndEquipPart(self.ResID)
	local RichTextL1 = '<span color="#00FD2BFF">'
	local RichTextL2 = '<span color="#FFFF0000">'
	local RichTextR = '</>'
	if GradeDiffValue > 0 then
		self.ItemLevel = string.format("%s%s%s%s%s%s%s", Cfg.ItemLevel, "  (  ", RichTextL1, "+", GradeDiffValue, RichTextR, "  )")
	elseif GradeDiffValue == 0 then
		self.ItemLevel = Cfg.ItemLevel
	else
		self.ItemLevel = string.format("%s%s%s%s%s%s", Cfg.ItemLevel, "  (  ", RichTextL2, GradeDiffValue, RichTextR, "  )")
	end
	
	-- if #ItemCfg.ProfLimit > 0 then
	-- 	lstEquipmentAttrItemVM[1].RightText = EquipmentMgr:GetProfName(ItemCfg.ProfLimit[1])
	-- 	lstEquipmentAttrItemVM[1].RightIcon = RoleInitCfg:FindRoleInitProfIconSimple(ItemCfg.ProfLimit[1])
	-- else
	-- 	lstEquipmentAttrItemVM[1].RightText = EquipmentMgr:GetProfClassName(ItemCfg.ClassLimit)
	-- 	lstEquipmentAttrItemVM[1].RightIcon = nil
	-- end

	-- local RoleDetail = ActorMgr:GetMajorRoleDetail()
	-- local ProfList = RoleDetail.Prof.ProfList
	local CfgProfLimit = Cfg.ProfLimit
	if #CfgProfLimit > 0 then
		local ProfInfo = RoleInitCfg:FindCfgByKey(CfgProfLimit[1])
		self.ProfName = ProfInfo.ProfName
		self.ProfSimpleIcon = ProfInfo.SimpleIcon
	else
		self.ProfName = EquipmentMgr:GetProfClassName(Cfg.ClassLimit)
		self.ProfSimpleIcon = nil
	end
	self.Grade = Cfg.Grade
	self.Grade = string.format("%s%s", tostring(self.Grade), "级以上")
end

function RollTipsVM:OnBegin()
end

function RollTipsVM:OnEnd()
end

function RollTipsVM:OnShutdown()
end

return RollTipsVM