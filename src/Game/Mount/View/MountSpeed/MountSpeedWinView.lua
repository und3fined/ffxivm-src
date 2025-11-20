---
--- Author: janezli
--- DateTime: 2024-10-11 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MountSpeedWinVM = require("Game/Mount/VM/MountSpeedWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MountSpeedWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Focus4 UFCanvasPanel
---@field EFF_Focus5 UFCanvasPanel
---@field EFF_Focus6 UFCanvasPanel
---@field ImgGearFocus1 UFImage
---@field ImgGearFocus2 UFImage
---@field ImgGearFocus3 UFImage
---@field ImgGearFocus4 UFImage
---@field ImgGearFocus5 UFImage
---@field ImgGearFocus6 UFImage
---@field ImgMount UFImage
---@field PanelGear2 UFCanvasPanel
---@field PanelGear3 UFCanvasPanel
---@field PanelGear5 UFCanvasPanel
---@field PanelGear6 UFCanvasPanel
---@field TextCity UFTextBlock
---@field TextGear1 UFTextBlock
---@field TextGear2 UFTextBlock
---@field ThroughFrame CommonThroughFrameSView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSpeedWinView = LuaClass(UIView, true)

local LSTR = _G.LSTR

function MountSpeedWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Focus4 = nil
	--self.EFF_Focus5 = nil
	--self.EFF_Focus6 = nil
	--self.ImgGearFocus1 = nil
	--self.ImgGearFocus2 = nil
	--self.ImgGearFocus3 = nil
	--self.ImgGearFocus4 = nil
	--self.ImgGearFocus5 = nil
	--self.ImgGearFocus6 = nil
	--self.ImgMount = nil
	--self.PanelGear2 = nil
	--self.PanelGear3 = nil
	--self.PanelGear5 = nil
	--self.PanelGear6 = nil
	--self.TextCity = nil
	--self.TextGear1 = nil
	--self.TextGear2 = nil
	--self.ThroughFrame = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSpeedWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ThroughFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSpeedWinView:OnInit()
	self.ViewModel = MountSpeedWinVM.New()
end

function MountSpeedWinView:OnDestroy()

end

function MountSpeedWinView:OnShow()
	self.ThroughFrame.TextTitle:SetText(LSTR(200003))
	--self.ThroughFrame.TextCloseTips:SetText(LSTR(200013))
	-- 这里位置是反的 好反人类
	self.ThroughFrame.BtnCheck2:SetText(LSTR(200018))
	self.ThroughFrame.BtnClose2:SetText(LSTR(200019))
	local Params = self.Params 
    if Params == nil then
        return
    end
	self.MapID = Params.MapID
	self.RegionID = Params.RegionID
	self.ViewModel:UpdateContent(Params)
	self:PlayAnimation(self.AnimIn)
end

function MountSpeedWinView:OnHide()

end

function MountSpeedWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ThroughFrame.BtnClose2, self.OnClickedShowMountSpeed)
	UIUtil.AddOnClickedEvent(self, self.ThroughFrame.BtnCheck2, self.OnClickedClose)
end

function MountSpeedWinView:OnRegisterGameEvent()

end

function MountSpeedWinView:OnRegisterBinder()
	local Binders = {
		{ "TextCity", UIBinderSetText.New(self, self.TextCity) },
		{ "TextGear1", UIBinderSetText.New(self, self.TextGear1) },
		{ "TextGear2", UIBinderSetText.New(self, self.TextGear2) },
		{ "ImgGearFocus1Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus1) },
		{ "ImgGearFocus2Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus2) },
		{ "ImgGearFocus4Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus4) },
		{ "ImgGearFocus5Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus5) },
		{ "ImgGearFocus6Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus6) },
		--{ "EFF_Focus1Visible", UIBinderSetIsVisible.New(self, self.EFF_Focus1) },
		--{ "EFF_Focus2Visible", UIBinderSetIsVisible.New(self, self.EFF_Focus2) },
		{ "EFF_Focus4Visible", UIBinderSetIsVisible.New(self, self.EFF_Focus4) },
		{ "EFF_Focus5Visible", UIBinderSetIsVisible.New(self, self.EFF_Focus5) },
		{ "EFF_Focus6Visible", UIBinderSetIsVisible.New(self, self.EFF_Focus6) },
		{ "PanelGear2Visible", UIBinderSetIsVisible.New(self, self.PanelGear2) },
		{ "PanelGear3Visible", UIBinderSetIsVisible.New(self, self.PanelGear3) },
		{ "PanelGear5Visible", UIBinderSetIsVisible.New(self, self.PanelGear5) },
		{ "PanelGear6Visible", UIBinderSetIsVisible.New(self, self.PanelGear6) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MountSpeedWinView:OnClickedShowMountSpeed()
	UIViewMgr:HideView(UIViewID.MountSpeedWinPanel)
	local Params = {}
	Params.RegionID = self.RegionID
	Params.MapID = self.MapID
	UIViewMgr:ShowView(UIViewID.MountSpeedPanel,Params)
end

function MountSpeedWinView:OnClickedClose()
	UIViewMgr:HideView(UIViewID.MountSpeedWinPanel)
end

return MountSpeedWinView