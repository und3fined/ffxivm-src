---
--- Author: chaooren
--- DateTime: 2022-01-21 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local ObjectMgr = require("Object/ObjectMgr")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local UIViewIDPair = ProSkillDefine.UIViewIDPair
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

---@class MainProSkillView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProSkillSlot UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainProSkillView = LuaClass(UIView, true)

function MainProSkillView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProSkillSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainProSkillView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainProSkillView:OnInit()
	self.CurView = nil
	self.CurTag = ""
	self.CacheView = nil
	self.CacheTag = ""
end

function MainProSkillView:OnDestroy()
	if self.CurView then
		_G.UIViewMgr:RecycleView(self.CurView)
		self.CurView = nil
	end
end

function MainProSkillView:OnShow()
	self:OnSpectrumReplace()
	self:OnSkillSpectrumForbidStatus(_G.MainProSkillMgr:GetSpectrumForbidStatus())
end

function MainProSkillView:OnHide()

end

function MainProSkillView:OnRegisterUIEvent()

end

function MainProSkillView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillSpectrumReplace, self.OnSpectrumReplace)
	self:RegisterGameEvent(EventID.SkillSpectrumSync, self.OnSpectrumReplace)
	self:RegisterGameEvent(EventID.SkillSpectrumForbidStatus, self.OnSkillSpectrumForbidStatus)
end

function MainProSkillView:OnRegisterBinder()

end

function MainProSkillView:OnPWorldMapEnter(_)
	self:OnSpectrumReplace()
end

function MainProSkillView:OnSpectrumReplace()
	local function RemoveView()
		local CurView = self.CurView
		if CurView then
			CurView:HideView()
			self.CurTag = ""
			self.ProSkillSlot:ClearChildren()
			WidgetPoolMgr:RecycleWidget(CurView)
			self.CurView = nil
		end
	end

	local CurrentSpectrumIDs = _G.MainProSkillMgr.CurrentSpectrumIDs
	print(string.format("[Spectrum] replace %s", table_to_string(CurrentSpectrumIDs)))
	if not CurrentSpectrumIDs or #CurrentSpectrumIDs == 0 then
		RemoveView()
		return
	end

	local CurViewTag = 0
	for _, value in ipairs(CurrentSpectrumIDs) do
		--忽视量谱ID为0的配置
		if value ~= 0 then
			local ViewTag = UIViewIDPair[value] or -1
			if CurViewTag == 0 then
				CurViewTag = ViewTag
			elseif CurViewTag ~= ViewTag then
				CurViewTag = -1
				FLOG_WARNING("Can't switch spectrum between different ViewID")
				break
			end
		end
	end
	local UnlockSpectrumData = _G.MainProSkillMgr.UnlockSpectrumData
	local function OnPostMajorUnlockSpectrum(Params)
		_G.SkillLogicMgr:PostMajorUnlockSpectrum(Params)
		_G.MainProSkillMgr.UnlockSpectrumData = nil
	end
	if CurViewTag == 0 or CurViewTag == -1 then
		RemoveView()
	elseif CurViewTag == self.CurTag then
		self.CurView:UpdateView(CurrentSpectrumIDs)
		--判断是否需要解锁
		if UnlockSpectrumData ~=nil then
			OnPostMajorUnlockSpectrum(UnlockSpectrumData)
		end
	else
		local function OnLoadComplete(Widget)
			if _G.UE.UCommonUtil.IsObjectValid(self.ProSkillSlot) then
				RemoveView()
				if Widget then
					self.ProSkillSlot:AddChildToCanvas(Widget)
					local Size=UIUtil.CanvasSlotGetSize(Widget)
					UIUtil.CanvasSlotSetSize(Widget, _G.UE.FVector2D(1920, 1080))
					self:AddSubView(Widget)
					self.CurView = Widget
					self.CurTag = CurViewTag

					if UnlockSpectrumData ~=nil then
						OnPostMajorUnlockSpectrum(UnlockSpectrumData)
					end
				end
			else
				WidgetPoolMgr:RecycleWidget(Widget)
			end
		end

		WidgetPoolMgr:CreateWidgetAsyncByName(CurViewTag, nil, OnLoadComplete, true, true, CurrentSpectrumIDs)
	end
end

function MainProSkillView:CreateView(ViewPath)
	local View = nil
	-- if ViewPath == self.CacheTag then
	-- 	View = self.CacheView
	-- 	self.CacheView = nil
	-- 	self.CacheTag = ""
	-- 	return View
	-- end
	local Class = ObjectMgr:LoadClassSync(tostring(ViewPath))
	if nil == Class then
		return
	end
	View = _G.UE.UWidgetBlueprintLibrary.Create(FWORLD(), Class)
	if nil == View then
		return
	end

	return View
end

function MainProSkillView:OnSkillSpectrumForbidStatus(ForbidStatus)
	UIUtil.SetRenderOpacity(self.ProSkillSlot, ForbidStatus and 0 or 1)
end

return MainProSkillView