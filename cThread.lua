--
-- Created by IntelliJ IDEA.
-- User: Noneatme
-- Date: 25.01.2015
-- Time: 14:33
-- License: See License.md
--

--[[
	About:
	This class is used to create a virtual thread in a Lua VM.
	Usage:

	local performanceFunction = function()
		while(true) do
			coroutine.yield()
		end
	end

	local thread = cThread:new("simple thread", performanceFunction, 10);	-- 10 Calls / yield

	This class was written for MTA: San Andreas. If you want to use it for other scripts, you may have to remove some output functions.

]]

cThread = {}

Threads     = {}

_coroutine_resume = coroutine.resume

-- ///////////////////////////////
-- ///// resume
-- ///// Returns: string, string
-- ///////////////////////////////

function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		outputDebugString( tostring(result), 1 )	-- Output error message
	end
	return state,result
end

-- ///////////////////////////////
-- ///// new
-- ///// Returns: instance
-- ///////////////////////////////

function cThread:new(...)
    local obj = setmetatable({}, {__index = self});
    if obj.constructor then
        obj:constructor(...);
    end
    return obj;
end

-- ///////////////////////////////
-- ///// constructor
-- ///// Returns: nil
-- ///////////////////////////////

function cThread:constructor(sName, func, iAmmounts)
    assert(Threads[sName] == nil);
    self.name = sName
    self.func = func

    self.iAmmounts = iAmmounts or 1;
    outputConsole("[TRHEAD: "..sName.."] Constructor");

    Threads[sName]  = self;
end

-- ///////////////////////////////
-- ///// start
-- ///// Returns: nil
-- ///////////////////////////////

function cThread:start(iMS)
    self.thread = coroutine.create(self.func)
    self.yields = 0;

    self.lastTickCount  = getTickCount();

    self:resume()

    self.timer  = setTimer(function()
        if(self:status() == "suspended") then
            if(getTickCount()-self.lastTickCount > 5000) then
                self.lastTickCount = getTickCount();
                outputConsole("[THREAD: "..self.name.."] Current Yields: "..self.yields);
            end
            for i = 1, self.iAmmounts, 1 do
				if(self:status() == "suspended") then
	            self.yields = self.yields+1;
	            local result = self:resume();
	                if(result) and (type(result) ~= "boolean") then
	                    outputDebugString(tostring(result), 1)
	                end
					end
            end
        end

        if(self:status() == "dead") then
            killTimer(self.timer);
            self:stop()
        end
    end, iMS, -1)
end

-- ///////////////////////////////
-- ///// resume
-- ///// Returns: misc
-- ///////////////////////////////

function cThread:resume()
    return coroutine.resume(self.thread)
end

-- ///////////////////////////////
-- ///// stop
-- ///// Returns: nil
-- ///////////////////////////////

function cThread:stop()
    self.thread = nil

    outputConsole("[THREAD: "..self.name.."] Completed, Yields: "..self.yields);
end

-- ///////////////////////////////
-- ///// status
-- ///// Returns: string
-- ///////////////////////////////

function cThread:status()
    return coroutine.status(self.thread)
end

-- eof