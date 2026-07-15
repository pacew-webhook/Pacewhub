-- 1. DETEKSI HTTP REQUEST DARI EXECUTOR
local request_func = (syn and syn.request) or (http and http.request) or http_request or request

if not request_func then
    game.Players.LocalPlayer:Kick("Executor Anda tidak mendukung HTTP Requests!")
    return
end

-- 2. KONFIGURASI WEBHOOK
-- ⚠️ Ganti link di bawah ini dengan URL Webhook Discord yang sudah Anda salin
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1526967957354451036/3sOJpYogicwGYAwAyV9ZrlH0yHCj970hqyU_ymxbcDsw-i9fMdxPUHaP9lARV-hlvRQm"
local LocalPlayer = game.Players.LocalPlayer

-- Fungsi untuk merapikan tampilan angka besar (misal: 1000000 -> 1.00M)
local function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

-- 3. LOOP PENGIRIMAN DATA
task.spawn(function()
    while true do
        local shekels = 0
        pcall(function()
            -- Ambil nilai koin/Shekels dari leaderstats game
            if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Shekels") then
                shekels = LocalPlayer.leaderstats.Shekels.Value
            end
        end)

        -- Struktur Embed Discord agar tampilan di Discord rapi dan keren
        local embedPayload = {
            ["username"] = "Grow A Garden 2 Monitor",
            ["avatar_url"] = "https://images.rbxcdn.com/71239aa8e374df986bc3a67732d847ff.png", -- Icon default Roblox
            ["embeds"] = {
                {
                    ["title"] = "🤖 Status Update Bot",
                    ["color"] = 65280, -- Warna Hijau (dalam format desimal)
                    ["fields"] = {
                        {
                            ["name"] = "Nama Bot Account",
                            ["value"] = "👤 " .. LocalPlayer.Name,
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Status",
                            ["value"] = "🟢 Active Farming",
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Total Shekels",
                            ["value"] = "💰 " .. formatNumber(shekels),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "Farm Rate Estimasi",
                            ["value"] = "⚡ x44.8K",
                            ["inline"] = true
                        }
                    },
                    ["footer"] = {
                        ["text"] = "Sistem Monitor Otomatis • Waktu: " .. os.date("%X")
                    }
                }
            }
        }

        -- Mengirim data ke Discord Webhook via POST request
        local success, response = pcall(function()
            return request_func({
                Url = DISCORD_WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode(embedPayload)
            })
        end)

        if success then
            print("Berhasil mengirim data status bot ke Discord!")
        else
            warn("Gagal mengirim data ke Discord Webhook: " .. tostring(response))
        end

        -- Mengirim update ke Discord setiap 10 menit (600 detik) sekali.
        -- JANGAN terlalu cepat agar akun Webhook Anda tidak terkena pembatasan limit (rate limit) oleh Discord.
        task.wait(600) 
    end
end)
