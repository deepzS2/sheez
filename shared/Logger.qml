pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: logger

    enum Level {
        Debug,
        Info
    }

    property int logLevel: Quickshell.env("SHEEZ_DEBUG") ? Logger.Debug : Logger.Info
    property bool enableConsoleLogging: true
    property bool enableFileLogging: false
    property string logFile: ""

    property var _timers: ({})

    FileView {
        id: logFileView
        path: logger.logFile
        blockWrites: false
        atomicWrites: true
        printErrors: false
    }

    // === BASIC LOGGING API ===
    function debug(moduleOrMessage, ...args) {
        if (logLevel <= Logger.Debug) {
            const {
                module,
                messageArgs
            } = _parseModuleArg(moduleOrMessage, args);
            _log("DEBUG:", module, ...messageArgs);
        }
    }

    function info(moduleOrMessage, ...args) {
        if (logLevel <= Logger.Info) {
            const {
                module,
                messageArgs
            } = _parseModuleArg(moduleOrMessage, args);
            _log("INFO:", module, ...messageArgs);
        }
    }

    function warn(moduleOrMessage, ...args) {
        const {
            module,
            messageArgs
        } = _parseModuleArg(moduleOrMessage, args);
        _log("WARN:", module, ...messageArgs);
    }

    function error(moduleOrMessage, ...args) {
        const {
            module,
            messageArgs
        } = _parseModuleArg(moduleOrMessage, args);
        _log("ERROR:", module, ...messageArgs);
    }

    function debugf(moduleOrFormat, ...args) {
        if (logLevel <= Logger.Debug) {
            const {
                module,
                messageArgs
            } = _parseModuleArg(moduleOrFormat, args);
            _logWithVerbs("DEBUG:", module, ...messageArgs);
        }
    }

    function infof(moduleOrFormat, ...args) {
        if (logLevel <= Logger.Info) {
            const {
                module,
                messageArgs
            } = _parseModuleArg(moduleOrFormat, args);
            _logWithVerbs("INFO:", module, ...messageArgs);
        }
    }

    function warnf(moduleOrFormat, ...args) {
        const {
            module,
            messageArgs
        } = _parseModuleArg(moduleOrFormat, args);
        _logWithVerbs("WARN:", module, ...messageArgs);
    }

    function errorf(moduleOrFormat, ...args) {
        const {
            module,
            messageArgs
        } = _parseModuleArg(moduleOrFormat, args);
        _logWithVerbs("ERROR:", module, ...messageArgs);
    }

    // === ADVANCED FEATURES ===
    function time(label) {
        _timers[label] = Date.now();
    }

    function timeEnd(moduleOrLabel, ...args) {
        const {
            module,
            messageArgs
        } = _parseModuleArg(moduleOrLabel, args);
        const label = messageArgs[0];

        if (_timers.hasOwnProperty(label)) {
            const start = _timers[label];
            const duration = Date.now() - start;
            delete _timers[label];
            _logWithVerbs("INFO:", module, "{0}: {1}ms", label, duration);
        } else {
            _logWithVerbs("ERROR:", module, "Timer '{0}' does not exist", label);
        }
    }

    function table(moduleOrData, ...args) {
        const {
            module,
            messageArgs
        } = _parseModuleArg(moduleOrData, args);
        const data = messageArgs[0];
        const columns = messageArgs[1];

        if (!Array.isArray(data) || data.length === 0) {
            _log("INFO:", module, "(empty)");
            return;
        }

        // If columns not specified, use all keys from first object
        const columnNames = columns || Object.keys(data[0]);

        // Calculate column widths
        const colWidths = {};
        columnNames.forEach(col => {
            colWidths[col] = Math.max(col.length, ...data.map(row => String(row[col] || '').length));
        });

        // Create header and separator
        const header = columnNames.map(col => col.padEnd(colWidths[col])).join(' | ');
        const separator = columnNames.map(col => '-'.repeat(colWidths[col])).join('-+-');

        // Log table
        _log("INFO:", module, `  ${header}`);
        _log("INFO:", module, `  ${separator}`);

        data.forEach(row => {
            const rowStr = columnNames.map(col => String(row[col] || '').padEnd(colWidths[col])).join(' | ');
            _log("INFO:", module, `  ${rowStr}`);
        });
    }

    // === PRIVATE IMPLEMENTATION ===
    function _log(level, module, ...args) {
        const message = module ? _formatMessageWithModule(level, module, ...args) : _formatMessage(level, ...args);

        console.log(message);
        _writeToFile(_stripAnsiCodes(message));
    }

    function _logWithVerbs(level, module, ...args) {
        const message = module ? _formatMessageWithVerbsAndModule(level, module, ...args) : _formatMessageWithVerbs(level, ...args);

        console.log(message);
        _writeToFile(_stripAnsiCodes(message));
    }

    function _parseModuleArg(firstArg, remainingArgs) {
        if (typeof firstArg !== 'string') {
            return {
                module: null,
                messageArgs: [firstArg, ...remainingArgs]
            };
        }

        if (remainingArgs.length === 0) {
            return {
                module: null,
                messageArgs: [firstArg]
            };
        }

        if (typeof remainingArgs[0] === 'string') {
            return {
                module: firstArg,
                messageArgs: remainingArgs
            };
        }

        return {
            module: null,
            messageArgs: [firstArg, ...remainingArgs]
        };
    }

    function _writeToFile(message) {
        if (!enableFileLogging || !logFile)
            return;

        const currentContent = logFileView.loaded ? logFileView.text() : "";
        const newContent = currentContent + message + "\n";

        logFileView.setText(newContent);
    }

    function _formatMessage(level, ...args) {
        const maxLength = 14;
        const timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss");
        const levelStr = level.substring(0, maxLength).padEnd(maxLength, " ");
        const message = args.join(" ");

        return `\x1b[36m[${timestamp}]\x1b[0m \x1b[35m${levelStr}\x1b[0m ${message}`;
    }

    function _formatMessageWithModule(level, module, ...args) {
        const maxLength = 14;
        const timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss");
        const levelStr = level.substring(0, maxLength).padEnd(maxLength, " ");
        const moduleStr = `[${module}] `;
        const message = args.join(" ");

        return `\x1b[36m[${timestamp}]\x1b[0m \x1b[35m${levelStr}\x1b[0m ${moduleStr}${message}`;
    }

    function _formatMessageWithVerbs(level, ...args) {
        const maxLength = 14;
        const timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss");
        const levelStr = level.substring(0, maxLength).padEnd(maxLength, " ");
        const message = _parseFormatString(...args);

        return `\x1b[36m[${timestamp}]\x1b[0m \x1b[35m${levelStr}\x1b[0m ${message}`;
    }

    function _formatMessageWithVerbsAndModule(level, module, ...args) {
        const maxLength = 14;
        const timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss");
        const levelStr = level.substring(0, maxLength).padEnd(maxLength, " ");
        const moduleStr = `[${module}] `;
        const message = _parseFormatString(...args);

        return `\x1b[36m[${timestamp}]\x1b[0m \x1b[35m${levelStr}\x1b[0m ${moduleStr}${message}`;
    }

    // Handle positional arguments in logs with formatting
    function _parseFormatString(format, ...args) {
        if (args.length === 0)
            return format;

        return format.replace(/\{(\d+)\}/g, (match, index) => {
            const idx = parseInt(index);
            return idx < args.length ? String(args[idx]) : match;
        });
    }

    function _stripAnsiCodes(message) {
        return message.replace(/\x1b\[[0-9;]*m/g, '');
    }
}
