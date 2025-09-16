--[[
Author: xingcaicao
Date: 2023-05-18 20:59
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-10 11:16:06
FilePath: \Script\Game\TeamRecruit\View\Item\TeamRecruitProfItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class TeamRecruitProfItemView : UIView
---@field ViewModel TeamRecruitSimpleProfVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImgCheck UFImage
---@field FImgProf UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitProfItemView = LuaClass(UIView, true)

function TeamRecruitProfItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImgCheck = nil
	--self.FImgProf = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitProfItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitProfItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.FImgProf) },
		{ "HasRole", UIBinderSetIsVisible.New(self, self.FImgCheck) },
	}

	self.RoleBinders = {
		{"Prof", UIBinderValueChangedCallback.New(self, nil, function(View, NewProf)
			if View.ViewModel and NewProf then
				-- View.ViewModel:UpdateProfs({NewProf})
				View.ViewModel.Profs  = {NewProf}
    			View.ViewModel:UpdateFunctionInfo()
			end
		end)}
	}
end

function TeamRecruitProfItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if not self.ViewModel then
		return
	end
	
	self:RegisterBinders(self.ViewModel, self.Binders)
	if self.ViewModel.HasRole then
		self:RegisterBinders(_G.RoleInfoMgr:FindRoleVM(self.ViewModel.RoleID), self.RoleBinders)
	end
end

return TeamRecruitProfItemView