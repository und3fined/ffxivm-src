local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BuddyMgr = require("Game/Buddy/BuddyMgr")
local BuddySkillLevelCfg = require("TableCfg/BuddySkillLevelCfg")
local BuddySkillCfg = require("TableCfg/BuddySkillCfg")
local UIBindableList = require("UI/UIBindableList")
local BuddySkillItemVM = require("Game/Buddy/VM/BuddySkillItemVM")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")

---@class BuddyAbilityPageVM : UIViewModel
local BuddyAbilityPageVM = LuaClass(UIViewModel)

BuddyAbilityPageVM.TabType = {DefenceSkill = BuddyMgr.SkillType.DefenceSkill, HealthSkill = BuddyMgr.SkillType.HealthSkill, AttackSkill = BuddyMgr.SkillType.AttackSkill}

---Ctor
function BuddyAbilityPageVM:Ctor()
    self.ReadyBrokenVisible = nil
    self.ExpText = nil
    self.ExpProgressPercent = nil
    self.SkillLevelText = nil

    self.BuffImg = nil
    self.BuffImgVisible = nil

    self.SkillPointText = nil
    self.CostSkillPointText = nil
    self.StudyBtnEnable = nil

    self.SkillVMList = UIBindableList.New(BuddySkillItemVM)

    self.TabIndex = nil
    self.CurLearnID = nil
    self.NameText = nil
    self.StudyBtnVisible = nil

    self.BuffNodeVisible = nil
	self.LeaveNodeVisible = nil
end

function BuddyAbilityPageVM:UpdateVM()
    if BuddyMgr.QueryInfo ~= nil then
        self.NameText = BuddyMgr:GetBuddyName()

        local BuddyLevelExp = BuddyMgr.QueryInfo.LevelExp
        
        if BuddyMgr:IsMaxLevel() then
			self.SkillLevelText = string.format(_G.LSTR(1000030), BuddyLevelExp.Level)
            self.ExpText = ""
            self.ReadyBrokenVisible = false
            self.ExpProgressPercent = 1
        else
            self.SkillLevelText = string.format(_G.LSTR(1000031), BuddyLevelExp.Level)
            local SkillLevelCfg = BuddySkillLevelCfg:FindCfgByKey(BuddyLevelExp.Level)
            local NextLevelCfg = BuddySkillLevelCfg:FindCfgByKey(BuddyLevelExp.Level + 1)
            local LastLevelCfg = BuddySkillLevelCfg:FindCfgByKey(BuddyLevelExp.Level - 1)
            if SkillLevelCfg ~= nil then
                local CurExp = BuddyLevelExp.Exp
                local MaxExp = SkillLevelCfg.Exp
                if LastLevelCfg ~= nil then
                    CurExp = CurExp - LastLevelCfg.Exp
                    MaxExp = MaxExp - LastLevelCfg.Exp
                end

                self.ReadyBrokenVisible = false
                self.ExpText = string.format("%d/%d", CurExp, MaxExp)
                if MaxExp == 0 then
                    self.ExpProgressPercent = 1
                else
                    self.ExpProgressPercent = CurExp / MaxExp
                end
   
                if NextLevelCfg ~= nil and NextLevelCfg.NeedBreak == 1 and CurExp == MaxExp then
                    self.ReadyBrokenVisible = true
                    self.ExpText = ""
                end
            else
                self.ExpText = ""
                self.ReadyBrokenVisible = false
                self.ExpProgressPercent = 0
            end
        end

       self.SkillPointText = string.format(_G.LSTR(1000032), BuddyLevelExp.Unassigned)
    end

    self:UpdateBuddyActivity()
    self:UpdateBuddyState()
    self:SetTabsSelectionIndex(self.TabIndex or 1)
end

function BuddyAbilityPageVM:UpdateBuddyState()
    self.BuffImgVisible = false
    if BuddyMgr:IsBuddyOuting() == false then
		self.BuffNodeVisible = false
		self.LeaveNodeVisible = false
		return
	end

	local State = BuddyMgr:GetBuddyBuff()
	if State == nil then
		return
	end

	local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(State)
    if StateShowCfg ~= nil then
		self.BuffImgVisible = true
        self.BuffImg = StateShowCfg.EffectIcon
    end
end

function BuddyAbilityPageVM:UpdateBuddyActivity()
    local BuddyActivity = BuddyMgr:CanBuddyActivity()

    self.BuffNodeVisible = BuddyActivity
	self.LeaveNodeVisible = not BuddyActivity and BuddyMgr:IsBuddyOuting()
end


function BuddyAbilityPageVM:SetTabsSelectionIndex(Index)
    self.TabIndex = Index
    if BuddyMgr.QueryInfo ~= nil then
        local BuddyAbility = BuddyMgr.QueryInfo.Ability
        if Index == BuddyAbilityPageVM.TabType.DefenceSkill then
            self.CurTabSkillLevelText = string.format(_G.LSTR(1000033), BuddyAbility.DefenceSkill and #BuddyAbility.DefenceSkill or 0)
        elseif Index == BuddyAbilityPageVM.TabType.HealthSkill then
            self.CurTabSkillLevelText = string.format(_G.LSTR(1000034), BuddyAbility.HealthSkill and #BuddyAbility.HealthSkill or 0)
        elseif Index == BuddyAbilityPageVM.TabType.AttackSkill  then
            self.CurTabSkillLevelText = string.format(_G.LSTR(1000035), BuddyAbility.AttackSkill and #BuddyAbility.AttackSkill or 0)
        end

        local CfgSearchCond = string.format("Type == %d", Index)
	    self.SkillVMList:UpdateByValues(BuddySkillCfg:FindAllCfg(CfgSearchCond))

        self:SetDefaultSelected()
    end
    
end

function BuddyAbilityPageVM:SetDefaultSelected()
    self.CurLearnID = nil
    self.StudyBtnVisible = false
    self.CostSkillPointText = ""
    for i = 1, self.SkillVMList:Length() do
		local SkillListVM = self.SkillVMList:Get(i)
        if SkillListVM.EFFVisible == true then
            SkillListVM.SelectImgVisible = true
            self.CurLearnID = SkillListVM.ID
			self.StudyBtnEnable = SkillListVM:BoolCanStudy()
            if SkillListVM:IsLearned() then
                self.StudyBtnVisible = false
                self.CostSkillPointText = ""
            else
                self.StudyBtnVisible = true
                local SkillCost = SkillListVM:GetCostSkillCost()
                if SkillCost > BuddyMgr:GetSkillUnassigned() then
                    self.CostSkillPointText = string.format(_G.LSTR(1000036), SkillCost)
                else
                    self.CostSkillPointText = string.format(_G.LSTR(1000037), SkillCost)
                end
                
            end
        else
            SkillListVM.SelectImgVisible = false
        end
	end
end


function BuddyAbilityPageVM:SelectedSkillItem(ID)
    self.CurLearnID = ID
    self.StudyBtnVisible = ID ~= nil
	for i = 1, self.SkillVMList:Length() do
		local SkillListVM = self.SkillVMList:Get(i)
		SkillListVM:UpdateIconState(ID)
		if ID == SkillListVM.ID then
            if SkillListVM:IsLearned() then
                self.StudyBtnVisible = false
                self.CostSkillPointText = ""
            else
                self.StudyBtnVisible = true
                local SkillCost = SkillListVM:GetCostSkillCost()
                if SkillCost > BuddyMgr:GetSkillUnassigned() then
                    self.CostSkillPointText = string.format(_G.LSTR(1000036), SkillCost)
                else
                    self.CostSkillPointText = string.format(_G.LSTR(1000037), SkillCost)
                end
            end
			self.StudyBtnEnable = SkillListVM:BoolCanStudy()
            
		end
	end
end


--要返回当前类
return BuddyAbilityPageVM