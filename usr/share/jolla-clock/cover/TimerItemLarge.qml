import QtQuick 2.0
import Sailfish.Silica 1.0
import "../common"
import "../common/DateUtils.js" as DateUtils

LargeItem {
    property QtObject timerClock
    // not used, just here to have common api with TimerItemSmall
    property real prePadding
    property real postPadding

    title: model.title
    text: {
        if (timerClock.remaining <= 60) {
            //% "in %n second(s)"
            return qsTrId("jolla-clock-la-in_n_seconds", timerClock.remaining)
        } else {
            return DateUtils.formatDuration(timerClock.remaining)
        }
    }
}
