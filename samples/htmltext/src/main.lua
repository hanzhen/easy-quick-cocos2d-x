
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

LuaLoadChunksFromZIP("res/easy_framework_precompiled.zip")

require("app.MyApp").new():run()
