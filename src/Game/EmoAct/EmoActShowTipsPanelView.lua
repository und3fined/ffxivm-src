---
--- Author: moodliu
--- DateTime: 2022-07-13 10:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class EmoActShowTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanvasMain UCanvasPanel
---@field EmoActShowTips_UIBP EmoActShowTipsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActShowTipsPanelView = LuaClass(UIView, true)

function EmoActShowTipsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CanvasMain = nil
	--self.EmoActShowTips_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActShowTipsPanelView:OnRegisterSubView()  --添加子视图
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EmoActShowTips_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActShowTipsPanelView:OnInit()
	self.MaxTipsCount = 5     --最多能显示UI的数量
	self.TipsViewList = {}    --UI的列表
end

function EmoActShowTipsPanelView:OnDestroy()

end

function EmoActShowTipsPanelView:OnShow()

end

function EmoActShowTipsPanelView:OnHide()

end

function EmoActShowTipsPanelView:OnRegisterUIEvent()

end

function EmoActShowTipsPanelView:OnRegisterGameEvent()

end

function EmoActShowTipsPanelView:OnRegisterBinder()

end

function EmoActShowTipsPanelView:OnRegisterTimer()  --计时器
	self.Super:OnRegisterTimer()
	local TickTime = self.Params.TickTime or 0.03
	self:RegisterTimer(self.Tick, 0, TickTime, 0)
end

function EmoActShowTipsPanelView:Tick()
	--print("EmoActShowTipsPanelView:Tick")
	local AllVisible = false
	for _, Tips in pairs(self.TipsViewList) do
		--print("Tick")
		if Tips and Tips:IsVisible()then  --如果UI存在且可视
			Tips:UpdatePos()              --将UI显示在人物头顶
			AllVisible = true
		end
	end
	if not AllVisible then                         --如果所有UI都不再显示
		_G.UIViewMgr:HideView(_G.UIViewID.EmotionShowTipsPanel)  --则设置隐藏
	end
end

--- 最多展示MaxTipsCount个Tips，将提示UI添加到画板
function EmoActShowTipsPanelView:ReqShowTips(InParams)
	local TargetID = InParams.TargetID
	if TargetID == 0 then
		TargetID = nil
	end
	local EmotionID = InParams.EmotionID
	---这里是获取数据表2中ID对应的文本信息内容（有、无目标）
	local EmotionDescPrefix, EmotionDesc = _G.EmotionMgr:GetEmotionDesc(TargetID, EmotionID)

	if #EmotionDesc == 0 then
		return
	end

	local Tips = nil

	-- 查找可用View
	for _, View in ipairs(self.TipsViewList) do
		if not View:IsVisible() then
			Tips = View
			break
		end
	end

	-- 数量较少时尝试创建View
	if Tips == nil then
		if #self.TipsViewList < self.MaxTipsCount then
			Tips = _G.UIViewMgr:CloneView(self.EmoActShowTips_UIBP, self, true, true, InParams)
			self.CanvasMain:AddChildToCanvas(Tips)   --画布画板控件：添加子项
			table.insert(self.TipsViewList, Tips)    --插入表数据
		end
	end

	if Tips then
		print("EmoActShowTipsPanelView:Tips")
		Tips:SetParams(InParams)
		UIUtil.SetIsVisible(Tips, true)   --设置可视性true
	else
		print("EmoActShowTipsPanelView:ReqShowTips Tips is too much")
	end
end

return EmoActShowTipsPanelView