--
-- Author: loiafeng
-- Date: 2023-03-28 14:50
-- Description: 在线状态设置界面选项VM
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")

local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify 

---@class OnlineStatusSettingsItemVM : UIViewModel
---@field ID number 设置项ID
---@field StatusID number 状态ID
---@field IdentityID number 身份ID
---@field StatusName sting 状态名称
---@field StatusIcon sting 状态图标
local OnlineStatusSettingsItemVM = LuaClass(UIViewModel)

---Ctor
function OnlineStatusSettingsItemVM:Ctor()
    self.ID = nil
	self.StatusID = nil
    self.IdentityID = nil
    self.Name = nil
    self.Icon = nil
    self.IsSelected = false
end

---@param Value SetCfg
function OnlineStatusSettingsItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function OnlineStatusSettingsItemVM:AdapterOnGetCanBeSelected()
    local IsBeSelected = ( self.IdentityID ~= OnlineStatusIdentify.OnlineStatusIdentifyUnverifiedMentor
     and self.IdentityID ~= OnlineStatusIdentify.OnlineStatusIdentifyUnverifiedBattleMentor
     and self.IdentityID ~= OnlineStatusIdentify.OnlineStatusIdentifyUnverifiedMakeMentor )
    return IsBeSelected
end

function OnlineStatusSettingsItemVM:UpdateVM(ItemCfg)
	self.ID = ItemCfg.ID
	self.StatusID = ItemCfg.StatusID
    self.IdentityID = ItemCfg.Identity
    self.Name = ItemCfg.Name
    self.Icon = ItemCfg.Icon
end

function OnlineStatusSettingsItemVM:SetIsSelected(IsSelected)
	self.IsSelected = IsSelected
end

return OnlineStatusSettingsItemVM