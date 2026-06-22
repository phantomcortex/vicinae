import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Flickable {
    id: root
    contentWidth: width
    contentHeight: outer.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    readonly property var model: settings.generalModel

    ScrollBar.vertical: ViciScrollBar {
        policy: root.contentHeight > root.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
    }

    ColumnLayout {
        id: outer
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(root.width - 48, 720)
        spacing: 0

        SettingsSectionLabel {
            text: "Behavior"
            Layout.topMargin: 24
            Layout.bottomMargin: 10
        }

        SettingsGroup {
            SettingsRow {
                visible: settings.globalShortcutsSupported
                label: "Launcher hotkey"
                description: "Global shortcut to toggle the Vicinae launcher."
                ShortcutField {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    bordered: false
                    shortcutId: GlobalShortcuts.toggleId
                    shortcut: root.model.toggleShortcut
                    onAccepted: shortcut => root.model.toggleShortcut = shortcut
                    onCleared: root.model.toggleShortcut = ""
                }
            }

            SettingsRow {
                label: "Close on focus loss"
                SettingsToggle {
                    checked: root.model.closeOnFocusLoss
                    onToggled: checked => root.model.closeOnFocusLoss = checked
                }
            }

            SettingsRow {
                label: "Close on Escape"
                description: "Pressing Escape closes the launcher instead of navigating one view back."
                SettingsToggle {
                    checked: root.model.closeOnEscape
                    onToggled: checked => root.model.closeOnEscape = checked
                }
        SettingsRow {
            id: uiScaleRow
            label: "UI scale"
            // Bounds for the screen this settings window is on. Re-evaluates if it moves to another
            // monitor. Returns the static [0.8;2.5] range when dynamic bounds are disabled.
            readonly property var scaleBounds: Config.scaleBoundsForScreen(Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)
            function clampToScreen(raw) {
                const v = parseFloat(raw);
                if (isNaN(v))
                    return root.model.uiScale;
                return Math.max(scaleBounds[0], Math.min(scaleBounds[1], v)).toFixed(2);
            }
            description: "Uniform zoom for the whole interface. Takes effect after restarting Vicinae. The window is always kept within the screen. On this screen: " + scaleBounds[0].toFixed(1) + "–" + scaleBounds[1].toFixed(1) + "."
            FormTextInput {
                width: parent.width
                text: root.model.uiScale
                placeholder: "e.g. 1.0"
                onAccepted: root.model.uiScale = uiScaleRow.clampToScreen(text)
                onEditingChanged: {
                    if (!editing)
                        root.model.uiScale = uiScaleRow.clampToScreen(text);
                }
            }
        }

        SettingsRow {
            label: "Dynamic scale bounds"
            description: "Narrow the UI scale range to fit the current screen and desktop scaling. When off, the full [0.8;2.5] range is allowed."
            SettingsToggle {
                checked: root.model.dynamicScaleBounds
                onToggled: root.model.dynamicScaleBounds = checked
            }
        }

        SettingsRow {
            visible: settings.globalShortcutsSupported
            label: "Launcher hotkey"
            description: "Global shortcut to toggle the Vicinae launcher."
            ShortcutField {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                bordered: false
                shortcutId: GlobalShortcuts.toggleId
                shortcut: root.model.toggleShortcut
                onAccepted: shortcut => root.model.toggleShortcut = shortcut
                onCleared: root.model.toggleShortcut = ""
            }

            SettingsRow {
                label: "Pop to root on close"
                description: "Reset the navigation state when the launcher window is closed."
                SettingsToggle {
                    checked: root.model.popToRootOnClose
                    onToggled: root.model.popToRootOnClose = checked
                }
            }

            SettingsRow {
                label: "Compact mode"
                description: "Show only the search bar at root; expand when a query is entered."
                showSeparator: false
                SettingsToggle {
                    checked: root.model.compactMode
                    onToggled: root.model.compactMode = checked
                }
            }
        }

        SettingsSectionLabel {
            text: "Privacy"
            Layout.topMargin: 24
            Layout.bottomMargin: 10
        }

        SettingsGroup {
            SettingsRow {
                label: "Basic usage statistics"
                description: "Send basic system and vicinae installation information on startup to help improve Vicinae."
                showSeparator: false
                SettingsToggle {
                    checked: root.model.telemetrySystemInfo
                    onToggled: root.model.telemetrySystemInfo = checked
                }
            }
        }

        Item {
            Layout.preferredHeight: 24
        }
    }
}
