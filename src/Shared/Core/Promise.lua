--[[
Name: Promise
Type: ModuleScript
Location: ReplicatedStorage.Shared.Core
Description: Basic Promise implementation for handling asynchronous operations
--]]

local Promise = {}
Promise.__index = Promise

-- Create a new Promise
function Promise.new(executor)
    local self = setmetatable({}, Promise)
    self._state = "pending"
    self._value = nil
    self._callbacks = {}
    
    local function resolve(value)
        if self._state ~= "pending" then return end
        self._state = "fulfilled"
        self._value = value
        self:_runCallbacks()
    end
    
    local function reject(reason)
        if self._state ~= "pending" then return end
        self._state = "rejected"
        self._value = reason
        self:_runCallbacks()
    end
    
    local success, err = pcall(executor, resolve, reject)
    if not success then
        reject(err)
    end
    
    return self
end

-- Create a resolved Promise
function Promise.resolve(value)
    return Promise.new(function(resolve)
        resolve(value)
    end)
end

-- Create a rejected Promise
function Promise.reject(reason)
    return Promise.new(function(_, reject)
        reject(reason)
    end)
end

-- Handle Promise resolution
function Promise:_runCallbacks()
    for _, callback in ipairs(self._callbacks) do
        if self._state == "fulfilled" then
            callback.onFulfilled(self._value)
        elseif self._state == "rejected" then
            callback.onRejected(self._value)
        end
    end
    self._callbacks = {}
end

-- Chain a new Promise
function Promise:andThen(onFulfilled, onRejected)
    return Promise.new(function(resolve, reject)
        local function handleCallback(callback, value)
            if type(callback) ~= "function" then
                resolve(value)
                return
            end
            
            local success, result = pcall(callback, value)
            if success then
                resolve(result)
            else
                reject(result)
            end
        end
        
        if self._state == "pending" then
            table.insert(self._callbacks, {
                onFulfilled = function(value)
                    handleCallback(onFulfilled, value)
                end,
                onRejected = function(reason)
                    handleCallback(onRejected, reason)
                end
            })
        elseif self._state == "fulfilled" then
            handleCallback(onFulfilled, self._value)
        elseif self._state == "rejected" then
            handleCallback(onRejected, self._value)
        end
    end)
end

-- Handle Promise rejection
function Promise:catch(onRejected)
    return self:andThen(nil, onRejected)
end

-- Wait for all Promises to resolve
function Promise.all(promises)
    return Promise.new(function(resolve, reject)
        local results = {}
        local remaining = #promises
        
        if remaining == 0 then
            resolve(results)
            return
        end
        
        for i, promise in ipairs(promises) do
            promise:andThen(function(value)
                results[i] = value
                remaining = remaining - 1
                if remaining == 0 then
                    resolve(results)
                end
            end, function(reason)
                reject(reason)
            end)
        end
    end)
end

function Promise.Init()
    return true
end

return Promise 