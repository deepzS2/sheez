function parseWorkspaces(output) {
    const data = JSON.parse(output);
    if (!Array.isArray(data)) throw new Error("Invalid Niri Workspaces Output");

    return data
        .sort((a, b) => a.idx - b.idx)
        .map((item) => ({
            id: item.id,
            output: item.output ?? "",
            name: item.name ?? "",
            isActive: item.is_active ?? false,
            isUrgent: item.is_urgent ?? false,
            isOccupied: !Number.isNaN(item.is_occupied),
            activeWindowId: item.active_window_id ?? null,
        }));
}

// Full window list; joined into workspaces as `activeWindow` by NiriService
function parseWindows(output) {
    const data = JSON.parse(output);
    if (!Array.isArray(data)) throw new Error("Invalid Niri Windows Output");

    return data.map((item) => ({
        id: item.id,
        title: item.title || "",
        appId: item.app_id || "",
    }));
}

function parseEventName(output) {
    const data = JSON.parse(output);
    return Object.keys(data)?.[0];
}

function eventTargets(eventName) {
    const workspaceEvents = ["WorkspacesChanged", "WorkspaceActivated"];
    const windowEvents = [
        "WindowOpenedOrChanged",
        "WindowClosed",
        "WindowFocusChanged",
    ];

    return {
        workspaces: workspaceEvents.includes(eventName),
        windows: windowEvents.includes(eventName),
    };
}
