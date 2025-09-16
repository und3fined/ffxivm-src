--
-- Author: ZhengJanChuan
-- Date: 2025-03-04 16:45
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local WardrobeTipsListItem2VM  = require("Game/Wardrobe/VM/Item/WardrobeTipsListItem2VM")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local MajorUtil = require("Utils/MajorUtil")


---@class WardrobeTipsItem2VM : UIViewModel
local WardrobeTipsItem2VM = LuaClass(UIViewModel)

---Ctor
function WardrobeTipsItem2VM:Ctor()
    self.ProfAppList = UIBindableList.New(WardrobeTipsListItem2VM)   
end

function WardrobeTipsItem2VM:OnInit()
end

function WardrobeTipsItem2VM:OnBegin()
end

function WardrobeTipsItem2VM:OnEnd()
end

function WardrobeTipsItem2VM:OnShutdown()
end

function WardrobeTipsItem2VM:UpdateProfAppList()
	--Todo 优化性能
    local ItemList = {}
	local bUpdate = true
    for index = 10, #(WardrobeDefine.FilterProfList) do
		local Name = nil
        local v = WardrobeDefine.FilterProfList[index]
		local ClassType = v.ClassType
		local ProfID = v.ProfID
		local IsVersionOpen = true
		local AdvancedProfID = 0
		local Cfg = RoleInitCfg:FindCfgByKey(v.ProfID)
		if Cfg ~= nil then
			local ProfLevel = MajorUtil.GetMajorLevelByProf(ProfID)
        	if v.ClassType == WardrobeDefine.ProfClass.BasicType then
				IsVersionOpen = Cfg ~= nil and Cfg.IsVersionOpen == 1
				Name = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v.ProfID)
			elseif v.ClassType == WardrobeDefine.ProfClass.AdvanceType then
				IsVersionOpen = Cfg ~= nil and Cfg.IsVersionOpen == 1
				AdvancedProfID = Cfg.AdvancedProf
				ProfLevel = MajorUtil.GetMajorLevelByProf(Cfg.AdvancedProf)
				Name = string.format("%s/%s", ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v.ProfID), ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, Cfg.AdvancedProf))
			end

			local bActive = ProfLevel ~= nil

			-- 没有激活基职，但有特职，也加入
			if Cfg.AdvancedProf ~= nil and not bActive then
				bActive = MajorUtil.GetMajorLevelByProf(ProfID) ~= nil
			end

			if Name ~= nil and IsVersionOpen and bActive then
				local TotalNum = WardrobeMgr:GetAppearanceCollectTotalNum(ProfID)
				local Num = WardrobeMgr:GetUnlockAppearanceCollectNum(ProfID, false)
				bUpdate = false
				local Item = {ID = index, Index = #ItemList + 1, ProfName = Name, ClassType = ClassType, ProfID = ProfID, AdvancedProfID = AdvancedProfID,  Num = Num, TotalNum = TotalNum}
				table.insert(ItemList, Item)
			end
		end
	end

	-- 自定义排序规则
	table.sort(ItemList, function(a, b)
	    if a.ProfID == b.ProfID then
	        -- 当ProfID相同时，按Num降序排列（数值大的在前）
	        return a.Num > b.Num
	    else
	        -- 主排序按ProfID升序排列（数值小的在前）
	        return a.ProfID < b.ProfID
	    end
	end)


	self.ProfAppList:UpdateByValues(ItemList)
end


--要返回当前类
return WardrobeTipsItem2VM