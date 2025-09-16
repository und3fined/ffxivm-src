local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local BuddyDetailAttriItemVM = require("Game/Buddy/VM/BuddyDetailAttriItemVM")
local BuddySkillCfg = require("TableCfg/BuddySkillCfg")
local SkillTagCfg = require("TableCfg/SkillTagCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local BuddySkillTypeItemVM = require("Game/Buddy/VM/BuddySkillTypeItemVM")

local LSTR = _G.LSTR
---@class BuddySkillDetailTipsVM : UIViewModel
local BuddySkillDetailTipsVM = LuaClass(UIViewModel)

---Ctor
function BuddySkillDetailTipsVM:Ctor()
	self.NameText = nil
	self.DescText = nil
	self.AttriVMList = UIBindableList.New(BuddyDetailAttriItemVM)
    self.SkillTypeVMList = UIBindableList.New(BuddySkillTypeItemVM)
end


function BuddySkillDetailTipsVM:UpdateVM(SkillID)
	local Cfg = BuddySkillCfg:FindCfgByKey(SkillID)
    if Cfg then
        self.NameText = Cfg.Name
        -- local TagType = Cfg.SkillType
    

	    self.DescText = Cfg.Desc

        local AttriList = {}
        table.insert(AttriList, {Attri = LSTR(1000027), Value = Cfg.Power})
        table.insert(AttriList, {Attri = LSTR(1000028), Value = Cfg.Duration})
        table.insert(AttriList, {Attri = LSTR(1000029), Value = Cfg.AdditionalEffects})

        self.AttriVMList :UpdateByValues(AttriList)

        local TagText = {}
        local IconPath = {}
        local SkillTypeList = {}
        for index, value in ipairs(Cfg.SkillType) do
            TagText[index] = ProtoEnumAlias.GetAlias(ProtoRes.ESkillTagType, value) or ""
            IconPath[index] = SkillTagCfg:FindValue(value, "BgImgPath") or ""
            table.insert(SkillTypeList, {TagText = TagText[index], IconPath = IconPath[index]})
        end

        self.SkillTypeVMList :UpdateByValues(SkillTypeList)
    end
end

--要返回当前类
return BuddySkillDetailTipsVM