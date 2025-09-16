--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description: 大卡片的显示VM
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class CardReadnessRewardItemVM : UIViewModel
local CardReadnessRewardItemVM = LuaClass(UIViewModel)

---Ctor
function CardReadnessRewardItemVM:Ctor()
	self.CardID = 0
end

---@param TargetValue int
function CardReadnessRewardItemVM:SetCardId(TargetValue)
	self.CardID = TargetValue
end

function CardReadnessRewardItemVM:SetCount(TargetValue)
	self.Count = TargetValue
end

function CardReadnessRewardItemVM:SetIconImage(TargetValue)
	self.IconImage = TargetValue
end

--- func desc
---@param TargetVM CardsSingleCardVM
function CardReadnessRewardItemVM:CanCardlick(TargetVM)
	return false
end

--要返回当前类
return CardReadnessRewardItemVM