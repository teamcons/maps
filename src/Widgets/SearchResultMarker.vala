/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * SearchResultMarker is a subclass of {@link Shumate.Marker} built from a position
 *
 * It displays a pointer on the map which when clicked shows a popover offering the user to create a new pin for this location
 *
 * It is created by {@link Maps.Map_Widget} as the result of a search initiated by the user
 */
public class Maps.SearchResultMarker : Shumate.Marker {

    public signal void create_pin (MarkerData markerdata);
    private Gtk.Button button;

    public SearchResultMarker (double latitude, double longitude) {
        Object (
            latitude: latitude,
            longitude: longitude
        );
    }

    construct {
        button = new Gtk.Button.with_label (_("Create new pin")) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10,
            width_request = 80
        };

        var popover = new Gtk.Popover () {
            child = button
        };

        var image = new Gtk.Image.from_icon_name ("pointer") {
            icon_size = Gtk.IconSize.LARGE
        };

        var menubutton = new Gtk.MenuButton () {
            popover = popover,
            child = image,
            has_frame = false,
        };

        popover.position = Gtk.PositionType.TOP;
        child = menubutton;

        button.activate.connect (on_button_click);
    }

    private void on_button_click () {
        var new_marker_data = new MarkerData (latitude, longitude);
        create_pin (new_marker_data);
    }
}
