// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Controls 1.4
import UM 1.3 as UM

/**
 * NOTE: For most labels, a fixed height with vertical alignment is used to make
 * layouts more deterministic (like the fixed-size textboxes used in original
 * mock-ups). This is also a stand-in for CSS's 'line-height' property. Denoted
 * with '// FIXED-LINE-HEIGHT:'.
 */
Item
{
    id: base

    // The print job which all other information is dervied from
    property var printJob: null

    width: childrenRect.width
    height: 18 * screenScaleFactor // TODO: Theme!

    ProgressBar
    {
        id: progressBar
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
        value: printJob ? printJob.progress : 0
        style: ProgressBarStyle
        {
            background: Rectangle
            {
                color: printJob && printJob.isActive ? "#e4e4f2" : "#f3f3f9" // TODO: Theme!
                implicitHeight: visible ? 8 * screenScaleFactor : 0 // TODO: Theme!
                implicitWidth: 180 * screenScaleFactor // TODO: Theme!
                radius: 4 * screenScaleFactor // TODO: Theme!
            }
            progress: Rectangle
            {
                id: progressItem;
                color: printJob && printJob.isActive ? "#0a0850" : "#9392b2" // TODO: Theme!
                radius: 4 * screenScaleFactor // TODO: Theme!
            }
        }
    }
    Label
    {
        id: percentLabel
        anchors
        {
            left: progressBar.right
            leftMargin: 18 * screenScaleFactor // TODO: Theme!
        }
        text: Math.round(printJob.progress * 100) + "%"
        color: printJob && printJob.isActive ? "#374355" : "#babac1" // TODO: Theme!
        width: contentWidth
        font: UM.Theme.getFont("medium") // 14pt, regular

        // FIXED-LINE-HEIGHT:
        height: 18 * screenScaleFactor // TODO: Theme!
        verticalAlignment: Text.AlignVCenter
    }
    Label
    {
        id: statusLabel
        anchors
        {
            left: percentLabel.right
            leftMargin: 18 * screenScaleFactor // TODO: Theme!
        }
        color: "#374355" // TODO: Theme!
        font: UM.Theme.getFont("medium") // 14pt, regular
        text:
        {
            if (!printJob)
            {
                return ""
            }
            switch (printJob.state)
            {
                case "wait_cleanup":
                    if (printJob.timeTotal > printJob.timeElapsed)
                    {
                        return catalog.i18nc("@label:status", "Aborted")
                    }
                    return catalog.i18nc("@label:status", "Finished")
                case "sent_to_printer":
                    return catalog.i18nc("@label:status", "Preparing...")
                case "pre_print":
                    return catalog.i18nc("@label:status", "Preparing...")
                case "aborting": // NOTE: Doesn't exist but maybe should someday
                    return catalog.i18nc("@label:status", "Aborting...")
                case "aborted": // NOTE: Unused, see above
                    return catalog.i18nc("@label:status", "Aborted")
                case "pausing":
                    return catalog.i18nc("@label:status", "Pausing...")
                case "paused":
                    return catalog.i18nc("@label:status", "Paused")
                case "resuming":
                    return catalog.i18nc("@label:status", "Resuming...")
                case "queued":
                    return catalog.i18nc("@label:status", "Action required")
                default:
                    return catalog.i18nc("@label:status", "Finishes %1 at %2".arg(OutputDevice.getDateCompleted( printJob.timeRemaining )).arg(OutputDevice.getTimeCompleted( printJob.timeRemaining )))
            }
        }
        width: contentWidth

        // FIXED-LINE-HEIGHT:
        height: 18 * screenScaleFactor // TODO: Theme!
        verticalAlignment: Text.AlignVCenter
    }
}