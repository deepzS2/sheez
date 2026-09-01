function parseNetworkInfo(output) {
    const lines = output
        .trim()
        .split("\n")
        .filter((line) => line.trim());
    let bestConnection = null;

    lines.forEach((line) => {
        const parts = line.split(":");
        if (parts.length < 4) return;

        const [typeRaw, state, connection, device] = parts;
        const type = typeRaw.toLowerCase();

        if (state !== "connected") return;

        // Prefer ethernet over wifi
        if (type === "ethernet" || (type === "wifi" && !bestConnection)) {
            bestConnection = {
                type,
                connection,
                device,
            };
        }
    });

    return bestConnection;
}

function parseDeviceDetails(output, connectionType) {
    const lines = output.trim().split("\n");
    let ipAddress = "";
    let essid = "";

    lines.forEach((line) => {
        const parts = line.split(":");
        if (parts.length < 2) return;

        const key = parts[0];
        const value = parts.slice(1).join(":");

        if (key === "IP4.ADDRESS[1]") {
            ipAddress = value.split("/")[0];
        } else if (key === "GENERAL.CONNECTION" && connectionType === "wifi") {
            essid = value;
        }
    });

    return {
        ipAddress,
        essid,
    };
}

function parseWiFiList(output, targetEssid) {
    const lines = output.trim().split("\n");

    const signalStrength = lines.reduce((found, line) => {
        if (found > 0) return found;

        const parts = line.split(":");
        if (parts.length >= 2) {
            const [ssid, signalStr] = parts;
            const signal = parseInt(signalStr);

            if (ssid === targetEssid && !isNaN(signal)) {
                return signal;
            }
        }
        return found;
    }, 0);

    return signalStrength;
}

function parseBandwidth(text, interfaceName) {
    const lines = text.split("\n");
    const interfaceLine = lines.find((line) =>
        line.trim().startsWith(interfaceName + ":"),
    );

    if (!interfaceLine) return null;

    const parts = interfaceLine.trim().split(/\s+/);
    if (parts.length < 10) return null;

    const rxBytes = parseInt(parts[1]);
    const txBytes = parseInt(parts[9]);

    return {
        rxBytes,
        txBytes,
    };
}

function formatBandwidth(bytesPerSecond) {
    if (bytesPerSecond === 0) return "0B";

    const units = ["B", "K", "M", "G"];
    const k = 1024;
    const i = Math.floor(Math.log(bytesPerSecond) / Math.log(k));

    return `${(bytesPerSecond / Math.pow(k, i)).toFixed(1)}${units[i]}`;
}

function formatBandwidthBits(bitsPerSecond) {
    if (bitsPerSecond === 0) return "0b";

    const units = ["b", "K", "M", "G"];
    const k = 1000;
    const i = Math.floor(Math.log(bitsPerSecond) / Math.log(k));

    return `${(bitsPerSecond / Math.pow(k, i)).toFixed(1)}${units[i]}`;
}
