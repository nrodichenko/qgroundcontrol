/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.FlightMap     1.0

Item {
    property var    guidedActionsController

    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property real   _widgetHeight:  ScreenTools.defaultFontPixelHeight * 3
    property color  _textColor:     "black"
    property real   _rectOpacity:   0.8

    QGCPalette { id: qgcPal }

    Rectangle {
        id:             mvCommands
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         mvCommandsColumn.height + (_margin *2)
        color:          qgcPal.missionItemEditor
        opacity:        _rectOpacity
        radius:         _margin

        DeadMouseArea {
            anchors.fill: parent
        }

        Column {
            id:                 mvCommandsColumn
            anchors.margins:    _margin
            anchors.top:        parent.top
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin

            QGCLabel {
                anchors.left:   parent.left
                anchors.right:  parent.right
                text:           qsTr("The following commands will be applied to all vehicles")
                color:          _textColor
                wrapMode:       Text.WordWrap
                font.pointSize: ScreenTools.smallFontPointSize
            }

            Row {
                spacing:            _margin

                QGCButton {
                    text:       "Pause"
                    onClicked:  guidedActionsController.confirmAction(guidedActionsController.actionMVPause)
                }

                QGCButton {
                    text:       "Start Mission"
                    onClicked:  guidedActionsController.confirmAction(guidedActionsController.actionMVStartMission)
                }
            }
        }
    }

    QGCListView {
        id:                 missionItemEditorListView
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.topMargin:  _margin
        anchors.top:        mvCommands.bottom
        anchors.bottom:     parent.bottom
        spacing:            ScreenTools.defaultFontPixelHeight / 2
        orientation:        ListView.Vertical
        model:              QGroundControl.multiVehicleManager.vehicles
        cacheBuffer:        _cacheBuffer < 0 ? 0 : _cacheBuffer
        clip:               true

        property real _cacheBuffer:     height * 2

        delegate: Rectangle {
            width:      parent.width
            height:     innerColumn.y + innerColumn.height + _margin
            color:      qgcPal.missionItemEditor
            opacity:    _rectOpacity
            radius:     _margin

            property var    _vehicle:   object

            ColumnLayout {
                id:                 innerColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.left
                spacing:            _margin

                RowLayout {
                    Layout.fillWidth:       true
                    spacing: ScreenTools.defaultFontPixelWidth*2

                    QGCLabel {
                        Layout.alignment:   Qt.AlignCenter
                        text:               _vehicle ? _vehicle.id : ""
                        color:              _textColor
                    }

                    ColumnLayout {
                        Layout.alignment:   Qt.AlignCenter
                        spacing:            _margin

                        FlightModeMenu {
                            Layout.alignment:           Qt.AlignHCenter
                            font.pointSize:             ScreenTools.largeFontPointSize
                            color:                      _textColor
                            currentVehicle:             _vehicle
                        }

                        QGCLabel {
                            Layout.alignment:           Qt.AlignHCenter
                            text:                       _vehicle && _vehicle.armed ? qsTr("Armed") : qsTr("Disarmed")
                            color:                      _textColor
                        }
                    }

                    ColumnLayout {
                        Layout.alignment:   Qt.AlignCenter
                        spacing:            _margin

                        QGCLabel {
                            Layout.alignment:           Qt.AlignHCenter
                            font.pointSize:             ScreenTools.largeFontPointSize
                            text:                       _vehicle  ? _vehicle.altitudeAMSL.value.toFixed(1) : ""
                            color:                      _textColor
                        }

                        QGCLabel {
                            Layout.alignment:           Qt.AlignHCenter
                            text:                       "AMSL"
                            color:                      _textColor
                        }
                    }

                    ColumnLayout {
                        Layout.alignment:   Qt.AlignCenter
                        spacing:            _margin

                        QGCLabel {
                            property variant gnames: ["None","None","2D Lock","3D Lock","3D DGPS","RTK Float","RTK Fixed", "Static"]
                            Layout.alignment:           Qt.AlignHCenter
                            font.pointSize:             ScreenTools.largeFontPointSize
                            text:                       _vehicle  ? gnames[_vehicle.gps.lock.value] : ""
                            color:                      _textColor
                        }

                        QGCLabel {
                            Layout.alignment:           Qt.AlignHCenter
                            text:                       _vehicle  ? _vehicle.gps.count.value + " sats" : ""
                            color:                      _textColor
                        }
                    }

                } // RowLayout

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth
                    height: ScreenTools.defaultFontPixelHeight * 1.2

                    QGCButton {
                        height: parent.height
                        text:       "ARM"
                        visible:    _vehicle
                        onClicked:  {
                            if (_vehicle && !_vehicle.armed)
                                _vehicle.armed = true
                        }
                    }

                    QGCButton {
                        height: parent.height
                        text:       "LND"
                        visible:    _vehicle
                        onClicked:  _vehicle.flightMode = _vehicle.landFlightMode
                    }

                    QGCButton {
                        height: parent.height
                        text:       "OFB"
                        visible:    _vehicle
                        onClicked:  _vehicle.flightMode = _vehicle._offboardFlightMode
                    }

                    QGCButton {
                        height: parent.height
                        text:       "Reboot"
                        visible:    _vehicle
                        onClicked:  {
                            if (_vehicle && !_vehicle.armed)
                                _vehicle.rebootVehicle
                        }
                    }
                } // Row
            } // ColumnLayout
        } // delegate - Rectangle
    } // QGCListView
} // Item
