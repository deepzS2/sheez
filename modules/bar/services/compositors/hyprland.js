function parseWorkspaces(output) {
    const data = JSON.parse(output);
    if (!Array.isArray(data))
        throw new Error("Invalid Hyprland Workspaces Output");

    return data
        .sort((a, b) => a.id - b.id)
        .map((item) => ({
            id: item.id,
            name: item.name || "",
            // Filled in by markActiveWorkspace once the active-workspace query returns
            isActive: false,
            isUrgent: item.urgent || false,
            isOccupied: item.windows > 0,
        }));
}

function markActiveWorkspace(workspaces, activeId) {
    return workspaces.map((workspace) => ({
        id: workspace.id,
        name: workspace.name,
        isActive: workspace.id === activeId,
        isUrgent: workspace.isUrgent,
        isOccupied: workspace.isOccupied,
    }));
}

function parseFocusedWindow(output) {
    const data = JSON.parse(output);
    if (!Array.isArray(data))
        throw new Error("Invalid Hyprland Clients Output");

    const focusedWindow = data.find((client) => client.focused === true);

    return focusedWindow
        ? {
              title: focusedWindow.title || "",
              // Hyprland uses 'class' instead of 'app_id'
              appId: focusedWindow.class || "",
              isFocused: true,
          }
        : {
              title: "",
              appId: "",
              isFocused: false,
          };
}

function parseActiveWorkspaceId(output) {
    const data = JSON.parse(output);
    if (!data || typeof data.id === "undefined")
        throw new Error("Invalid Hyprland Active Workspace Output");

    return data.id;
}

function parseEventTargets(output) {
    const workspaceEvents = [
        "workspace",
        "focusedmon",
        "createworkspace",
        "destroyworkspace",
    ];
    const windowEvents = [
        "activewindow",
        "closewindow",
        "openwindow",
        "movewindow",
    ];
    const targets = { workspaces: false, windows: false };

    for (const line of output.split("\n")) {
        if (!line.includes(">>")) continue;

        const [eventType] = line.split(">>", 2);
        if (workspaceEvents.includes(eventType)) targets.workspaces = true;
        else if (windowEvents.includes(eventType)) targets.windows = true;
    }

    return targets;
}
