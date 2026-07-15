-- 1. DETEKSI HTTP REQUEST DARI EXECUTOR
local request_func = (syn and syn.request) or (http and http.request) or http_request or request

if not request_func then
    game.Players.LocalPlayer:Kick("Executor Anda tidak mendukung HTTP Requests! Gunakan executor lain.")
    return
end

-- 2. KONFIGURASI DATABASE
-- Ganti dengan URL Firebase Anda, akhiri dengan "/bots.json"
local FIREBASE_URL = "https://console.firebase.google.com/u/0/project/pacewhub/database/pacewhub-default-rtdb/data/~2F/bots.json"
local LocalPlayer = game.Players.LocalPlayer

-- 3. LOOP PENGIRIMAN DATA OTOMATIS
task.spawn(function()
    while true do
        -- Mengambil nilai Shekels dari leaderstats game secara real-time
        local shekels = 0
        local success_stats, err_stats = pcall(function()
            if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Shekels") then
                shekels = LocalPlayer.leaderstats.Shekels.Value
            end
        end)

        -- Membuat paket data (payload) JSON
        local payload = {
            [LocalPlayer.Name] = {
                name = LocalPlayer.Name,
                status = "online",
                farmRate = "x30.5K", -- Anda bisa ubah teks ini sesuai kebutuhan info farm Anda
                shekels = shekels,
                lastUpdated = os.time() -- Penanda waktu agar website tahu bot masih aktif
            }
        }

        -- Mengirimkan data ke Firebase
        local success, response = pcall(function()
            return request_func({
                Url = FIREBASE_URL,
                Method = "PATCH", -- Menggunakan PATCH agar tidak menimpa data akun bot lain
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)

        if success then
            print("Status Bot [" .. LocalPlayer.Name .. "] berhasil dikirim ke Firebase!")
        else
            warn("Gagal mengirim data: " .. tostring(response))
        end

        task.wait(10) -- Kirim update otomatis setiap 10 detik sekali
    end
end)
