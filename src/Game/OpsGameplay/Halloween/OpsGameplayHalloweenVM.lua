--
-- Author: sammrli
-- Date: 2025-5-28 15:14
-- Description: 活动玩法-守护天节 界面View Model
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")

local OpsHalloweenClueItemVM = require("Game/Ops/View/OpsHalloween/Itme/VM/OpsHalloweenClueItemVM")

---@class OpsGameplayHalloweenVM : UIViewModel
---@field Title string
---@field TaskDesc string
---@field ClueTitle string
---@field ClueList UIBindableList
local OpsGameplayHalloweenVM = LuaClass(UIViewModel)

function OpsGameplayHalloweenVM:Ctor()
    self.Title = ""
    self.TaskDesc = ""
    self.ClueTitle = ""
    self.ClueList = UIBindableList.New(OpsHalloweenClueItemVM)
end

return OpsGameplayHalloweenVM