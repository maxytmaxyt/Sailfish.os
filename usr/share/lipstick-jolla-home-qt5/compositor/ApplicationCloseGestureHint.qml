import QtQuick 2.6
import Sailfish.Silica 1.0

Loader {
    readonly property bool hinting: item && item.hinting
    property int acceptMargin: Theme.itemSizeMedium

    anchors.fill: parent

    sourceComponent: Component {
        Item {
            readonly property int maxLoops: Number.MAX_VALUE
            property int loopsRun
            readonly property bool hinting: leftHint.running || rightHint.running
            readonly property bool finished: !hinting && !labelAnimator.running

            onFinishedChanged: {
                if (finished) {
                    active = false
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {}
                onPressAndHold: {}
            }

            InteractionHintLabel {
                id: hintLabel

                anchors {
                    left: parent.left
                    leftMargin: acceptMargin
                    right: parent.right
                    rightMargin: acceptMargin
                }

                invert: true
                opacity: hinting ? 1.0 : 0.0
                Behavior on opacity {
                    FadeAnimator {
                        id: labelAnimator
                        duration: 600
                    }
                }

                //: Put the emphasis on the close verb as that's the swipe action that this hint shows.
                //% "Close the app by swiping from the corners"
                //: iPhone-style: swipe from left edge to go back
                //% "Go back by swiping from the left edge"
                text: qsTrId("lipstick-jolla-home-la-iphone_back_gesture_hint")
            }

            Rectangle {
                height: parent.height / 2
                width: acceptMargin
                opacity: hinting ? Theme.opacityOverlay : 0.0
                Behavior on opacity { FadeAnimator { duration: 600 } }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, Theme.opacityHigh) }
                    GradientStop { position: 0.8; color: "transparent" }
                }
            }

            // iPhone-style: right-edge highlight removed (no right back gesture)
            Rectangle {
                anchors.right: parent.right
                height: parent.height / 2
                width: acceptMargin
                opacity: 0.0  // hidden: iPhone has no right-edge back gesture
                Behavior on opacity { FadeAnimator { duration: 600 } }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, Theme.opacityHigh) }
                    GradientStop { position: 0.8; color: "transparent" }
                }
            }

            TouchInteractionHint {
                id: leftHint

                // iPhone-style: Back gesture hint - swipe RIGHT from left edge
                direction: TouchInteraction.Right
                interactionMode: TouchInteraction.EdgeSwipe
                loops: 1
                alwaysRunToEnd: true
                running: loopsRun % 2 == 1 && loopsRun < maxLoops
                anchors {
                    horizontalCenter: undefined
                    left: parent.left
                    leftMargin: Math.max(Theme.paddingSmall, (acceptMargin - width) / 2)
                }

                onRunningChanged: {
                    if (!running) {
                        ++loopsRun
                    }
                }
            }

            TouchInteractionHint {
                id: rightHint

                // iPhone-style: second hint hidden (no right-edge back gesture on iPhone)
                direction: TouchInteraction.Right
                interactionMode: TouchInteraction.EdgeSwipe
                loops: 1
                running: false  // disabled: iPhone has no right-edge back gesture
                alwaysRunToEnd: true
                anchors {
                    horizontalCenter: undefined
                    right: parent.right
                    rightMargin: Math.max(Theme.paddingSmall, (acceptMargin - width) / 2)
                }

                onRunningChanged: {
                    if (!running) {
                        ++loopsRun
                    }
                }
            }

            Button {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 4 * Theme.paddingLarge
                    horizontalCenter: parent.horizontalCenter
                }

                //: Should be the same as tutorial-bt-got_it
                //% "Got it!"
                text: qsTrId("lipstick-jolla-home-bt-got_it")

                opacity: hinting ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator { duration: 600 } }

                onClicked: loopsRun = maxLoops
            }
        }
    }
}