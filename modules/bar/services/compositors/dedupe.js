function workspacesEqual(current, previous) {
    if (!current || !previous || current.length !== previous.length)
        return false;

    return current.every((workspace, index) => {
        const other = previous[index];
        return (
            workspace.id === other.id &&
            workspace.name === other.name &&
            workspace.isActive === other.isActive &&
            workspace.isUrgent === other.isUrgent &&
            workspace.isOccupied === other.isOccupied
        );
    });
}

function windowsEqual(current, previous) {
    if (!current && !previous) return true;
    if (!current || !previous) return false;

    return (
        current.title === previous.title &&
        current.appId === previous.appId &&
        current.isFocused === previous.isFocused
    );
}
