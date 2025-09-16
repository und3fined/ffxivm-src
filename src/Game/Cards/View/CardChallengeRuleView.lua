---
--- Author: Administrator
--- DateTime: 2023-11-14 09:46
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CardsChallengeRuleVM = require("Game/Cards/VM/CardsChallengeRuleVM")
local MagicCardMgr = nil ---@class MagicCardMgr

---@class CardChallengeRuleView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field EnemyName UFTextBlock
---@field PanelReward UFCanvasPanel
---@field TableViewCurrentRules UTableView
---@field TableViewPopularRules UTableView
---@field TableViewReward UTableView
---@field Text01 UFTextBlock
---@field Text03 UFTextBlock
---@field Text06 UFTextBlock
---@field TextReward UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardChallengeRuleView = LuaClass(UIView, true)

function CardChallengeRuleView:Ctor()
    MagicCardMgr = _G.MagicCardMgr
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BG = nil
    -- self.PanelReward = nil
    -- self.TableViewReward = nil
    -- self.Text02 = nil
    -- self.Text04 = nil
    -- self.Text05 = nil
    -- self.Text07 = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.ViewModel = CardsChallengeRuleVM.New()
end

function CardChallengeRuleView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BG)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardChallengeRuleView:OnInit()
    self.TableViewPopularRuleAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPopularRules, nil, true)
    self.TableViewCurrentRuleAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCurrentRules, nil, true)
    self.ViewModel:RefreshData()
    local Binders = {
        {
            "PopularRuleTable",
            UIBinderUpdateBindableList.New(self, self.TableViewPopularRuleAdapter)
        },
        {
            "CurrentRuleTable",
            UIBinderUpdateBindableList.New(self, self.TableViewCurrentRuleAdapter)
        }
    }
    self.Binders = Binders
    UIUtil.SetIsVisible(self.PanelReward, false)
    self.OpponentName = ""
end

function CardChallengeRuleView:OnDestroy()

end

function CardChallengeRuleView:OnShow()
    self:SetLSTR()
    local OpponentInfo = MagicCardMgr:GetOpponentInfo()
    if OpponentInfo ~= nil then
        self.OpponentName = OpponentInfo.Name
    end
    self.EnemyName:SetText(self.OpponentName)
end

function CardChallengeRuleView:SetLSTR()
	self.BG:SetTitleText(_G.LSTR(1130033))--1130033("幻卡挑战规则")
	self.Text01:SetText(_G.LSTR(1130034))--1130034("对手")
	self.Text03:SetText(_G.LSTR(1130035))--1130035("流行规则")
	self.Text06:SetText(_G.LSTR(1130036))--1130036("对局规则")
	self.TextReward:SetText(_G.LSTR(1130037))--1130037("报酬")
end

function CardChallengeRuleView:OnHide()

end

function CardChallengeRuleView:OnRegisterUIEvent()

end

function CardChallengeRuleView:OnRegisterGameEvent()

end

function CardChallengeRuleView:OnRegisterBinder()
    self.ViewModel:RefreshData()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardChallengeRuleView
