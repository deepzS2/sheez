function parseWorkspaces(output) {
    const { all_tags: allTags } = JSON.parse(output);

    // Mango tags have no names; they are identified by index alone
    return allTags
        .reduce(
            (workspaces, monitorTags) => workspaces.concat(monitorTags.tags),
            [],
        )
        .map((tag) => ({
            id: tag.index,
            name: "",
            isActive: tag["is_active"],
            isUrgent: tag["is_urgent"],
            isOccupied: (tag["client_count"] || 0) > 0,
        }));
}

function parseFocusedWindow(output) {
    const data = JSON.parse(output);

    return {
        title: data.title || "",
        appId: data.appid || "",
        isFocused: true,
    };
}
