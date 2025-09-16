local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

local ProfUtil = require("Game/Profession/ProfUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local ProfessionRangeItemVM = require("Game/Profession/VM/ProfessionRangeItemVM")
local ProfessionLevelItemVM = require("Game/Profession/VM/ProfessionLevelItemVM")

---@class ProfessionToggleJobVM : UIViewModel
local ProfessionToggleJobVM = LuaClass(UIViewModel)

---Ctor
function ProfessionToggleJobVM:Ctor()
	self.RangeItemVMList = nil
	self.LeftRangeItemVMList = nil
	self.RightRangeItemVMList = nil
	self.ProfSpecialization = ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
end

---@param ProfDetailList Table map<int32, ProfData>
function ProfessionToggleJobVM:UpdateProfList(ProfDetailList)
	if nil == ProfDetailList then
		return
	end

	if nil ~= self.RangeItemVMList and nil ~= next(self.RangeItemVMList) then
		--判断active数量和原本数量是否相同，不相同说明有转职
		if self:CheckNeedGenProfList(ProfDetailList) then
			self:UpdateCurrentProfList(ProfDetailList)
		else
			self:GenerateNewProfList(ProfDetailList)
		end
	else
		self:GenerateNewProfList(ProfDetailList)
	end
end

function ProfessionToggleJobVM:CheckNeedGenProfList(ProfDetailList)
	local ProfTable = {}
	for k, v in pairs(self.RangeItemVMList) do
		for _, LevelItemVM in pairs(v.LevelItemVMList) do
			if LevelItemVM.bIsActive then
				table.insert(ProfTable, LevelItemVM.ProfID)
			end
		end
	end
	local isHaveAllProf = true
	for key, value in pairs(ProfDetailList) do
		local isHaveProf = false
		for _, activeID in pairs(ProfTable) do
			if value.ProfID == activeID then
				isHaveProf = true
			end
		end
		if not isHaveProf then
			isHaveAllProf = false
		end
	end
	--全部拥有说明不需要更新列表
	return isHaveAllProf
end

function ProfessionToggleJobVM:UpdateCurrentProfList(ProfDetailList)
    local MaxLevel = LevelExpCfg:GetMaxLevel()

	for _, RangeItemVM in pairs(self.RangeItemVMList) do
		for _, LevelItemVM in pairs(RangeItemVM.LevelItemVMList) do
			local ProfData = ProfDetailList[LevelItemVM.ProfID]
			LevelItemVM:SetActive(nil ~= ProfData)
			local PreviewProfID = _G.EquipmentMgr:GetPreviewProfID()
				if PreviewProfID and PreviewProfID ~= 0 then
					LevelItemVM.bIsCurProf = LevelItemVM.ProfID == _G.EquipmentMgr:GetPreviewProfID()
				else
					LevelItemVM.bIsCurProf = LevelItemVM.ProfID == MajorUtil.GetMajorProfID()
				end
			if LevelItemVM.bIsCurProf then
				local Level = 0
				if LevelItemVM.ProfID ~= MajorUtil.GetMajorProfID() then
					Level = ProfData and ProfData.Level or 0
				else
					Level = MajorUtil.GetMajorLevel()
				end
				LevelItemVM:SetLevel(Level)
				self.SelectedLevelItemVM = LevelItemVM
			else
				LevelItemVM:SetLevel(ProfData and ProfData.Level or 0)
			end
			if LevelItemVM.Level < MaxLevel then
				local LevelExpData = LevelExpCfg:FindCfgByKey(LevelItemVM.Level)
				local NextExp = LevelExpData and LevelExpData.NextExp or 0
				if NextExp == 0 then
					LevelItemVM.ExpProgress = LevelItemVM.bActive and 1.0 or 0.0
				else
					LevelItemVM.ExpProgress = ProfData and ProfData.Exp / NextExp or 0
				end
			else
				-- 等级溢出
				LevelItemVM.ExpProgress = 1.0
			end
			LevelItemVM.ProfIcon = _G.EquipmentMgr:GetProfLevelItemIcon(LevelItemVM.ProfID)
		end
	end
end
--role quest finishall 151163
function ProfessionToggleJobVM:GenerateNewProfList(ProfDetailList)
	-- local StartTime = _G.TimeUtil.GetLocalTimeMS()
	local SortedProfData = ProfMgr.GenProfTypeSortData(ProfDetailList, self.ProfSpecialization)
	-- print("Prof data get time: "..tostring(_G.TimeUtil.GetLocalTimeMS() - StartTime)) 开销大头
	-- StartTime = _G.TimeUtil.GetLocalTimeMS()

    local RangeItemVMList = {}
    local MaxLevel = LevelExpCfg:GetMaxLevel()
    for _, SectionData in ipairs(SortedProfData) do
        if nil ~= SectionData.lst and #SectionData.lst > 0 then
            -- 添加title
            local RangeItemVM = ProfessionRangeItemVM.New()
            RangeItemVM.Title = SectionData.Title
            RangeItemVM.IconPath = SectionData.IconPath
			RangeItemVM.BgPath = ProfUtil.GetProfClassColorBgPath(SectionData.ProfClass)

            -- 添加item
			local LevelItemVMList = {}
            for _, ItemData in ipairs(SectionData.lst) do
                local LevelItemVM = ProfessionLevelItemVM.New()
				LevelItemVM:SetActive(ItemData.bActive or false)
                LevelItemVM.ProfID = ItemData.Prof
				local ProfData = ProfDetailList[LevelItemVM.ProfID]
				local PreviewProfID = _G.EquipmentMgr:GetPreviewProfID()
				if PreviewProfID and PreviewProfID ~= 0 then
					LevelItemVM.bIsCurProf = ItemData.Prof == _G.EquipmentMgr:GetPreviewProfID()
				else
					LevelItemVM.bIsCurProf = ItemData.Prof == MajorUtil.GetMajorProfID()
				end
				if LevelItemVM.bIsCurProf then
					local Level = 0
					if LevelItemVM.ProfID ~= MajorUtil.GetMajorProfID() then
						Level = ProfData and ProfData.Level or 0
					else
						Level = MajorUtil.GetMajorLevel()
					end
					LevelItemVM:SetLevel(Level)
					self.SelectedLevelItemVM = LevelItemVM
				else
                	LevelItemVM:SetLevel(ItemData.Data and ItemData.Data.Level or 0)
				end
                if LevelItemVM.Level < MaxLevel then
                    local LevelExpData = LevelExpCfg:FindCfgByKey(LevelItemVM.Level)
                    local NextExp = LevelExpData and LevelExpData.NextExp or 0
                    if NextExp == 0 then
                        LevelItemVM.ExpProgress = ItemData.bActive and 1.0 or 0.0
                    else
                        LevelItemVM.ExpProgress = ItemData.Data and ItemData.Data.Exp / NextExp or 0
                    end
                else
                    -- 等级溢出
                    LevelItemVM.ExpProgress = 1.0
                end
				local ProfLevel = RoleInitCfg:FindProfLevel(ItemData.Prof)
				local ProfCfg = RoleInitCfg:FindProfForPAdvance(ItemData.Prof)
				local ProfType = RoleInitCfg:FindProfSpecialization(ItemData.Prof)
				LevelItemVM.ProfIcon = _G.EquipmentMgr:GetProfLevelItemIcon(ItemData.Prof)
				if ProfType == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
					table.insert(LevelItemVMList, LevelItemVM)
				else
					if ProfLevel > 0 and not ItemData.bActive and ProfCfg then
						--未解锁的有基职的特职不显示
					elseif ItemData.AdvancedProf ~= 0 and EquipmentVM.lstProfDetail[ItemData.AdvancedProf] ~= nil then
						--解锁特职的基职不显示
					else
						table.insert(LevelItemVMList, LevelItemVM)
					end
				end
            end
			RangeItemVM.LevelItemVMList = LevelItemVMList
			table.insert(RangeItemVMList, RangeItemVM)
        end
    end
	self.RangeItemVMList = RangeItemVMList

	-- print("VM generation time: "..tostring(_G.TimeUtil.GetLocalTimeMS() - StartTime))
	-- StartTime = _G.TimeUtil.GetLocalTimeMS()
	-- 瀑布流式布局
	local LeftRangeItemVMList = {}
	local RightRangeItemVMList = {}
	local LeftLevelItemCount = 0
	local RightLevelItemCount = 0
	for _, RangeItemVM in ipairs(RangeItemVMList) do
		if LeftLevelItemCount == 0 then
			table.insert(LeftRangeItemVMList, RangeItemVM)
			LeftLevelItemCount = #RangeItemVM.LevelItemVMList
		else
			table.insert(RightRangeItemVMList, RangeItemVM)
			RightLevelItemCount = RightLevelItemCount + #RangeItemVM.LevelItemVMList
			if RightLevelItemCount >= LeftLevelItemCount then
				LeftLevelItemCount = 0
				RightLevelItemCount = 0
			end
		end
	end
	self.LeftRangeItemVMList = LeftRangeItemVMList
	self.RightRangeItemVMList = RightRangeItemVMList

	-- print("VM update generation time: "..tostring(_G.TimeUtil.GetLocalTimeMS() - StartTime))
end

return ProfessionToggleJobVM