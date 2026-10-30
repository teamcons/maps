/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * Marker is a subclass of {@link Shumate.Marker} built from a {@link Maps.MarkerData}
 *
 * It uses as child a MenuButton, whose popover displays the MarkerData informations.
 *
 * The pointer is an image set as child of the MenuButton
 */
public class Maps.Marker : Shumate.Marker {

    public MarkerData markerdata {get; construct;}

    private Gtk.Popover popover;
    public signal void changed ();
    public signal void deletion_requested (Shumate.Marker marker);

    public Marker (MarkerData markerdata) {
        Object (
            markerdata: markerdata,
            latitude: markerdata.latitude,
            longitude: markerdata.longitude
        );
    }

    construct {
        var box = new Granite.Box (Gtk.Orientation.VERTICAL, Granite.Box.Spacing.SINGLE) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10,
            width_request = 210
        };

        var name_entry = new Gtk.Entry () {
            text = markerdata.name,
            placeholder_text = _("Name of the location")
        };

        var comment_textview = new Granite.HyperTextView () {
            accepts_tab = false,
            wrap_mode = WORD_CHAR,
            top_margin = 3,
            right_margin = 3,
            bottom_margin = 3,
            left_margin = 3,
        };
        comment_textview.buffer.text = markerdata.notes;

        var scrolled = new Gtk.ScrolledWindow () {
            child = comment_textview,
            hscrollbar_policy = NEVER
        };

        var frame = new Gtk.Frame (null) {
            child = scrolled,
            height_request = 110,
            hexpand = true,
            vexpand = true
        };

        var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic") {
            tooltip_text = _("Delete this location"),
            halign = Gtk.Align.START,
        };
        delete_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        box.append (name_entry);
        box.append (frame);
        box.append (delete_button);

        popover = new Gtk.Popover () {
            child = box
        };

        var image = new Gtk.Image.from_icon_name ("pointer") {
            icon_size = Gtk.IconSize.LARGE
        };

        var menubutton = new Gtk.MenuButton () {
            popover = popover,
            icon_name = "pointer",
            child = image,
            has_frame = false,
            tooltip_text = markerdata.name
        };

        popover.position = Gtk.PositionType.TOP;
        child = menubutton;

        name_entry.bind_property ("text",
            markerdata, "name",
            GLib.BindingFlags.DEFAULT);

        name_entry.bind_property ("text",
            menubutton, "tooltip-text",
            GLib.BindingFlags.DEFAULT);

        comment_textview.buffer.bind_property ("text",
            markerdata, "notes",
            GLib.BindingFlags.DEFAULT);

        delete_button.clicked.connect (delete_marker);
        name_entry.changed.connect (on_changed);
        comment_textview.buffer.changed.connect (on_changed);
    }

    public void on_changed () {
        changed ();
    }

    public void delete_marker () {
        popover.popdown ();
        deletion_requested (this);
    }

    public void popup () {
        popover.popup ();
    }
}
