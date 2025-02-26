local activeRopes = {}
local attachedProp = nil
local attachKey = 38 -- [E] key to grab rope
local dropKey = 73 -- [X] key to drop rope
local interactingRope = nil
local isHoldingRope = false

-- Function to create and attach a prop to the player's hand
local function attachPropToPlayer()
    local playerPed = PlayerPedId()

    -- Load the model
    local propModel = `prop_rope_hook_01`
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Citizen.Wait(0)
    end

    -- Create the prop
    attachedProp = CreateObject(propModel, 0, 0, 0, true, true, true)

    -- Attach the prop to the player's hand
    AttachEntityToEntity(
        attachedProp,
        playerPed,
        GetPedBoneIndex(playerPed, 60309), -- Right hand bone
        0.0, 0.0, 0.0, -- Offset
        0.0, 0.0, 0.0, -- Rotation
        true, true, false, true, 1, true
    )
end

-- Function to detach and delete the prop
local function detachProp()
    if DoesEntityExist(attachedProp) then
        DetachEntity(attachedProp, true, true)
        DeleteEntity(attachedProp)
        attachedProp = nil
    end
end

-- Function to create a new rope
local function createRope(ropeData)
    local ropeId = AddRope(
        ropeData.coords.x, ropeData.coords.y, ropeData.coords.z, -- Anchor point
        ropeData.rotation.x, ropeData.rotation.y, ropeData.rotation.z, -- Direction vector
        ropeData.maxLength,                                      -- Maximum length
        ropeData.ropeType,                                       -- Rope type
        ropeData.initLength,                                     -- Initial length
        ropeData.minLength,                                      -- Minimum length
        ropeData.lengthChangeRate,                               -- Length change rate
        ropeData.onlyPPU,                                        -- Only PPU
        ropeData.collisionOn,                                    -- Collision enabled
        ropeData.lockFromFront,                                  -- Lock from front
        ropeData.timeMultiplier,                                 -- Time multiplier
        ropeData.breakable,                                      -- Breakable rope
        ropeData.unkPtr                                          -- Unknown pointer
    )

    if ropeId then
        RopeLoadTextures()
        StartRopeUnwindingFront(ropeId)

        activeRopes[#activeRopes + 1] = {
            ropeId = ropeId,
            coords = ropeData.coords,
            maxLength = ropeData.maxLength,
            attachedToPlayer = false,
        }

        print("Rope created at", ropeData.coords)
        return ropeId
    else
        print("Failed to create rope.")
        return nil
    end
end

-- Function to attach rope to the player's prop
local function attachRopeToProp(rope)
    if not attachedProp then
        print("No prop attached to the player.")
        return
    end

    -- Attach the rope to the prop
    AttachEntitiesToRope(
        rope.ropeId,                      -- Rope ID
        attachedProp, -1,                 -- Prop entity
        rope.coords.x, rope.coords.y, rope.coords.z, -- Anchor point
        0.0, 0.0, 0.0,                   -- Offset
        false,                           -- No collision
        true                             -- Lock from front
    )

    isHoldingRope = true
    rope.attachedToPlayer = true
    interactingRope = rope

    print("Rope attached to prop.")
end

-- Function to attach rope to a vehicle bone
local function attachRopeToVehicle(vehicle, bone, offset, rope)
    if DoesEntityExist(vehicle) then
        local boneIndex = GetEntityBoneIndexByName(vehicle, bone)
        local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)

        -- Add the offset to the bone position
        local attachCoords = boneCoords + offset

        -- Attach rope to vehicle bone
        AttachEntitiesToRope(
            rope.ropeId,
            vehicle, boneIndex,
            rope.coords.x, rope.coords.y, rope.coords.z, -- Rope anchor point
            attachCoords.x, attachCoords.y, attachCoords.z, -- Vehicle attach point
            false, -- No collision
            true   -- Lock from front
        )

        print("Rope attached to vehicle.")
    else
        print("Vehicle not found.")
    end
end

-- Interaction loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Check for nearby ropes
        for _, rope in ipairs(activeRopes) do
            local distance = #(playerCoords - rope.coords)

            if not isHoldingRope and distance < 2.0 then
                DrawText3D(rope.coords, "[E] Grab Rope")
                if IsControlJustPressed(0, attachKey) then
                    attachPropToPlayer()
                    attachRopeToProp(rope)
                end
            end
        end

        -- Drop the rope
        if isHoldingRope and IsControlJustPressed(0, dropKey) then
            detachProp()
            isHoldingRope = false
        end
    end
end)

-- Automatically create ropes on resource start
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, ropeData in ipairs(Config.Ropes) do
        createRope(ropeData)
    end
end)

-- Draw 3D text at specified coordinates
function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - coords)

    if onScreen then
        local scale = (1 / dist) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov

        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
