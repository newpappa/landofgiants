--[[
Name: OrbCounter
Type: ModuleScript
Location: ReplicatedStorage
Description: Counts successful and failed orb spawns over the first 10 seconds
--]]

local OrbCounter = {}

-- Storage
local attempts = {
    success = {},
    failed = {},
    startTime = os.time()
}

-- Log a successful spawn
function OrbCounter.LogSuccess(orbType)
    table.insert(attempts.success, {
        type = orbType,
        time = os.time()
    })
end

-- Log a failed spawn
function OrbCounter.LogFail()
    table.insert(attempts.failed, {
        time = os.time()
    })
end

-- Get summary of attempts
local function getSummary()
    local summary = {
        total_success = #attempts.success,
        total_failed = #attempts.failed,
        by_type = {
            SMALL = 0,
            MEDIUM = 0,
            LARGE = 0
        }
    }
    
    -- Count by type
    for _, spawn in ipairs(attempts.success) do
        summary.by_type[spawn.type] = summary.by_type[spawn.type] + 1
    end
    
    return summary
end

-- Print a summary after 10 seconds
task.delay(10, function()
    local summary = getSummary()
    local runtime = os.time() - attempts.startTime
    
    print("\n=== ORB SPAWN SUMMARY ===")
    print("Time Period:", runtime, "seconds")
    print("\nResults:")
    print("  Total Successful:", summary.total_success)
    print("  Total Failed:", summary.total_failed)
    print("  Success Rate:", string.format("%.1f%%", 
        (summary.total_success / (summary.total_success + summary.total_failed)) * 100))
    print("\nBy Type:")
    print("  Small Orbs:", summary.by_type.SMALL)
    print("  Medium Orbs:", summary.by_type.MEDIUM)
    print("  Large Orbs:", summary.by_type.LARGE)
    print("========================\n")
end)

return OrbCounter 