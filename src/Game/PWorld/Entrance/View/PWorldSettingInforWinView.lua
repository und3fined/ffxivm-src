---
--- Author: v_hggzhang
--- DateTime: 2023-06-01 11:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PWorldSettingInforWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field RichTextBoxDesc URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldSettingInforWinView = LuaClass(UIView, true)

function PWorldSettingInforWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.RichTextBoxDesc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldSettingInforWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldSettingInforWinView:OnInit()

end

function PWorldSettingInforWinView:OnDestroy()

end

function PWorldSettingInforWinView:OnShow()
	local Text = [[副本设置说明

	※只有队长进行设定才会生效。
	
	一、常规
	·不符合人数要求参加任务，系统将会帮你匹配合适队友。
	·符合人数要求参加任务，可以以任何职业构成参与，且不会受到装备平均品级限制。
	·将装备品级和角色等级同步到任务的最高要求。
	※设限特职只有在以规定人数组队状态下才能进入。
	
	二、挑战
	·可以以不足规定人数的队伍参加任务。
	·可以以任何职业构成参与，且不会受到装备品级限制。
	·将装备品级和角色等级同步到任务的最低要求。
	·不获得可在任务中获得的超越之力。
	※只能在允许开启挑战模式的副本使用。
	
	三、解除限制
	·可以以不足规定人数的队伍参加任务。
	·可以以任何职业构成参与，且不会受到装备品级限制。
	·不进行等级同步，不进行装备品级同步。
	·打倒怪物之后将不会获得经验值和报酬。
	※只能在允许开启解除限制模式的副本使用。]]
	self.RichTextBoxDesc:SetText(Text)
end

function PWorldSettingInforWinView:OnHide()

end

function PWorldSettingInforWinView:OnRegisterUIEvent()

end

function PWorldSettingInforWinView:OnRegisterGameEvent()

end

function PWorldSettingInforWinView:OnRegisterBinder()

end

return PWorldSettingInforWinView