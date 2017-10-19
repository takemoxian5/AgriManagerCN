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
                    title:          qsTr("悬停横滚灵敏度")
                    description:    qsTr("滑到左边，使横滚控制变得更快更准确. 向右滑，如果横滚振动变大.")
                    param:          "MC_ROLL_TC"
                    min:            0.15
                    max:            0.25
                    step:           0.01
                }

                ListElement {
                    title:          qsTr("悬停俯仰灵敏度")
                    description:    qsTr("向左侧滑动以使俯仰控制变得更快更准确. 向右滑，如果俯仰振动变大.")
                    param:          "MC_PITCH_TC"
                    min:            0.15
                    max:            0.25
                    step:           0.01
                }

                ListElement {
                    title:          qsTr("固定翼横滚灵敏度")
                    description:    qsTr("滑到左边，使横滚控制变得更快更准确. 向右滑，如果横滚振动变大.")
                    param:          "FW_R_TC"
                    min:            0.2
                    max:            0.8
                    step:           0.01
                }

                ListElement {
                    title:          qsTr("固定翼俯仰灵敏度")
                    description:    qsTr("向左侧滑动以使俯仰控制变得更快更准确. 向右滑，如果俯仰振动变大.")
                    param:          "FW_P_TC"
                    min:            0.2
                    max:            0.8
                    step:           0.01
                }

                ListElement {
                    title:          qsTr("固定翼巡航油门")
                    description:    qsTr("这是达到所需巡航速度所需的油门设置. 大多数固定翼为 50-60%.")
                    param:          "FW_THR_CRUISE"
                    min:            20
                    max:            80
                    step:           1
                }

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
                    title:          qsTr("固定翼任务模式灵敏度")
                    description:    qsTr("向左滑动，使位置控制更加准确和迅速. 向右滑，使飞行在任务模式中更流畅，更稳定.")
                    param:          "FW_L1_PERIOD"
                    min:            12
                    max:            50
                    step:           0.5
                }
            }
        }
    }
}
