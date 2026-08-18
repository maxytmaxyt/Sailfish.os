// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

Page {
    id: page

    property alias url: originalPlaylistModel.url
    property string title
    property bool isEditable: app.playlists.isEditable(url)

    Connections {
        target: app.playlists
        onUpdated: {
            originalPlaylistModel.refresh()
        }
    }

    FilterModel {
        id: playlistModel

        sourceModel: originalPlaylistModel
        filterRegExp: RegExpHelpers.regExpFromSearchString(playlistHeader.searchText, true)
    }

    PlaylistModel {
        id: originalPlaylistModel
    }

    MediaPlayerListView {
        id: view

        anchors.fill: parent
        model: playlistModel

        PullDownMenu {
            enabled: playlistModel.count > 0
            visible: playlistModel.count > 0

            MenuItem {
                //: Add to playing queue drop down menu item in playlist page
                //% "Add to playing queue"
                text: qsTrId("mediaplayer-me-playlist-add-to-playing-queue")
                onClicked: AudioPlayer.addToQueue(playlistModel)
            }

            MenuItem {
                //: Clear playlist drop down menu item in playlist page
                //% "Clear playlist"
                text: qsTrId("mediaplayer-me-playlist-clear-playlist")
                visible: isEditable

                onClicked: {
                    //: Clearing the playlist
                    //% "Clearing"
                    Remorse.popupAction(page, qsTrId("mediaplayer-la-clearing"), function() {
                        if (app.playlists.clearPlaylist(page.url, page.title)) {
                            pageStack.pop()
                        }
                    })
                }
            }

            NowPlayingMenuItem { }

            MenuItem {
                //: Search menu entry
                //% "Search"
                text: qsTrId("mediaplayer-me-search")
                onClicked: playlistHeader.enableSearch()
                enabled: view.count > 0 || playlistHeader.searchText !== ''
            }
        }

        ViewPlaceholder {
            text: {
                if (playlistHeader.searchText !== '') {
                    //: Placeholder text for an empty search view
                    //% "No items found"
                    return qsTrId("mediaplayer-la-empty-search")
                } else {
                    //: "Placeholder text for an empty playlist; Add songs to playlist"
                    //% "Add some media"
                    return qsTrId("mediaplayer-la-add-some-media")
                }
            }
            enabled: playlistModel.count === 0
        }

        header: SearchPageHeader {
            id: playlistHeader

            width: parent.width
            title: page.title
            //: Playlist search field placeholder text
            //% "Search song"
            placeholderText: qsTrId("mediaplayer-tf-playlist-search")
        }

        delegate: MediaListDelegate {
            property int realIndex: playlistModel.mapRowToSource(index)

            function remove() {
                remorseDelete(function() {
                    if (realIndex >= 0 ) {
                        originalPlaylistModel.remove(realIndex)
                        app.playlists.savePlaylist(page.title, originalPlaylistModel)
                    }
                })
            }

            formatFilter: playlistHeader.searchText
            menu: menuComponent
            onClicked: {
                AudioPlayer.play(view.model, index)
                app.playlists.updateAccessTime(page.url)
            }
            ListView.onRemove: animateRemoval()

            Component {
                id: menuComponent
                ContextMenu {
                    MenuItem {
                        //: Remove from playlist context menu item in playlist page
                        //% "Remove from playlist"
                        text: qsTrId("mediaplayer-me-playlist-remove-from-playlist")
                        onClicked: remove()
                    }
                }
            }
        }
    }
}
