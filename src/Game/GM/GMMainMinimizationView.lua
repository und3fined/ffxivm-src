---
--- Author: v_zanchang
--- DateTime: 2022-4-29 19:18:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


---@class GMMainMinimizationView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMaxText UFTextBlock
---@field BtnSendText UFTextBlock
---@field ButtonClearLine UFButton
---@field ClearText UTextBlock
---@field DragText UFTextBlock
---@field GMText UGMInputTextBox_C
---@field Image01 UImage
---@field Image_32 UImage
---@field InputText CommInputBoxView
---@field Maximize UFButton
---@field SendCommand UFButton
---@field DragOffset Vector2D
---@field DragedWidget UserWidget
---@field DragCall mcdelegate
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMMainMinimizationView = LuaClass(UIView, true)

function GMMainMinimizationView:Ctor()
        --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMaxText = nil
	--self.BtnSendText = nil
	--self.ButtonClearLine = nil
	--self.ClearText = nil
	--self.DragText = nil
	--self.GMText = nil
	--self.Image01 = nil
	--self.Image_32 = nil
	--self.InputText = nil
	--self.Maximize = nil
	--self.SendCommand = nil
	--self.DragOffset = nil
	--self.DragedWidget = nil
	--self.DragCall = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

end

function GMMainMinimizationView:OnRegisterSubView()
        --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InputText)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMMainMinimizationView:OnInit()

end

function GMMainMinimizationView:OnClickedMaxminizationShowCalled(cmd)
        self.InputText:SetText(cmd)
end

function GMMainMinimizationView:OnDestroy()

end

function GMMainMinimizationView:OnShow()
        self.InputText:SetIsHideNumber(true)
        UIUtil.SetIsVisible(self.GMText, false)
        self.DragText:SetText(_G.LSTR(1440003))  --拖拽
        self.BtnSendText:SetText(_G.LSTR(1440013))  --发送
        self.ClearText:SetText(_G.LSTR(1440014)) --X
        self.BtnMaxText:SetText(_G.LSTR(1440015)) --最大化
end

function GMMainMinimizationView:OnHide()

end

function GMMainMinimizationView:OnRegisterUIEvent()
        UIUtil.AddOnClickedEvent(self, self.SendCommand, self.SendCommandHandle)
        UIUtil.AddOnClickedEvent(self, self.ButtonClearLine, self.ButtonClearLineHandle)
        UIUtil.AddOnClickedEvent(self, self.Maximize, self.MaximizeHandle)
end

-- 点击发送指令
function GMMainMinimizationView:SendCommandHandle()
        local reqText = tostring(self.InputText:GetText())
        self:ReqGM(reqText)
end

-- 清空指令搜索框
function GMMainMinimizationView:ButtonClearLineHandle()
        self.InputText:SetText("")
end

-- 最大化GM界面
function GMMainMinimizationView:MaximizeHandle()
        _G.UIViewMgr:ShowView(_G.UIViewID.GMMain)
        _G.UIViewMgr:HideView(_G.UIViewID.GMMainMinimizationHud)
end

-- GMMain输入指令值改变执行
function GMMainMinimizationView:OnCommandalueChangedCallback(Command)
        self.InputText:SetText(Command)
end

function GMMainMinimizationView:OnRegisterGameEvent()
        self:RegisterGameEvent(_G.EventID.MinimizationUIShow, self.OnClickedMaxminizationShowCalled)
end

function GMMainMinimizationView:OnRegisterBinder()

end



-- 发送指令到服务器
function GMMainMinimizationView:ReqGM(CmdList)
    _G.GMMgr:ReqGM0(CmdList)
end

return GMMainMinimizationView