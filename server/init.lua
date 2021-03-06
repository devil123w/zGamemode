util.AddNetworkString("Eye")
util.AddNetworkString("Kills")
util.AddNetworkString("timeSend")
util.AddNetworkString("openlogs")
util.AddNetworkString("SendLogs")
util.AddNetworkString("send_start_message")
resource.AddFile("vehicles/enzo/cringe.wav")
resource.AddFile("vehicles/enzo/levelup.wav")
resource.AddWorkshop("128089118") --M9K Weapons
local NPCSpawnCount = 6 -- we are not yandere dev put these vars in other files and use include() to run them
local KillCount = 0
local TimeString = os.date("%d.%m.%Y - %H:%M:%S", Timestamp)
CheckIfSpawned = 0
local AbleToPlay = true

PlayerModels = {"npc_kleiner", "npc_eli", "npc_breen"}

hook.Add("PlayerInitialSpawn", "PlayerConnect", function(ply)
    timer.Simple(3, function()
        for k, v in pairs(player.GetAll()) do
            local StartMessageTab = { -- chat.Add infomations
                Color(255, 0, 0),
                "[",
                Color(0,255,0),
                "SYSTEM",
                Color(255,0,0),
                "] ",
                Color(255,255,255),
                "Um das Spiel zu starten musst du",
                Color(0,255,0),
                "!start",
                Color(255,255,255),
                "in den Chat schreiben!"

            }

            if 0 == 0 then -- if u want add filter condition here
                net.Start("send_start_message")
                net.WriteTable(StartMessageTab or {}) -- only about 800 key's !
                net.Send(v)
            end
        end

        file.Append("logsys/test.txt", "\n[ " .. TimeString .. "] " .. ply:Name() .. "" .. " (" .. ply:SteamID() .. ") hat sich auf den Server verbunden.\n")
        net.Start("SendLogs")
        net.WriteString("PlayerInitial")
        net.Send(ply)
        ply:StripWeapons()
        ply:Spectate(6)
    end)
end)

local function Spawn(ply)
    timer.Simple(1, function()
        ply:StripWeapons()
        ply:Spectate(6)
    end)
end

hook.Add("PlayerSpawn", "SpawnPlayer", Spawn)

if (AbleToPlay) then
    hook.Add("PlayerSay", "StartCommand", function(ply, text, ent)
        if string.lower(text) == "!sa" and ply:Team() ~= TEAM_SHOOTER then
            ply:changeTeam(TEAM_SHOOTER, true) -- when this gamemode is not based on DarkRP ply:changeTeam() won't work use ply:SetTeam()
            roundStat = 1 -- I don't know if you want to store those values on the ply but when your anwser is yes use ply:SetNWBool() or ply:SetNWInt()
            IsSpawning = 1
            ply:SelectWeapon("m9k_m16a4_acog")
            ply:GiveAmmo(200, "smg1", true)
            ply:GiveAmmo(300, "m9k_ammo_ar2", true)
            Main(ply)
            ply:UnSpectate()
            CheckIfSpawned = 0
            ply:SetModel("models/Police.mdl")
            AbleToPlay = false

            return ""
        elseif string.lower(text) == "!sa" and ply:Team() == TEAM_SHOOTER then
            roundStat = 1
            IsSpawning = 1
            ply:Give("m9k_m16a4_acog", false)
            ply:SelectWeapon("m9k_m16a4_acog")
            ply:GiveAmmo(200, "smg1", true)
            ply:GiveAmmo(300, "m9k_ammo_ar2", true)
            Main(ply)
            ply:UnSpectate()
            CheckIfSpawned = 0
            AbleToPlay = false

            return ""
        elseif string.lower(text) == "!logs" then
            net.Start("openlogs")
            net.Send(ply)

            return ""
        elseif string.lower(text) == "!reset" then
            ply:ChatPrint("Du hast dich erfolgreich zurückgesetzt")
            KillCount = 0
            roundStat = 0
            IsSpawning = 0
            CheckIfSpawned = 0
            NPCSpawnCount = 6
            ply:Spectate(6)
            ply:StripWeapons()
            ply:SelectWeapon("")
            prop:Remove()
            game.CleanUpMap()
            timer.Stop("NpcSpawn")
            Timegerundet = 0
            time = 0

            return ""
        end
    end)
end

function reset(attacker)
    attacker:ChatPrint("Du wurdest zurückgesetzt")
    KillCount = 0
    roundStat = 0
    IsSpawning = 0
    CheckIfSpawned = 0
    NPCSpawnCount = 6
    attacker:Spectate(6)
    attacker:StripWeapons()
    attacker:SelectWeapon("")
    attacker:Remove()
    game.CleanUpMap()
    AbleToPlay = true
end

--local ZufallsPlayer = math.random(1, #player.GetAll())
for k, v in ipairs(player.GetAll()) do
    timer.Simple(5, function()
        v:SetModel("models/player/police_fem.mdl")
        v:PhysicsInit(SOLID_VPHYSICS)
    end)
end

function Main(ply)
    print("Runde : " .. roundStat)
    local NPC = ents.Create("npc_kleiner")

    if roundStat == 1 and IsSpawning == 1 then
        ply:UnSpectate()
        ply:Freeze(true)
        ply:SetPos(Vector(23.519316, 178.790863, -83.970474)) -- Player TP 
        net.Start("Eye")
        net.WriteBool(true)
        net.Send(ply)

        timer.Simple(4, function()
            NPCSpawnCount = 6
            ply:ChatPrint("Aufgabe: Du musst die " .. NPCSpawnCount .. " NPCs so schnell wie möglich töten!\nDie Zeit beginnt wenn du den ersten NPC getötet hast. \n")
        end)

        timer.Create("NpcSpawn", 1, 3, function()
            ply:PrintMessage(HUD_PRINTCENTER, "Loading...")

            timer.Simple(4, function()
                ply:PrintMessage(HUD_PRINTCENTER, "Loading finished")
            end)

            for i = 1, 2 do
                local RandomXYPos = Vector(math.random(-332, -850), math.random(-150, 400), 1)
                net.Start("SendLogs")
                net.WriteString("NPCSpawns")
                net.Send(ply)
                NPC = ents.Create(table.Random(PlayerModels))
                NPC:SetPos(RandomXYPos)
                NPC:DropToFloor()
                NPC:SetMaxHealth(10)
                NPC:SetHealth(10)
                NPC:Spawn()
                -- ply:ChatPrint(" HEALTH " .. NPC:Health())
                NPCSpawnCount = NPCSpawnCount - 1
                --local NPCCurrHealth = NPC:Health()
                --hook.Add("Think", "HealthThink", function()
                net.Start("Eye")
                --net.WriteUInt(NPCCurrHealth, 4)
                net.Send(ply)

                -- end)
                if NPCSpawnCount <= 0 then
                    print("Alle NPCs sind erfolgreich gespawnt")
                    ply:SetWalkSpeed(200)
                    timer.Remove("NpcSpawn")
                elseif NPCSpawnCount > 6 then
                    ply:PrintMessage(HUD_PRINTCENTER, "Fehler")
                    reset()
                    game.CleanUpMap()
                end
            end
        end)

        timer.Simple(4, function()
            ply:Freeze(false)
            ply:SetWalkSpeed(7)

            hook.Add("SetupMove", "TestFunc", function(pplayyer, mv, cmd)
                pplayyer:StopWalking()
            end)
        end)

        function SpawnTableFunction()
            local SpawnPos = Vector(-50.519316, 180.790863, -83.970474)
            prop = ents.Create("prop_physics")
            prop:SetModel("models/props_wasteland/kitchen_counter001d.mdl")
            prop:SetPos(SpawnPos)
            prop:Spawn()
            CheckIfSpawned = 1

            return CheckIfSpawned
        end

        if CheckIfSpawned ~= 1 then
            SpawnTableFunction()
            net.Start("SendLogs")
            net.WriteString("PropSpawn")
            net.Send(ply)
        else
            print("Prop already spawned")
        end

        function level2()
            local NPCSpawnCount2 = 9

            hook.Add("PlayerSay", "level2Start", function(plyy, text2, ent)
                if string.lower(text2) == "!level2" then
                    plyy:ChatPrint("LEVEL 2 : Die Zeit beginnt wenn du den ersten NPC getötet hast.")
                    file.Append("logsys/serverlogs.txt", "[ " .. TimeString .. "] Level 2 wurde von " .. plyy:Name() .. " gestartet \n")
                    plyy:Freeze(true)
                    plyy:Give("m9k_fal", true)

                    timer.Create("NPCSpawn2", 1, 3, function()
                        plyy:PrintMessage(HUD_PRINTCENTER, "Loading level 2...")

                        timer.Simple(5, function()
                            plyy:PrintMessage(HUD_PRINTCENTER, "Loading finished")
                            plyy:Freeze(false)
                        end)

                        for i = 1, 3 do
                            local RandomXYPos = Vector(math.random(-1332, -650), math.random(-150, 400), 1)
                            print("NPC Spawned")
                            NPC = ents.Create(table.Random(PlayerModels))
                            NPC:SetPos(RandomXYPos)
                            NPC:DropToFloor()
                            --NPC:SetNPCState(2)
                            NPC:SetMaxHealth(40)
                            NPC:SetHealth(40)
                            NPC:Spawn()
                            -- ply:ChatPrint(" HEALTH " .. NPC:Health())
                            NPCSpawnCount2 = NPCSpawnCount2 - 1

                            --local NPCCurrHealth = NPC:Health()
                            hook.Add("Think", "HealthThink2", function()
                                net.Start("Eye")
                                net.Send(plyy)
                            end)

                            if NPCSpawnCount2 <= 0 then
                                plyy:ChatPrint("Alle NPCs sind erfolgreich gespawnt")
                                plyy:SetWalkSpeed(200)
                                timer.Remove("NPCSpawn2")
                            end
                        end
                    end)
                    --
                    --roundStat = 2
                end
            end)
        end

        level2()

        hook.Add("OnNPCKilled", "Kills", function(victim, attacker, weapon)
            KillCount = KillCount + 1
            file.Append("logsys/playerlogs.txt", "[ " .. TimeString .. "] " .. victim:GetClass() .. " wurde von " .. attacker:GetName() .. " mit einer " .. ply:GetActiveWeapon():GetClass() .. " getötet.\n")
            net.Start("Kills")
            net.WriteUInt(KillCount, 4)
            net.WriteString("TimeStart")
            net.Send(ply)

            if KillCount == 6 then
                attacker:ChatPrint("Du wirst in 3 Sekunden automatisch zurückgesetzt.")

                timer.Simple(3, function()
                    reset(attacker)
                end)
            end
        end)

        hook.Add("EntityTakeDamage", "NPCDamage", function(target, dmginfo)
            if (target:IsNPC()) then end --  file.Append("logsys/serverlogs.txt", "[ " .. TimeString .. "] " .. NPC:GetClass() .. " hat " .. dmginfo:GetDamage() .. " Schaden von der Waffe: " .. ply:GetActiveWeapon() .. " bekommen\n")
        end)

        hook.Add("PlayerDisconnected", "PlayerDC", function(plyy)
            prop:Remove()
            net.Start("SendLogs")
            net.WriteString("PlayerDC")
            net.Send(plyy)
        end)
    end

    net.Receive("timeSend", function(len, play)
        local time = net.ReadFloat()
        Timegerundet = math.Truncate(time, 2) -- Rundung auf 2 Dezimalstellen

        for k, v in pairs(player.GetAll()) do
            v:ChatPrint(play:Name() .. " Hat Level 1 in " .. Timegerundet .. " Sekunden erledigt") --befindest dich jetzt in Level 2 \num fortzufahren musst du !level2 in den Chat schreiben."
        end
    end)
end

hook.Add("Initialize", "DateiTest", function()
    if not file.Exists("logsys", "DATA") then
        file.CreateDir("logsys")
        file.Write("logsys/test.txt", "------------------------ Test ------------------------\n")
    end
end)
