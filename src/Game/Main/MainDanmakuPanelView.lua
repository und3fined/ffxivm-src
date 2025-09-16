---
--- Author: xingcaicao
--- DateTime: 2025-04-03 11:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DanmakuVM = require("Game/Danmaku/DanmakuVM")

---@class MainDanmakuPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AreaPanel UFCanvasPanel
---@field RichText1 URichTextBox
---@field RichText2 URichTextBox
---@field RichText3 URichTextBox
---@field RichText4 URichTextBox
---@field RichText5 URichTextBox
---@field RichText6 URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainDanmakuPanelView = LuaClass(UIView, true)

function MainDanmakuPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AreaPanel = nil
	--self.RichText1 = nil
	--self.RichText2 = nil
	--self.RichText3 = nil
	--self.RichText4 = nil
	--self.RichText5 = nil
	--self.RichText6 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainDanmakuPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainDanmakuPanelView:OnInit()
	
end

function MainDanmakuPanelView:OnDestroy()
	DanmakuVM:Reset()
end

function MainDanmakuPanelView:OnShow()
    DanmakuVM:UpdateMoveSpeed()

	self:TryInit()

	self:RegisterTimer(self.OnTimer, 0.2, 0, 0)
end

function MainDanmakuPanelView:OnHide()

end

function MainDanmakuPanelView:OnRegisterUIEvent()

end

function MainDanmakuPanelView:OnRegisterGameEvent()

end

function MainDanmakuPanelView:OnRegisterBinder()

end

function MainDanmakuPanelView:TryInit()
	if self.IsInited then
		return
	end

    local LineConfig = {
        {
            PosY = UIUtil.CanvasSlotGetPosition(self.RichText1).Y,
            Controls = {"RichText1", "RichText2", "RichText3"},
            LastUsedIndex = 0  -- 轮询记录
        },
        {
            PosY = UIUtil.CanvasSlotGetPosition(self.RichText6).Y,
            Controls = {"RichText4", "RichText5", "RichText6"},
            LastUsedIndex = 0
        }
    }

	-- 初始化控件状态
	local AreaSize = UIUtil.GetWidgetSize(self.AreaPanel) or {}
	self.IsInited =DanmakuVM:InitControlsStatus(self, LineConfig, AreaSize.X)
end

function MainDanmakuPanelView:OnTimer(_, ElapsedTime)
	DanmakuVM:Tick()
end

return MainDanmakuPanelView