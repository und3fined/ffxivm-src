---
--- Author: qibaoyiyi
--- DateTime: 2023-03-17 11:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LSTR = _G.LSTR
---@class ArmyRuleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field TableViewRule UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRuleWinView = LuaClass(UIView, true)

function ArmyRuleWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.TableViewRule = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRuleWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRuleWinView:OnInit()
	self.TabsViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRule)
end

function ArmyRuleWinView:OnDestroy()
end

function ArmyRuleWinView:OnShow()
    -- LSTR string:部队规则提示
    self.BG:SetTitleText(LSTR(910320))
	local RuleList = {
        {
            -- LSTR string:转让部队条件
            Tips = LSTR(910237),

        },
		{
            -- LSTR string:解散部队条件
            Tips = LSTR(910218),
        }
    }
    self.TabsViewAdapter:UpdateAll(RuleList)
end

function ArmyRuleWinView:OnHide()
end

function ArmyRuleWinView:OnRegisterUIEvent()
end

function ArmyRuleWinView:OnRegisterGameEvent()
end

function ArmyRuleWinView:OnRegisterBinder()
end

return ArmyRuleWinView
