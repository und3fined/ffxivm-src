local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MountVM = require("Game/Mount/VM/MountVM")
local EventID = require("Define/EventID")

---@class MountFilterTipsVM : UIViewModel
local MountFilterTipsVM = LuaClass(UIViewModel)

function MountFilterTipsVM:Ctor()
    self.IsTitle = false
    self.IsSelect = false
    self.TitleText = nil
    self.TitleColor = "C9C08FFF"
    self.Key = nil
    self.Category = nil
end

function MountFilterTipsVM:SetSelect(IsSelected, bSendEvent)
    self.IsSelect = IsSelected

    if self.IsTitle == true then
		self.TitleColor = self.IsSelect and "C9C08FFF" or "AFAFAFFF"
        if (bSendEvent) then
		    _G.EventMgr:SendEvent(EventID.MountFilterUpdate, {self.Key, self.IsSelect})
        end
	else
		if self.Category == 1 then
			MountVM:SetGetwayFilterValue(self.Key, self.IsSelect)
		elseif self.Category == 2 then
			MountVM:SetVersionFilterValue(self.Key, self.IsSelect)
		elseif self.Category == 3 then
			MountVM:SetLikeFilterValue(self.Key, self.IsSelect)
		end
        if (bSendEvent) then
		    _G.EventMgr:SendEvent(EventID.MountRefreshList)
        end
	end
end

function MountFilterTipsVM:SetItemSelect(IsSelected, bSendEvent)
    self.IsSelect = IsSelected
    MountVM:SetGetwayFilterValue(self.Key, self.IsSelect)
    if (bSendEvent) then
        _G.EventMgr:SendEvent(EventID.MountFilterUpdate, {self.Key, self.IsSelect})
        _G.EventMgr:SendEvent(EventID.MountRefreshList)
    end
end

return MountFilterTipsVM