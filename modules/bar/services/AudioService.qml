pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.commons

Singleton {
    id: root

    // Sink (speaker/headphones) properties
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real sinkVolume: sink?.audio?.volume || 0
    readonly property bool sinkMuted: sink?.audio?.muted || false
    readonly property string sinkIcon: {
        if (sinkMuted)
            return "";
        const vol = Math.round(sinkVolume * 100);
        if (vol <= 33)
            return "";
        if (vol <= 66)
            return "";
        return "";
    }
    readonly property string sinkTooltip: {
        const vol = Math.round(sinkVolume * 100);
        const status = sinkMuted ? "Muted" : `${vol}%`;
        return `Sink: ${status}`;
    }

    // Source (microphone) properties
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real sourceVolume: source?.audio?.volume || 0
    readonly property bool sourceMuted: source?.audio?.muted || false
    readonly property string sourceIcon: sourceMuted ? "" : ""
    readonly property string sourceTooltip: {
        const vol = Math.round(sourceVolume * 100);
        const status = sourceMuted ? "Muted" : `${vol}%`;
        return `Source: ${status}`;
    }

    // Sink methods
    function toggleSinkMute() {
        if (!sink) {
            Logger.warn("AudioService", "No sink available to toggle mute");
            return;
        }

        sink.audio.muted = !sink.audio.muted;
        Logger.debugf("AudioService", "Sink mute toggled to: {0}", sink.audio.muted);
    }

    function adjustSinkVolume(delta) {
        if (!sink) {
            Logger.warn("AudioService", "No sink available to adjust volume");
            return;
        }

        const newVolume = Math.max(0, Math.min(1, sink.audio.volume + delta));
        sink.audio.volume = newVolume;

        Logger.debugf("AudioService", "Sink volume adjusted to: {0}%", Math.round(newVolume * 100));
    }

    function setSinkVolume(volume) {
        if (!sink) {
            Logger.warn("AudioService", "No sink available to set volume");
            return;
        }

        sink.audio.volume = Math.max(0, Math.min(1, volume));
        Logger.debugf("AudioService", "Sink volume set to: {0}%", Math.round(volume * 100));
    }

    // Source methods
    function toggleSourceMute() {
        if (!source) {
            Logger.warn("AudioService", "No source available to toggle mute");
            return;
        }

        source.audio.muted = !source.audio.muted;
        Logger.debugf("AudioService", "Source mute toggled to: {0}", source.audio.muted);
    }

    function adjustSourceVolume(delta) {
        if (!source) {
            Logger.warn("AudioService", "No source available to adjust volume");
            return;
        }

        const newVolume = Math.max(0, Math.min(1, source.audio.volume + delta));
        source.audio.volume = newVolume;

        Logger.debugf("AudioService", "Source volume adjusted to: {0}%", Math.round(newVolume * 100));
    }

    function setSourceVolume(volume) {
        if (!source) {
            Logger.warn("AudioService", "No source available to set volume");
            return;
        }

        source.audio.volume = Math.max(0, Math.min(1, volume));
        Logger.debugf("AudioService", "Source volume set to: {0}%", Math.round(volume * 100));
    }

    // Launch pavucontrol
    function launchPavucontrol() {
        Quickshell.execDetached(["pavucontrol"]);
        Logger.info("AudioService", "Launched pavucontrol");
    }

    // Object trackers for automatic updates
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("AudioService", "Audio service initialized");
        Logger.debugf("AudioService", "Sink available: {0}", !!sink);
        Logger.debugf("AudioService", "Source available: {0}", !!source);
    }
}
