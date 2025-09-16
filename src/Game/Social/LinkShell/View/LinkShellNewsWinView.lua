---
--- Author: xingcaicao
--- DateTime: 2024-07-12 20:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class LinkShellNewsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field CommEmpty CommBackpackEmptyView
---@field TableViewNewsList UTableView
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellNewsWinView = LuaClass(UIView, true)

function LinkShellNewsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommEmpty = nil
	--self.TableViewNewsList = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellNewsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellNewsWinView:OnInit()
    self.TableAdapterNews = UIAdapterTableView.CreateAdapter(self, self.TableViewNewsList)

	self.Binders = {
		{ "IsEmptyNews", 	UIBinderSetIsVisible.New(self, self.CommEmpty) },
		{ "NewsItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterNews) },
	}
end

function LinkShellNewsWinView:OnDestroy()

end

function LinkShellNewsWinView:OnShow()
	self:InitConstText()

	--空提示文本内容
	self.CommEmpty:SetTipsContent(self.Params or "")
end

function LinkShellNewsWinView:OnHide()

end

function LinkShellNewsWinView:OnRegisterUIEvent()

end

function LinkShellNewsWinView:OnRegisterGameEvent()

end

function LinkShellNewsWinView:OnRegisterBinder()
	self:RegisterBinders(LinkShellVM, self.Binders)
end

function LinkShellNewsWinView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.BG:SetTitleText(_G.LSTR(40107)) -- "通讯贝动态"
end

return LinkShellNewsWinView