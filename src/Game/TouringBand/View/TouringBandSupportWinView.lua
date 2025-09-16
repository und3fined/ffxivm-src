---
--- Author: Administrator
--- DateTime: 2025-02-12 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class TouringBandSupportWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonThroughFrameS_UIBP CommonThroughFrameSView
---@field TableView_81 UTableView
---@field TextGet UFTextBlock
---@field TextGetBuff UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandSupportWinView = LuaClass(UIView, true)

function TouringBandSupportWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonThroughFrameS_UIBP = nil
	--self.TableView_81 = nil
	--self.TextGet = nil
	--self.TextGetBuff = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandSupportWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonThroughFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandSupportWinView:OnInit()
	self.BandBuffVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_81, nil, nil)
end

function TouringBandSupportWinView:OnDestroy()

end

function TouringBandSupportWinView:OnShow()
	self.CommonThroughFrameS_UIBP.TextTitle:SetText(_G.LSTR(450024))
	self.CommonThroughFrameS_UIBP.TextCloseTips:SetText(_G.LSTR(10056)) --("点击空白处关闭")
	self.TextGetBuff:SetText(_G.LSTR(450026))
end

function TouringBandSupportWinView:OnHide()
	_G.TouringBandMgr:TryOpenTouringBandStoryUnLockTips()
end

function TouringBandSupportWinView:OnRegisterUIEvent()

end

function TouringBandSupportWinView:OnRegisterGameEvent()

end

function TouringBandSupportWinView:OnRegisterBinder()
	self.ViewModel = _G.TouringBandMgr:GetTouringBandSupportWinVM()

	local Binders = {
		{ "BandBuffVMList", UIBinderUpdateBindableList.New(self, self.BandBuffVMAdapter) },
		{ "ExpText", UIBinderSetText.New(self, self.TextGet) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

return TouringBandSupportWinView