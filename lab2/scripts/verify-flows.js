// Сквозная проверка потоков лабораторной работы №2.
//
// Node-RED отдаёт события панели Debug по WebSocket (ws://localhost:1880/comms).
// Скрипт подключается к нему, дёргает inject-ноды через Admin API
// (POST /inject/<id>) и собирает то, что реально дошло до debug-нод.
// Так проверяется вся цепочка целиком, а не только первая нода.
//
// Запуск:  node lab2/scripts/verify-flows.js
// Требует Node.js 21+ (нужен встроенный WebSocket).

const BASE = process.env.NODE_RED_URL || "http://localhost:1880";

// inject-ноды, которые нужно дёрнуть, и что это за пункт задания
const TRIGGERS = [
    ["f01_inject",    "2.1  inject -> debug"],
    ["f02_inj_num",   "2.2  function (число)"],
    ["f02_inj_str",   "2.2  function (строка)"],
    ["f02_inj_obj",   "2.2  function (объект)"],
    ["f03_inj_high",  "2.3  switch (avg >= 4)"],
    ["f03_inj_low",   "2.3  switch (avg < 4)"],
    ["f04_inject",    "2.4  change"],
    ["f05_inject",    "2.5  template"],
    ["f06_inject",    "2.6  http request"],
    ["f07_inj_pub",   "2.7  mqtt publish"],
    ["f11_inj_read",  "2.11 file in -> function"],
    ["f12_inj_tick",  "2.12 context"],
    ["f12_inj_reset", "2.12 context reset"]
];

// debug-ноды, которые обязаны сработать
const EXPECTED = [
    "Debug: complete msg",
    "Debug: результат функции",
    "ВЫХОД 1: avg >= 4",
    "ВЫХОД 2: otherwise (avg < 4)",
    "Debug: complete msg после change",
    "Debug: собранный JSON",
    "Debug: ответ API (complete msg)",
    "Debug: принято из топика",
    "Debug: содержимое файла + статистика",
    "Debug: контекст",
    "Debug: сброс",
    "Debug: показания датчика"
];

const received = [];
const seen = new Map();

const ws = new WebSocket(BASE.replace(/^http/, "ws") + "/comms");

ws.addEventListener("open", async () => {
    console.log("WebSocket /comms подключён\n");

    for (const [id, label] of TRIGGERS) {
        try {
            const res = await fetch(`${BASE}/inject/${id}`, { method: "POST" });
            console.log(`  ${id.padEnd(16)} ${res.status}   ${label}`);
        } catch (e) {
            console.log(`  ${id.padEnd(16)} ОШИБКА: ${e.message}`);
        }
        await new Promise((r) => setTimeout(r, 900));
    }

    console.log("\nСобираю сообщения из Debug (7 секунд, MQTT идёт через брокер)...");
    await new Promise((r) => setTimeout(r, 7000));
    ws.close();
});

ws.addEventListener("message", (event) => {
    let batch;
    try { batch = JSON.parse(event.data); } catch { return; }
    if (!Array.isArray(batch)) { batch = [batch]; }   // события приходят массивом

    for (const item of batch) {
        if (!item || item.topic !== "debug") { continue; }

        const d = item.data || {};
        const name = d.name || "(без имени)";

        // d.msg — это строка JSON, а не объект
        let msg = d.msg;
        if (typeof msg === "string") {
            try { msg = JSON.parse(msg); } catch { msg = { payload: msg }; }
        }
        msg = msg || {};

        received.push({ name, msg });
        seen.set(name, (seen.get(name) || 0) + 1);
    }
});

ws.addEventListener("close", () => {
    console.log("\n================ СОБРАНО ИЗ DEBUG ================\n");
    console.log(`Всего сообщений: ${received.length}\n`);

    console.log("--- по debug-нодам ---");
    for (const [name, count] of [...seen.entries()].sort()) {
        console.log(`  ${String(count).padStart(3)} x  ${name}`);
    }

    console.log("\n--- последнее сообщение каждой ноды ---");
    const last = new Map();
    for (const r of received) { last.set(r.name, r.msg); }
    for (const [name, msg] of [...last.entries()].sort()) {
        let pretty;
        try { pretty = JSON.stringify(msg.payload); } catch { pretty = String(msg.payload); }
        const short = pretty && pretty.length > 260 ? pretty.slice(0, 260) + "…" : pretty;
        console.log(`\n[${name}]`);
        if (msg.topic !== undefined) { console.log(`  topic:   ${msg.topic}`); }
        console.log(`  payload: ${short}`);
    }

    const missing = EXPECTED.filter((n) => !seen.has(n));
    console.log("\n================ ИТОГ ================");
    if (missing.length === 0) {
        console.log(`ВСЕ ОЖИДАЕМЫЕ DEBUG-НОДЫ ОТРАБОТАЛИ (${EXPECTED.length} из ${EXPECTED.length})`);
    } else {
        console.log("НЕ ОТРАБОТАЛИ: " + missing.join(", "));
    }
    process.exit(missing.length === 0 ? 0 : 1);
});

ws.addEventListener("error", (e) => {
    console.log("Ошибка WebSocket: " + (e.message || e));
    console.log("Node-RED запущен? Проверьте " + BASE);
    process.exit(1);
});
