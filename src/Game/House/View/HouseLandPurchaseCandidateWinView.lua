--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-09-29 11:08:59
FilePath: \Script\Game\House\View\HouseLandPurchaseCandidateWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: muyanli
--- DateTime: 2025-05-30 20:51
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HouseLandPurchaseCandidateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Text UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseCandidateWinView = LuaClass(UIView, true)

function HouseLandPurchaseCandidateWinView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Comm2FrameM_UIBP = nil
    -- self.Text = nil
    -- self.TextNumber = nil
    -- self.TextTime = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseCandidateWinView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Comm2FrameM_UIBP)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseCandidateWinView:OnInit()

end

function HouseLandPurchaseCandidateWinView:OnDestroy()

end

function HouseLandPurchaseCandidateWinView:OnShow()
    if nil == self.Params then
        return
    end
    self.Comm2FrameM_UIBP:SetTitleText(HouseLocalDef.LocalTxtStr.SelectSuc)
	self.Comm2FrameM_UIBP.Btn1:SetButtonText(HouseLocalDef.LocalTxtStr.BtnSure)
    self.Text:SetText(HouseLocalDef.LocalTxtStr.SelectSucTips)
    self.TextNumber:SetText(self.Params.ApplyNumber)
    local TimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M", self.Params.ShowTime)
    local PhaseTimeStr = string.format(HouseLocalDef.LocalTxtStr.SelectResultTimeStr, TimeStr)
    self.TextTime:SetText(PhaseTimeStr)
end

function HouseLandPurchaseCandidateWinView:OnHide()

end

function HouseLandPurchaseCandidateWinView:OnRegisterUIEvent()
 UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Btn1, self.OnClickedBtnSure)
end

function HouseLandPurchaseCandidateWinView:OnRegisterGameEvent()

end

function HouseLandPurchaseCandidateWinView:OnRegisterBinder()

end

function HouseLandPurchaseCandidateWinView:OnClickedBtnSure()
	self:Hide()
end

return HouseLandPurchaseCandidateWinView
