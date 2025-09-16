--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-01-08 11:31:10
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-01-08 11:31:47
FilePath: \Client\Source\Script\LuaDebug.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaDebug = {}

--[[
--Luasocket已集成到工程里，除shipping版本都已开启，不需要手动加载socket.core
--搜索luasocket for debug-on-phone即可查看详情
package.cpath = package.cpath .. string.format(";%s\\..\\Tools\\luasocket\\?.dll",FDIR_CONTENT())
require("socket.core")
]]

--Lua断点调试（包括编辑器、真机）：【取消注释】下面一行即可且【切勿】提交至git！
-- require("LuaPanda").start("127.0.0.1", 8818)

-- Lua热更功能，修改Lua后无需重启Editor（出现异常时再重启，比如变更被绑定的函数（delegate，定时器等））：【取消注释】下面两行即可且【切勿】提交至git！
-- _G.UE.UnLuaDebugModule.Start()

-- Lua文件热更检测
_G.DynamicReloadLuaMgr = require("DynamicReloadLuaMgr")

--Lua内存快照，用于定位、监控内存情况
-- require("LuaPerf").Start()

------------------------------- 加载EmmyLua调试器 -------------------------------
--if _G.UE.UPlatformUtil.IsWithEditor() then
--    local ProjectDir = UE4.UKismetSystemLibrary.GetProjectDirectory()
--    local DebuggerPath = string.format("%s/Tools/EmmyLuaDebugger/1.4.6", ProjectDir)
--    --if FPaths.FileExists(string.format("%s/emmy_core.dll", DebuggerPath)) then
--    local File = io.open(string.format("%s/emmy_core.dll", DebuggerPath),"r");
--    if File ~= nil then
--        io.close(File)
--        package.cpath = package.cpath .. string.format(";%s/?.dll", DebuggerPath)
--        local dbg = require('emmy_core')
--        print("[DEBUG] Load debugger: ", dbg)
--        dbg.tcpListen('localhost', 9966)
--    end
--end

return LuaDebug