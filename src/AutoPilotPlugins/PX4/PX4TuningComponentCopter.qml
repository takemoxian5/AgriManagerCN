/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.3
import QtQuick.Controls     1.2

import QGroundControl.Controls  1.0

SetupPage {
    id:             tuningPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        FactSliderPanel {
            width:          availableWidth
            qgcViewPanel:   tuningPage.viewPanel

            sliderModel: ListModel {
                ListElement {
                    title:          qsTr("悬停油门")
                    description:    qsTr("调整油门以悬停在中间油门. 如果悬停油门比中心低，就向左边滑动. 如果悬停油门比中心高，就向右边滑动.")
                    param:          "MPC_THR_HOVER"
                    min:            20
                    max:            80
                    step:           1
                }

                ListElement {
                    title:          qsTr("手动悬停最小油门")
                    description:    qsTr("向左滑，启动马达，使用更少的空闲功率. 如果在手动飞行中不稳定而下降，就向右滑.")
                    param:          "MPC_MANTHR_MIN"
                    min:            0
                    max:            15
                    step:           1
                }

                ListElement {
                    title:          qsTr("横滚灵敏度")
                    description:    qsTr("滑到左边，使横滚控制变得更快更准确. 向右滑，如果横滚振动变大.")
                    param:          "MC_ROLL_TC"
                    min:            0.15
                    max:            0.25
                    step:           0.01
                }

                ListElement {
                    title:          qsTr("俯仰灵敏度")
                    description:    qsTr("向左侧滑动以使俯仰控制变得更快更准确. 向右滑，如果俯仰振动变大.")
                    param:          "MC_PITCH_TC"
                    min:            0.15
                    max:            0.25
                    step:           0.01
                }
            }
        }
    } // Component
} // SetupPage
