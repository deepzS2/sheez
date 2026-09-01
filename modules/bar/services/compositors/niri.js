function parseWorkspaces(output) {
    const data = JSON.parse(output);
    if (!Array.isArray(data)) throw new Error("Invalid Niri Workspaces Output");

    return data
        .sort((a, b) => a.idx - b.idx)
        .map((item) => ({
            id: item.id,
            name: item.name ?? "",
            isActive: item.is_active ?? false,
            isUrgent: item.is_urgent ?? false,
            isOccupied: !Number.isNaN(item.is_occupied),
        }));
}

function parseFocusedWindow(output) {
    const data = JSON.parse(output);
    if (!Array.isArray(data)) throw new Error("Invalid Niri Windows Output");

    const focusedWindow = data.find((window) => window.is_focused);

    return {
        title: focusedWindow?.title || "",
        appId: focusedWindow?.app_id || "",
        isFocused: !!focusedWindow,
    };
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
