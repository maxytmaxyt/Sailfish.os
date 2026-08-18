/*
 * Copyright (c) 2013 - 2021 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Calculator 1.0

Page {
    id: calculatorPage

    property Item advancedPanel: calculatorPanel.advancedPanel

    focus: true

    Keys.onPressed: {
        if (event.text.length === 1 && "0123456789".indexOf(event.text) >= 0) {
            // TODO: could also support non-latin numbers if locale uses those
            activeCalculation.insert(event.text)
        } else if (event.text === Qt.locale().decimalPoint) {
            activeCalculation.insert(event.text)
        } else if (event.text === "+") {
            activeCalculation.add()
        } else if (event.text === "-") {
            activeCalculation.subtract()
        } else if (event.text === "/") {
            activeCalculation.divide()
        } else if (event.text === "*") {
            activeCalculation.multiply()
        } else if (event.text === "(") {
            activeCalculation.openBracket()
        } else if (event.text === ")") {
            activeCalculation.closeBracket()
        } else if (event.text === "e") {
            activeCalculation.setConstant(Calculation.E)
        } else if (event.text === "!") {
            activeCalculation.factorial()
        } else if (event.text === "^") {
            activeCalculation.power()
        } else if (event.modifiers ===  Qt.ControlModifier && event.key === Qt.Key_V) {
            activeCalculation.paste()
        } else {
            switch (event.key) {
            case Qt.Key_Backspace:
                activeCalculation.backspace()
                break
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Equal:
                activeCalculation.calculate()
                break
            }
        }
    }

    MouseArea {
        id: dragArea

        anchors.fill: parent
        drag {
            target: advancedPanel
            axis: Drag.YAxis
            minimumY: -advancedPanel.maximumHeight
            maximumY: 0
            filterChildren: true
        }

        MouseArea {
            enabled: calculatorPage.isPortrait && !advancedPanel.animating
            anchors {
                top: parent.top
                bottom: calculatorPanel.top
                bottomMargin: calculatorPage.isPortrait ? advancedPanel.height : 0
                right: parent.right
                left: parent.left
            }
            Behavior on height {
                enabled: advancedPanel.animating
                NumberAnimation { easing.type: Easing.InOutQuad; duration: advancedPanel.animationDuration }
            }

            CalculationsListView {
                id: calculationsListView

                anchors.fill: parent
                clip: true

                // view autoscroll implementation
                property real equationY
                property real equationHeight

                // store the position of focused equation as delegates
                // can get destroyed when moved outside the view port
                function calculateAutoScrollPosition() {
                    if (focusEquation) {
                        equationY = contentItem.mapFromItem(focusEquation, 0, 0).y
                        equationHeight = focusEquation.height
                    }
                }

                function autoScroll() {
                    var _equationY = mapFromItem(contentItem, 0, equationY).y
                    var scrollMargin = 0
                    var animate = false
                    if (_equationY < scrollMargin) {
                        animate = true
                        autoScrollAnimation.to = Math.max(originY, contentY + _equationY - scrollMargin)
                    } else if (_equationY + equationHeight + scrollMargin > height) {
                        animate = true
                        autoScrollAnimation.to = Math.min(originY + contentHeight - height,
                                                          contentY + _equationY + equationHeight + scrollMargin - height)
                    }
                    if (animate && !moving) {
                        autoScrollAnimation.restart()
                    }
                }

                onFocusEquationChanged: positionTimer.restart()
                Component.onCompleted: positionTimer.restart()
                onMovingChanged: if (moving) autoScrollAnimation.stop()

                Timer {
                    id: positionTimer

                    interval: 10
                    onTriggered: parent.calculateAutoScrollPosition()
                }
                NumberAnimation {
                    id: autoScrollAnimation

                    easing.type: Easing.InOutQuad
                    target: calculationsListView
                    property: "contentY"
                    duration: 400
                }
            }
        }

        ScientificCalculatorHint {
            id: hint

            width: parent.width
            anchors {
                top: parent.top
                bottom: calculatorPanel.top
                bottomMargin: advancedPanel.height
            }
        }

        CalculatorPanel {
            id: calculatorPanel

            onButtonClicked: calculationsListView.autoScroll()
            onMenuClosed: positionTimer.restart()
            onClear: calculations.clear()

            calculation: activeCalculation
            anchors.bottom: parent.bottom
        }
    }
}
