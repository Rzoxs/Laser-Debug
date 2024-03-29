local enabled = false
local hit, coords

RegisterCommand('debuglaser', function()
    enabled = not enabled

    CreateThread(function()
        while enabled do
            local weapon = GetCurrentPedWeaponEntityIndex(PlayerPedId())
            if weapon ~= 0 then
                local offset = GetOffsetFromEntityInWorldCoords(weapon, 0, 0, -0.01)
                hit, coords = RayCastPed(offset, 15000, PlayerPedId())
                if hit ~= 0 then
                    DrawLine(offset.x, offset.y, offset.z, coords.x, coords.y, coords.z, 255, 0, 0, 120)
                    DrawSphere2(coords, 0.01, 255, 0, 0, 120)
                    Draw3DText(coords.x, coords.y, coords.z, string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
                end
            end
            Wait(0)
        end
    end)
end, false)

RegisterCommand("printCoords", function(src, args, raw)
    if args[1] ~= nil then
        format = "%s - vector3(%.2f, %.2f, %.2f)"
        print(format:format(args[1], coords.x, coords.y, coords.z))
        return
    end

    print(string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
end)

---@param rotation vector3
---@return vector3
function RotationToDirection(rotation)
	local adjustedRotation = { x = (math.pi / 180) * rotation.x, y = (math.pi / 180) * rotation.y, z = (math.pi / 180) * rotation.z }
	local direction = vector3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
	
    return direction
end

---@param pos vector3
---@param distance number
---@param ped number
---@return boolean, vector3
function RayCastPed(pos,distance,ped)
    local cameraRotation = GetGameplayCamRot()
	local direction = RotationToDirection(cameraRotation)
	local destination = vector3(pos.x + direction.x * distance, pos.y + direction.y * distance, pos.z + direction.z * distance)

	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(pos.x, pos.y, pos.z, destination.x, destination.y, destination.z, -1, ped, 1))
    return b, c
end

---@param pos vector3
---@param radius number
---@param r number
---@param g number
---@param b number
---@param a number
---@return void
function DrawSphere2(pos, radius, r, g, b, a)
	DrawMarker(28, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, radius, r, g, b, a, false, false, 2, nil, nil, false)
end

---@param x number
---@param y number
---@param z number
---@param text string
function Draw3DText(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropShadow(0, 0, 0, 55)
		SetTextEdge(0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end
