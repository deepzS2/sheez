pragma Singleton

import QtQuick
import Quickshell
import qs.widgets
import qs.commons

Singleton {
    id: root

    property Component tooltipComponent: Component {
        Tooltip {}
    }

    property var tooltipInstance: null

    Component.onCompleted: {
        tooltipInstance = tooltipComponent.createObject(null);
        Logger.infof("TooltipService", "Tooltip instance created successfully");
    }

    function show(text, targetItem, options = {}) {
        if (!tooltipInstance) {
            Logger.errorf("TooltipService", "Tooltip instance not available - cannot show tooltip: {0}", text);
            return;
        }

        if (!targetItem) {
            Logger.warnf("TooltipService", "Invalid target item for tooltip: {0}", text);
            return;
        }

        Logger.debugf("TooltipService", "Showing tooltip: \"{0}\" (length: {1})", text, text.length);
        logConfiguration();

        // Set tooltip properties from options
        tooltipInstance.alignment = options.alignment || "center";
        tooltipInstance.vertical = options.vertical || "auto";
        tooltipInstance.customMaxWidth = options.maxWidth || 300;
        tooltipInstance.additionalOffsetX = options.offsetX || 0;
        tooltipInstance.additionalOffsetY = options.offsetY || 0;
        tooltipInstance.forcePosition = options.forcePosition || false;

        // Hide any existing tooltip first
        if (tooltipInstance.visible) {
            Logger.debug("TooltipService", "Hiding existing tooltip before showing new one");
            tooltipInstance.hideTooltip();
        }

        tooltipInstance.showTooltip(text, targetItem);
    }

    function hide() {
        if (tooltipInstance?.visible) {
            Logger.debug("TooltipService", "Hiding currently visible tooltip");
            tooltipInstance.hideTooltip();
        } else {
            Logger.debug("TooltipService", "No tooltip currently visible to hide");
        }
    }

    function logConfiguration() {
        Logger.info("TooltipService", "Configuration Overview");

        const config = [
            {
                property: "alignment",
                value: tooltipInstance?.alignment || "N/A",
                type: "string"
            },
            {
                property: "vertical",
                value: tooltipInstance?.vertical || "N/A",
                type: "string"
            },
            {
                property: "maxWidth",
                value: tooltipInstance?.customMaxWidth || "N/A",
                type: "number"
            },
            {
                property: "offsetX",
                value: tooltipInstance?.additionalOffsetX || "N/A",
                type: "number"
            },
            {
                property: "offsetY",
                value: tooltipInstance?.additionalOffsetY || "N/A",
                type: "number"
            },
            {
                property: "forcePosition",
                value: tooltipInstance?.forcePosition || false,
                type: "boolean"
            },
            {
                property: "visible",
                value: tooltipInstance?.visible || false,
                type: "boolean"
            }
        ];

        Logger.table(config, ["property", "value", "type"]);
    }
}
