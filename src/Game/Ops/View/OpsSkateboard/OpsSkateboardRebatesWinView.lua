--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-03-31 15:00:04
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-31 15:02:49
FilePath: \Script\Game\Ops\View\OpsSkateboard\OpsSkateboardRebatesWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("Game/Ops/View/OpsActivity/Item/OpsWhaleMonutRebatesWinView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsSkateboardRebatesWinView : OpsWhaleMonutRebatesWinView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRecommend OpsCommBtnLView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field PopUpBG CommonPopUpBGView
---@field TableViewList UTableView
---@field TextHint UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkateboardRebatesWinView = LuaClass(UIView, true)

return OpsSkateboardRebatesWinView