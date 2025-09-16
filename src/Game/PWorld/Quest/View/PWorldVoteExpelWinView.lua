---
--- Author: v_hggzhang
--- DateTime: 2023-05-16 17:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class PWorldVoteExpelWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnConfirm CommBtnLView
---@field TableViewVoteItem UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteExpelWinView = LuaClass(UIView, true)

function PWorldVoteExpelWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnConfirm = nil
	--self.TableViewVoteItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldVoteExpelWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnConfirm)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldVoteExpelWinView:OnInit()
	self.MemAdp = UIAdapterTableView.CreateAdapter(self, self.TableViewVoteItem, function(_, Idx, ItemVM)
		if self.SeltMemID == ItemVM.MemRoleID then
			self.SeltMemID = nil
		else
			self.SeltMemID = ItemVM.MemRoleID
		end

		self.BtnConfirm:SetIsEnabled(self.SeltMemID ~= nil)
	end, true, true)
end

function PWorldVoteExpelWinView:OnDestroy()

end

function PWorldVoteExpelWinView:OnShow()
	self.MemAdp:ClearSelectedItem()
	_G.PWorldTeamVM:ClearMatchMembersSelection()
	self.SeltMemID = nil
	self.BtnConfirm:SetIsEnabled(self.SeltMemID ~= nil)
end

function PWorldVoteExpelWinView:OnHide()

end

function PWorldVoteExpelWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, function()
		if not self.SeltMemID then
			return
		end

		_G.PWorldTeamMgr:ReqPWVoteStartExile(self.SeltMemID)
		self:Hide()
		-- print("zhg PWorldVoteExpelWinView:OnRegisterUIEvent self.SeltMemID = " .. tostring(self.SeltMemID))
	end)
end

function PWorldVoteExpelWinView:OnRegisterGameEvent()

end

function PWorldVoteExpelWinView:OnRegisterBinder()
	local VM = _G.PWorldTeamVM
	if not VM then
		return
	end
	local Binders = {
        { "MatchMems",       UIBinderUpdateBindableList.New(self, self.MemAdp) },
    }
    self:RegisterBinders(VM, Binders)
end

function PWorldVoteExpelWinView:SetConfirmBtn(V)
	self.BtnConfirm:SetIsEnabled(V)
end

return PWorldVoteExpelWinView