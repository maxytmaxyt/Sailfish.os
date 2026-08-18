/****************************************************************************
**
** Copyright (C) 2026 Jolla Mobile Ltd
**
****************************************************************************/

import QtQuick 2.6
import org.nemomobile.lipstick 0.1
import QtQuick.Window 2.1 as QtQuick
import Sailfish.Silica 1.0
import com.jolla.lipstick 0.1

WindowWrapper {
    id: wrapper

    property real requestedScale: Math.max(1, Desktop.settings.xdg_window_scale)
    property int requestedOrientation: QtQuick.Screen.primaryOrientation
    property int requestedAngle: QtQuick.Screen.angleBetween(requestedOrientation,
                                                             clientOrientation)
    property bool requestedTransposed: requestedAngle % 180 != 0
    property int cornerAvoidance: 0.5 * Math.max(Screen.topLeftCorner.radius,
                                                 Screen.topRightCorner.radius,
                                                 Screen.bottomLeftCorner.radius,
                                                 Screen.bottomRightCorner.radius)
    property int keyboardAvoidance: Lipstick.compositor.keyboardHeight
    property int topAvoidance: Math.max(effectiveAngle == 180 ? keyboardAvoidance : 0,
                                        cornerAvoidance, Screen.topCutout.height)
    property int bottomAvoidance: Math.max(effectiveAngle == 0 ? keyboardAvoidance : 0,
                                           cornerAvoidance)
    property int leftAvoidance: effectiveAngle == 90 ? keyboardAvoidance : 0
    property int rightAvoidance: effectiveAngle == 270 ? keyboardAvoidance : 0

    property size maxSize: {
        var availWidth = wrapper.width - leftAvoidance - rightAvoidance
        var availHeight = wrapper.height - topAvoidance - bottomAvoidance

        var w = requestedTransposed ? availHeight : availWidth
        var h = requestedTransposed ? availWidth : availHeight

        return Qt.size(w / requestedScale, h / requestedScale)
    }

    property int effectiveAngle: QtQuick.Screen.angleBetween(orientation, clientOrientation)
    property bool effectiveTransposed: effectiveAngle % 180 != 0

    property bool _reconfiguring
    property bool _resizing

    width: Lipstick.compositor.width
    height: Lipstick.compositor.height

    // Start a transition when the window is rotated or scaled. The window will
    // first be faded out, and it will be faded in immediately if no resize is
    // needed or stay hidden until the client acknowledges the new size.
    onRequestedAngleChanged: _reconfiguring = true
    onRequestedScaleChanged: _reconfiguring = true
    onMaxSizeChanged: {
        _resizing = true
        if (!_reconfiguring) {
            window.surface.requestSize(maxSize)
        }
    }

    function updateOrientation() {
        if (!Desktop.settings.xdg_window_rotation) {
            return
        }

        if (Lipstick.compositor.screenOrientation != Qt.InvertedPortraitOrientation
            || Screen.sizeCategory >= Screen.Large) {
            requestedOrientation = Lipstick.compositor.screenOrientation
        }
    }

    Component.onCompleted: {
        updateOrientation()
        window.surface.requestSize(maxSize)
    }

    Connections {
        target: Lipstick.compositor
        onScreenOrientationChanged: updateOrientation()
    }

    Connections {
        target: window
        onResizeAcked: {
            _resizing = false
            _reconfiguring = false
        }
    }

    Binding {
        target: window
        property: "bufferScale"
        value: requestedScale
    }

    Binding {
        target: window
        property: "popupArea"
        value: Qt.rect(0, 0, maxSize.width, maxSize.height)
    }

    Binding {
        target: window
        property: "rotation"
        value: effectiveAngle
    }

    Binding {
        target: window
        property: "x"
        value: (effectiveAngle == 90 || effectiveAngle == 180)
                ? (wrapper.width - rightAvoidance) : leftAvoidance
    }

    Binding {
        target: window
        property: "y"
        value: (effectiveAngle == 180 || effectiveAngle == 270)
                ? (wrapper.height - bottomAvoidance) : topAvoidance
    }

    Rectangle {
        anchors.fill: parent
        z: -1
        color: "black"
    }

    Timer {
        id: resizeTimer

        interval: 1000
        onTriggered: {
            _resizing = false
            _reconfiguring = false
        }
    }

    states: [
        State {
            name: "reconfiguring"
            when: _reconfiguring

            PropertyChanges {
                target: wrapper
                explicit: true
                orientation: wrapper.orientation
            }

            PropertyChanges {
                target: window
                explicit: true
                scale: window.scale
            }

            PropertyChanges {
                target: resizeTimer
                running: _resizing
            }
        },
        State {
            when: !_reconfiguring

            PropertyChanges {
                target: wrapper
                orientation: requestedOrientation
            }

            PropertyChanges {
                target: window
                scale: requestedScale
            }

            PropertyChanges {
                target: resizeTimer
                running: false
            }
        }
    ]

    transitions: [
        Transition {
            to: "reconfiguring"

            SequentialAnimation {
                FadeAnimation { target: wrapper; to: 0.0 }
                ScriptAction {
                    script: {
                        if (window && _resizing) {
                            window.surface.requestSize(maxSize)
                        } else {
                            _reconfiguring = false
                        }
                    }
                }
            }
        },
        Transition {
            from: "reconfiguring"

            SequentialAnimation {
                PropertyAction { target: wrapper; property: "orientation" }
                PropertyAction { target: window; property: "scale" }
                FadeAnimation { target: wrapper; to: 1.0 }
            }
        }
    ]
}
