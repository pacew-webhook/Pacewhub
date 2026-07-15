local request_func = (syn and syn.request) or (http and http.request) or http_request or request
if not request_func then return end

-- ⚠️ Ganti dengan link Webhook Channel Discord Anda sendiri
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1526967957354451036/3sOJpYogicwGYAwAyV9ZrlH0yHCj970hqyU_ymxbcDsw-i9fMdxPUHaP9lARV-hlvRQm"
local LocalPlayer = game.Players.LocalPlayer

task.spawn(function()
    while true do
        local shekelsValue = 0
        pcall(function()
            if LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Shekels") then
                shekelsValue = LocalPlayer.leaderstats.Shekels.Value
            end
        end)

        -- Membuat tampilan kartu informasi (Embed) di Discord
        local embedPayload = {
            ["username"] = "Roblox Account Monitor",
            ["embeds"] = {
                {
                    ["title"] = "📈 Bot Status Report",
                    ["color"] = 3066993, -- Warna Hijau Teal
                    ["fields"] = {
                        { ["name"] = "Username Bot", ["value"] = "👤 " .. LocalPlayer.Name, ["inline"] = true },
                        { ["name"] = "ID Akun", ["value"] = "🆔 " .. tostring(LocalPlayer.UserId), ["inline"] = true },
                        { ["name"] = "Total Koin", ["value"] = "💰 " .. tostring(shekelsValue), ["inline"] = false }
                    },
                    ["footer"] = { ["text"] = "Dikirim otomatis • Waktu: " .. os.date("%X") }
                }
            }
        }

        pcall(function()
            request_func({
                Url = DISCORD_WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(embedPayload)
            })
        end)

        -- JEDA PENGIRIMAN: Gunakan jeda minimal 5-10 menit (300-600 detik) untuk Discord 
        -- agar Webhook Anda tidak diblokir sementara (rate-limited) oleh sistem Discord.
        task.wait(300) 
    end
end)
