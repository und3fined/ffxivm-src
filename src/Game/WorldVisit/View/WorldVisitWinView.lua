--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-02-10 11:11:04
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-02-10 19:50:09
FilePath: \Script\Game\WorldVisit\View\WorldVisitWinView.lua
Description: 跨界确认弹窗
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LSTR = _G.LSTR
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")

---@class WorldVisitWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnOK CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgSeverState UFImage
---@field TextSever UFTextBlock
---@field TextSeverState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldVisitWinView = LuaClass(UIView, true)

function WorldVisitWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnOK = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgSeverState = nil
	--self.TextSever = nil
	--self.TextSeverState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldVisitWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOK)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldVisitWinView:OnInit()

end

function WorldVisitWinView:OnDestroy()

end

function WorldVisitWinView:OnShow()
	self.BtnOK:SetBtnName(LSTR(10033))
	self.BtnCancel:SetBtnName(LSTR(10034))
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(1530001))
	self.TextContent:SetText(LSTR(1530005))
	local Params = self.Params
	self.TextSever:SetText(Params.ServerTitle or "")
	self.TextTitle:SetText(string.format(LSTR(1530004), Params.ServerTitle or ""))
	for i = 1, #LoginNewDefine.ServerStateConfig do
        local ServerState = LoginNewDefine.ServerStateConfig[i]
        if ServerState.State == Params.State and not string.isnilorempty(ServerState.Icon) then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgSeverState, ServerState.Icon)
			self.TextSeverState:SetText(ServerState.Name)
			break
        end
    end
end

function WorldVisitWinView:OnHide()

end

function WorldVisitWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnClickOk)
end

function WorldVisitWinView:OnClickOk()
	if self.Params and self.Params.WorldID and self.Params.CrystalID then
		CrystalPortalMgr:SendCrossWorldTransReq(self.Params.WorldID, self.Params.CrystalID)
	end

	_G.UIViewMgr:HideView(_G.UIViewID.WorldVisitPanel)
	self:Hide()
end

function WorldVisitWinView:OnRegisterGameEvent()

end

function WorldVisitWinView:OnRegisterBinder()

end

return WorldVisitWinView