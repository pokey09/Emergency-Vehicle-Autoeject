-- Rope configuration
Config = {}

-- Define ropes with detailed parameters
Config.Ropes = {
    {
        coords = vector3(-1402.11, -498.28, 34.61),  -- Starting point
        rotation = vector3(0.0, 0.0, 0.0),          -- Direction vector
        maxLength = 5.0,                           -- Maximum rope length
        ropeType = 7,                               -- Rope type
        initLength = 1.5,                           -- Initial length
        minLength = 1.0,                            -- Minimum length
        lengthChangeRate = 1.0,                     -- Rate of length change
        onlyPPU = false,                            -- Use only PPU
        collisionOn = true,                         -- Collision enabled
        lockFromFront = false,                      -- Locked from the front
        timeMultiplier = 1.0,                       -- Time multiplier
        breakable = false,                          -- Breakable rope
        unkPtr = nil,                               -- Unknown pointer
    }
}

Config.RopesVehicles = {
    ["enforcerengine"] = {bone = "bodyshell", offset = vector3(-1.07, 3.41, -0.23)},
}