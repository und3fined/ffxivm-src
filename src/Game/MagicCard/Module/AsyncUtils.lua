---
--- Author: frankjfwang
--- DateTime: 2022-05-20 17:43
--- Description:
---


local co = coroutine
local table = table

---@class MagicCardAsyncUtils
local M = {}

function M.Wrap(func)
    return function(...)
        local current_co = co.running()
        local ret_sync, res = false, nil
        local function cb(...)
            if co.status(current_co) == "running" then
                -- func以同步方式执行时，在当前coroutine还在running状态时调用了cb，此时不需要resume，直接返回
                ret_sync = true
                res = ...
            else
                local stat, ret = co.resume(current_co, ...)
                --assert(stat, ret)
                -- 改动记录：
                -- 外部可能提前终止了协程，这里报个警告就好了，不需要错误，看后续是否要加参数显示是否显示为错误？
                if (not stat) then
                    _G.FLOG_WARNING(string.format("%s, %s,",tostring(stat), tostring(ret)))
                end
            end
        end
        local params = table.pack(...)
        table.insert(params, cb)
        func(table.unpack(params))
        if not ret_sync then
            res = co.yield()
        end
        -- 这里的return用于在func以同步方式调用cb时返回结果
        return res
    end
end

function M.BeginTask(func, ...)
    local t = co.create(func)
    co.resume(t, ...)
end

return M