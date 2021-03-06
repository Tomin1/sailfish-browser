/****************************************************************************
**
** Copyright (c) 2013 - 2019 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
** Contact: Dmitry Rozhkov <dmitry.rozhkov@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Browser 1.0
import org.nemomobile.configuration 1.0
import com.jolla.settings.system 1.0
import Sailfish.Policy 1.0
import Sailfish.WebEngine 1.0

Page {
    id: page

    property var _nameMap: ({})

    function name2index(name) {
        return _nameMap[name] !== undefined ? _nameMap[name] : 0
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn

            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                //% "Settings"
                title: qsTrId("sailfish_browser-he-settings")
            }

            DisabledByMdmBanner {
                active: !AccessPolicy.browserEnabled
            }

            TextField {
                id: homePage
                enabled: AccessPolicy.browserEnabled

                //: Label for home page text field
                //% "Home Page"
                label: qsTrId("settings_browser-la-home_page")
                text: homePageConfig.value == "about:blank" ? "" : homePageConfig.value

                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly

                onTextChanged: homePageConfig.value = text || "about:blank"

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            ComboBox {
                id: searchEngine
                enabled: AccessPolicy.browserEnabled

                width: parent.width
                //: Label for combobox that sets search engine used in browser
                //% "Search engine"
                label: qsTrId("settings_browser-la-search_engine")
                currentIndex: name2index(searchEngineConfig.value)

                menu: ContextMenu {
                    id: searchEngineMenu

                    Component {
                        id: menuItemComp

                        MenuItem {}
                    }

                    Component.onCompleted: {
                        var index = 0
                        settings.searchEngineList.forEach(function(name) {
                            var map = page._nameMap
                            // FIXME: _contentColumn should not be used to add items dynamicly
                            menuItemComp.createObject(searchEngineMenu._contentColumn, {"text": name})
                            map[name] = index
                            page._nameMap = map
                            index++
                        })
                    }
                }

                onCurrentItemChanged: {
                    if (currentItem.text !== searchEngineConfig.value) {
                        searchEngineConfig.value = currentItem.text
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                //: Button for opening privacy settings page.
                //% "Privacy"
                text: qsTrId("settings_browser-bt-privacy")
                enabled: AccessPolicy.browserEnabled
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("PrivacySettingsPage.qml"))
            }

            TextSwitch {
                //: Label for text switch that makes all tabs closed upon closing browser application
                //% "Close all tabs on exit"
                text: qsTrId("settings_browser-la-close_all_tabs")
                //% "Upon exiting Sailfish Browser all open tabs will be closed"
                description: qsTrId("settings_browser-la-close_all_tabs_description")
                checked: closeAllTabsConfig.value
                enabled: AccessPolicy.browserEnabled

                onCheckedChanged: closeAllTabsConfig.value = checked
            }

            TextSwitch {
                //: Label for text switch that enables JavaScript globally for all tabs
                //% "Enable JavaScript"
                text: qsTrId("settings_browser-la-enable_javascript")
                description: WebEngineSettings.javascriptEnabled ?
                                     //% "Allowed (recommended)"
                                     qsTrId("settings_browser-la-enabled_javascript_description") :
                                     //% "Blocked, some sites may not work correctly"
                                     qsTrId("settings_browser-la-disable_javascript_description")
                checked: WebEngineSettings.javascriptEnabled
                enabled: AccessPolicy.browserEnabled
                onCheckedChanged: WebEngineSettings.javascriptEnabled = checked;
            }

            BackgroundItem {
                width: parent.width
                contentHeight: Theme.itemSizeMedium
                Row {
                    width: parent.width - 2*Theme.horizontalPageMargin
                    x: Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter

                    Icon {
                        id: permissionIcon
                        source: "image://theme/icon-m-browser-permissions"
                    }
                    Label {
                        width: parent.width - parent.spacing - permissionIcon.width
                        //% "Permissions"
                        text: qsTrId("settings_browser-la-permissions")
                        anchors.verticalCenter: permissionIcon.verticalCenter
                    }
                }
                onClicked: pageStack.push("PermissionPage.qml")
            }
        }
    }

    ConfigurationValue {
        id: closeAllTabsConfig
        key: "/apps/sailfish-browser/settings/close_all_tabs"
        defaultValue: false
    }

    ConfigurationValue {
        id: searchEngineConfig

        key: "/apps/sailfish-browser/settings/search_engine"
        defaultValue: "Google"

        onValueChanged: {
            if (searchEngine.currentItem.text !== value) {
                searchEngine.currentIndex = name2index(value)
            }
        }
    }

    ConfigurationValue {
        id: homePageConfig

        key: "/apps/sailfish-browser/settings/home_page"
        defaultValue: "http://jolla.com/"
    }

    BrowserSettings {
        id: settings
    }
}
