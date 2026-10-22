/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.Marker : Shumate.Marker {

    public MarkerData markerdata {get; construct;}

    private Gtk.Popover popover;
    public signal void changed ();
    public signal void deletion_requested (int markerdata_id);

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
            margin_end = 10
        };

        var name_entry = new Gtk.Entry () {
            text = markerdata.name
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
            height_request = 80,
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = NEVER
        };

        var frame = new Gtk.Frame (null) {
            child = scrolled
        };

        var delete_button = new Gtk.Button.with_label (_("Delete…")) {
            halign = Gtk.Align.START,
        };
        delete_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        box.append (name_entry);
        box.append (frame);
        box.append (delete_button);

        popover = new Gtk.Popover () {
            child = box
        };

        var menubutton = new Gtk.MenuButton () {
            popover = popover,
            icon_name = "mail-unread",
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
        popover.closed.connect (on_popover_closed);
    }

    public void on_popover_closed () {
        changed ();
    }

    public void delete_marker () {
        popover.popdown ();
        deletion_requested (markerdata.id);
    }
}
