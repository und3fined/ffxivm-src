---
--- Author: Star
--- DateTime: 2024-04-18 10:15
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")

---@class ArmySelectMainArmyPageVM : UIViewModel
---@field GrandCompanyName string @选中的国防联军的名字
---@field GrandCompanyDesc string @选中的国防联军的描述
---@field GrandCompanyID number @选中的国防联军的ID
local ArmySelectMainArmyPageVM = LuaClass(UIViewModel)

---Ctor
function ArmySelectMainArmyPageVM:Ctor()

end

function ArmySelectMainArmyPageVM:OnInit()
    --self.GrandCompanyName = ""
    self.GrandCompanyDesc = ""
    self.GrandCompanyID = nil
    self.FlagDataList = {}
    local AllCfg = GrandCompanyCfg:FindAllCfg()
	for _, Cfg in ipairs(AllCfg) do
		table.insert(self.FlagDataList, Cfg) 
	end
	self.SetBGCallbak = nil
	self.GrandLineIcon = nil
    --self:FlagSortRandomly()
end

---随机排序旗帜/打乱数据顺序
function ArmySelectMainArmyPageVM:FlagSortRandomly()
	local Length = #self.FlagDataList
	if Length > 0 then
		for i = 1, Length do
			local j = math.random(1, Length)
			local Temp = self.FlagDataList[i]
			self.FlagDataList[i] = self.FlagDataList[j]
			self.FlagDataList[j] = Temp
		end
	end
	--self.GrandCompanyID = self.FlagDataList[2].ID
end

function ArmySelectMainArmyPageVM:GetAllGrandCompanyData()
    return self.FlagDataList
end

function ArmySelectMainArmyPageVM:GetGrandCompanyDataByID(ID)
	for _, Data in pairs(self.FlagDataList) do
		if ID == Data.ID then
			return Data
		end
	end
end

function ArmySelectMainArmyPageVM:SetSelectedGrandCompanyID(ID)
    self.GrandCompanyID = ID
    self:SetShowData()
end

function ArmySelectMainArmyPageVM:SetShowData()
    local Data = self:GetGrandCompanyDataByID(self.GrandCompanyID)
    local ID = self.GrandCompanyID
    self.GrandCompanyDesc = Data.Desc
	local GrandData = table.find_by_predicate(ArmyDefine.UnitedArmyTabs, function(Data)
			return Data.ID == ID
	end)
	if GrandData then
		self.GrandLineIcon = GrandData.LineIcon
	end
end

function ArmySelectMainArmyPageVM:GetSelectedGrandCompanyID()
    return self.GrandCompanyID
end

function ArmySelectMainArmyPageVM:OnReset()

end

function ArmySelectMainArmyPageVM:OnBegin()
end

function ArmySelectMainArmyPageVM:OnEnd()
end

function ArmySelectMainArmyPageVM:OnShutdown()
    self.GrandCompanyID = nil
end

--- 设置数据
function ArmySelectMainArmyPageVM:SetData(GrandCompanyData)
    --self.GrandCompanyName = GrandCompanyData.Name
    self.GrandCompanyDesc = GrandCompanyData.Desc
end

function ArmySelectMainArmyPageVM:SetSetBGCallbak(SetBGCallbak)
	self.SetBGCallbak = SetBGCallbak
end

function ArmySelectMainArmyPageVM:SetIsPlayAnimReturn(IsPlayAnimReturn)
	self.IsPlayAnimReturn = IsPlayAnimReturn
end

function ArmySelectMainArmyPageVM:GetIsPlayAnimReturn()
	return self.IsPlayAnimReturn
end
return ArmySelectMainArmyPageVM
