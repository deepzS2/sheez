// Tag indexes are per-output (two outputs can both have tag 1), so the
// workspace id is a composite "monitor:index". The active client of each
// monitor is joined onto its active tag as `activeWindow` by MangoService.
function parseWorkspaces(output) {
    const { all_tags: allTags } = JSON.parse(output);

    return allTags.reduce(
        (acc, monitorTags) =>
            acc.concat(
                monitorTags.tags.map((tag) => ({
                    id: `${monitorTags.monitor}:${tag.index}`,
                    output: monitorTags.monitor,
                    name: "",
                    isActive: tag["is_active"],
                    isUrgent: tag["is_urgent"],
                    isOccupied: (tag["client_count"] || 0) > 0,
                })),
            ),
        [],
    );
}

function parseMonitors(output) {
    const { monitors } = JSON.parse(output);

    return monitors.map((monitor) => ({
        name: monitor.name,
        activeClient: monitor.active_client
            ? {
                  title: monitor.active_client.title || "",
                  appId: monitor.active_client.appid || "",
              }
            : null,
    }));
}
