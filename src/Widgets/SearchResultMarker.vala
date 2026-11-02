/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * SearchResultMarker is a subclass of {@link Shumate.Marker} built from a {@link Geocode.Location}
 *
 * It displays a pointer on the map which when clicked shows a popover offering the user to create a new pin for this location
 *
 * It is created by {@link Maps.Map_Widget} when user selects a result of a search
 */
public class Maps.SearchResultMarker : Shumate.Marker {

    public signal void create_pin (MarkerData markerdata);
    public signal void deletion_requested (Shumate.Marker marker);

    private Granite.HeaderLabel headerlabel;
    private Gtk.Popover popover;

    public string loc_name {
        get {
            return headerlabel.label;
        }
        set {
            headerlabel.label = value;
        }
    }

    public string loc_address {
        get {
            return headerlabel.secondary_text;
        }
        set {
            headerlabel.secondary_text = value;
        }
    }

    public SearchResultMarker (Geocode.Place place) {
        Object (
            latitude: place.location.latitude,
            longitude: place.location.longitude
        );
    }

    construct {
        var box = new Granite.Box (VERTICAL, HALF) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10,
            width_request = 90
        };

        headerlabel = new Granite.HeaderLabel ("");

        var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic") {
            tooltip_text = _("Delete this location"),
        };
        delete_button.add_css_class (Granite.CssClass.DESTRUCTIVE);
        var button = new Gtk.Button.with_label (_("Create pin"));
        button.add_css_class (Granite.CssClass.SUGGESTED);

        var box_toolbar = new Gtk.CenterBox ();
        box_toolbar.start_widget = delete_button;
        box_toolbar.end_widget = button;

        box.append (headerlabel);
        box.append (box_toolbar);

        popover = new Gtk.Popover () {
            child = box
        };

        var image = new Gtk.Image.from_icon_name ("pointer") {
            icon_size = Gtk.IconSize.LARGE
        };

        var menubutton = new Gtk.MenuButton () {
            popover = popover,
            child = image,
            has_frame = false,
            tooltip_text = loc_name
        };

        popover.position = Gtk.PositionType.TOP;
        child = menubutton;

        button.clicked.connect (on_button_click);
    }

    private void on_button_click () {
        popover.popdown ();
        var new_marker_data = new MarkerData (latitude, longitude) {
            name = loc_name,
            comments = loc_address
        };
        create_pin (new_marker_data);
    }

    public void delete_marker () {
        popover.popdown ();
        deletion_requested (this);
    }
}
