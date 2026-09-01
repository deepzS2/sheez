function parseCpuTotals(text) {
    const cpuLine = text.split("\n").find((line) => line.startsWith("cpu "));
    if (!cpuLine) return null;

    const parts = cpuLine.trim().split(/\s+/);
    const user = parseInt(parts[1]);
    const nice = parseInt(parts[2]);
    const system = parseInt(parts[3]);
    const idle = parseInt(parts[4]);
    const iowait = parseInt(parts[5]);
    const irq = parseInt(parts[6]);
    const softirq = parseInt(parts[7]);

    return {
        total: user + nice + system + idle + iowait + irq + softirq,
        idle: idle + iowait,
    };
}

// CPU usage percentage since the previous reading, clamped to 0-100.
function cpuUsage(stats, previousStats) {
    const totalDiff = stats.total - previousStats.total;
    const idleDiff = stats.idle - previousStats.idle;

    const usage = ((totalDiff - idleDiff) / totalDiff) * 100;
    return Math.max(0, Math.min(100, usage));
}

// Memory usage percentage from /proc/meminfo, clamped to 0-100.
// Returns null when required fields are missing or zero.
function memoryUsage(text) {
    const { memTotal, memAvailable } = text.split("\n").reduce(
        (acc, line) => {
            const isMemTotal = line.startsWith("MemTotal");
            const isMemAvailable = line.startsWith("MemAvailable");

            if (!isMemTotal && !isMemAvailable) return acc;

            const value = Number.parseInt(line.split(/\s+/)[1]);

            return {
                memTotal: isMemTotal ? acc.memTotal + value : acc.memTotal,
                memAvailable: isMemAvailable
                    ? acc.memAvailable + value
                    : acc.memAvailable,
            };
        },
        {
            memTotal: 0,
            memAvailable: 0,
        },
    );

    if (!memTotal || !memAvailable) return null;

    const usage = ((memTotal - memAvailable) / memTotal) * 100;
    return Math.max(0, Math.min(100, usage));
}
