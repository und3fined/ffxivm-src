--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-17 16:40:32
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 16:41:18
FilePath: \Script\Game\Share\VM\ShareVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShareItemVM = require("Game/Share/VM/ShareItemVM")
local UIBindableList = require("UI/UIBindableList")
local ShareRewardItemVM = require("Game/Share/VM/ShareRewardItemVM")


---@class ShareVM : UIViewModel
---@field ExternalLinkShareItemList UIBindableList
---@field ShareActivityRewardVMList UIBindableList
local ShareVM = LuaClass(UIViewModel, nil)

function ShareVM:Ctor()
    self.ExternalLinkShareItemList = UIBindableList.New(ShareItemVM)
    self.ShareActivityRewardVMList =  UIBindableList.New(ShareRewardItemVM) 
    self.AcitivityImageShareItemList = UIBindableList.New(ShareItemVM)
end

function ShareVM:IsEqualVM()
	return false
end



return ShareVM