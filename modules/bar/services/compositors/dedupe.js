function workspacesEqual(current, previous) {
    if (!current || !previous || current.length !== previous.length)
        return false;

    return current.every((workspace, index) => {
        const other = previous[index];
        const activeWindowEqual =
            (workspace.activeWindow?.title ?? "") === (other.activeWindow?.title ?? "") &&
            (workspace.activeWindow?.appId ?? "") === (other.activeWindow?.appId ?? "");

        return (
            workspace.id === other.id &&
            workspace.output === other.output &&
            workspace.name === other.name &&
            workspace.isActive === other.isActive &&
            workspace.isUrgent === other.isUrgent &&
            workspace.isOccupied === other.isOccupied &&
            activeWindowEqual
        );
    });
}

function monitorsEqual(current, previous) {
    if (!current || !previous || current.length !== previous.length)
        return false;

    return current.every((monitor, index) => {
        const other = previous[index];
        const activeEqual =
            (monitor.activeClient?.title ?? "") === (other.activeClient?.title ?? "") &&
            (monitor.activeClient?.appId ?? "") === (other.activeClient?.appId ?? "");

        return monitor.name === other.name && activeEqual;
    });
}

function windowsEqual(current, previous) {
    if (!current || !previous || current.length !== previous.length)
        return false;

    return current.every((window, index) => {
        const other = previous[index];
        return (
            window.id === other.id &&
            window.title === other.title &&
            window.appId === other.appId
        );
    });
}
