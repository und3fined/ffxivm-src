--chaooren
--do slate pretick
local CommonUtil = require("Utils/CommonUtil")

local SlatePreTick = {
    Callback = {},
    SingleCallback = {},
    NextFrameCallback = {}
}


function SlatePreTick.RegisterSlatePreTick(Listener, Callback, Params)
    for _, value in ipairs(SlatePreTick.Callback) do
        if value.Listener == Listener and value.Callback == Callback then
            FLOG_WARNING("already registered")
            return
        end
    end
    table.insert(SlatePreTick.Callback, {Listener = Listener, Callback = Callback, Params = Params})
end

function SlatePreTick.UnRegisterSlatePreTick(Listener, Callback)
    for key, value in ipairs(SlatePreTick.Callback) do
        if value ~= nil and value.Listener == Listener and value.Callback == Callback then
            table.remove(SlatePreTick.Callback, key)
            return
        end
    end
end

function SlatePreTick.RegisterSlatePreTickSingle(Listener, Callback, Params)
    table.insert(SlatePreTick.SingleCallback, {Listener = Listener, Callback = Callback, Params = Params})
end

function SlatePreTick.UnRegisterSlatePreTickSingle(Listener, Callback)
    for key, value in ipairs(SlatePreTick.Callback) do
        if value ~= nil and value.Listener == Listener and value.Callback == Callback then
            table.remove(SlatePreTick.Callback, key)
            return
        end
    end
end

function SlatePreTick.RegisterSlatePreTickNextFrame(Listener, Callback, Params)
    table.insert(SlatePreTick.NextFrameCallback, {Listener = Listener, Callback = Callback, Params = Params})
end

function SlatePreTick.UnRegisterSlatePreTickNextFrame(Listener, Callback)
    for key, value in ipairs(SlatePreTick.NextFrameCallback) do
        if value ~= nil and value.Listener == Listener and value.Callback == Callback then
            table.remove(SlatePreTick.NextFrameCallback, key)
            return
        end
    end
    SlatePreTick.UnRegisterSlatePreTickSingle(Listener, Callback)
end

function SlatePreTick.DoSlatePreTick(DeltaTime)
    local _ <close> = CommonUtil.MakeProfileTag("SlatePreTick.DoSlatePreTick")
    for _, value in ipairs(SlatePreTick.Callback) do
        if value and value.Callback then
            CommonUtil.XPCall(value.Listener, value.Callback, DeltaTime, value.Params)
        end
    end

    for _, value in ipairs(SlatePreTick.SingleCallback) do
        if value and value.Callback then
            CommonUtil.XPCall(value.Listener, value.Callback, DeltaTime, value.Params)
        end
    end
    SlatePreTick.SingleCallback = SlatePreTick.NextFrameCallback
    table.clear(SlatePreTick.NextFrameCallback)
end

return SlatePreTick