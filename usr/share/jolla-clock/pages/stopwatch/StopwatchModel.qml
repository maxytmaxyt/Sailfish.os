import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.clock.private 1.0

ListModel {
    id: stopwatch

    property int totalTime
    property alias running: stopwatchTimer.running
    property bool hourMode: totalTime > 3600000 // an hour in milliseconds
    property ElapsedTimer timer: ElapsedTimer {}
    property int previousLapsAccumulator // total time from previous laps
    property int currentLapAccumulator // current lap before the last pause

    ListElement { time: 0; splitTime: 0; lap: 1 }

    function start() {
        if (!running) {
            timer.start()
            running = true
        }
    }
    function pause() {
        running = false
        currentLapAccumulator += timer.getMilliseconds()
        timer.reset()
    }
    function nextLap() {
        var currentLap = currentLapAccumulator + timer.restart()
        get(0).time = currentLap
        get(0).splitTime = currentLap + previousLapsAccumulator
        previousLapsAccumulator += currentLap
        currentLapAccumulator = 0
        insert(0, {"time": 0, "splitTime": 0, "lap": count + 1 })
    }
    function reset() {
        pause()
        clear()
        append({"time": 0, "splitTime": 0, "lap": 1 })
        totalTime = 0
        previousLapsAccumulator = 0
        currentLapAccumulator = 0
        timer.reset()
    }
    function formatTime(milliseconds) {
        var dateTime = new Date()
        dateTime.setMinutes(0)
        dateTime.setHours(0)
        dateTime.setSeconds(0)
        dateTime.setMilliseconds(milliseconds)
        var centiseconds = Math.floor(milliseconds/10) % 100
        var centisecondsString = centiseconds.toLocaleString()
        while (centisecondsString.length < 2) {
            var zero = 0
            centisecondsString = zero.toLocaleString() + centisecondsString
        }
        if (stopwatch.hourMode) {
            return Qt.formatDateTime(dateTime, "hh.mm:ss.") + centisecondsString
        } else {
            return Qt.formatDateTime(dateTime, "mm:ss.") + centisecondsString
        }
    }

    property Timer _timer: Timer {
        id: stopwatchTimer

        interval: 10
        repeat: true
        onTriggered: {
            var current = timer.getMilliseconds()
            totalTime = previousLapsAccumulator + currentLapAccumulator + current
            get(0).time = currentLapAccumulator + current
            get(0).splitTime = totalTime
        }
    }
}
