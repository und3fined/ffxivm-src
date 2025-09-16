--
-- Author: MichaelYang_LightPaw
-- Date: 2022-09-19 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local CardsRuleDetaiItemVM = require("Game/Cards/VM/CardsRuleDetaiItemVM")
local LSTR = _G.LSTR

---@class CardsChallengeRuleVM : UIViewModel
local CardsChallengeRuleVM = LuaClass(UIViewModel)

---Ctor
function CardsChallengeRuleVM:Ctor()

end

function CardsChallengeRuleVM:RefreshData()
    local GameInfo = MagicCardMgr.NpcGameInfo

    -- 规则详情相关
    self.PopularRuleTable = self.GenRuleVM(GameInfo.PopularRules)
    self.CurrentRuleTable = self.GenRuleVM(GameInfo.PlayRules)
    -- 规则详情结束
end

function CardsChallengeRuleVM.GenRuleVM(Rules)
    local RuleNameAndDescList = MagicCardVMUtils.GetRuleNameAndDescList(MagicCardVMUtils.GetRuleConfigListSorted(Rules))
    local _result = {}
    local NormalRuleColor = {
        R = 0.783,
        G = 0.289,
        B = 0.11,
        A = 1
    }
    local NoRuleColor = {
        R = 0.783,
        G = 0.783,
        B = 0.783,
        A = 1
    }
    if #RuleNameAndDescList == 0 then
        _result[1] = CardsRuleDetaiItemVM.New()
        _result[1]:SetTitleAndContent(LSTR(LocalDef.UKeyConfig.None), nil, NoRuleColor, NormalRuleColor)

    else
        local _index = 1
        for _, Rule in ipairs(RuleNameAndDescList) do
            _result[_index] = CardsRuleDetaiItemVM.New()
            _result[_index]:SetTitleAndContent(Rule.Name, Rule.Desc, NoRuleColor, NormalRuleColor)
            _index = _index + 1
        end
    end

    return _result
end

-- 要返回当前类
return CardsChallengeRuleVM
