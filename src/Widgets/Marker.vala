/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * Marker is a subclass of {@link Shumate.Marker} built from a {@link Maps.MarkerData}
 *
 * It displays a pointer on the map which when clicked shows a popover presenting the MarkerData informations.
 *
 * It is created by {@link Maps.MarkerManager} from the content of a {@link Maps.Storage}
 */
public class Maps.Marker : Shumate.Marker {

    public signal void changed ();
    public signal void deletion_requested (Shumate.Marker marker);

    private Gtk.Popover popover;
    private Gtk.Entry name_entry;
    private Granite.HyperTextView comment_textview;

    public string loc_name {
        owned get {
            return name_entry.text.dup ();
        }
        set {
            name_entry.text = value;
            changed ();
        }
    }

    public string loc_comments {
        owned get {
            return comment_textview.buffer.text.dup ();
        }
        set {
            comment_textview.buffer.text = value;
            changed ();
        }
    }

    public Marker (MarkerData markerdata) {
        Object (
            latitude: markerdata.latitude,
            longitude: markerdata.longitude,
            loc_name: markerdata.name,
            loc_comments: markerdata.comments
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

        name_entry = new Gtk.Entry () {
            placeholder_text = _("Name of the location")
        };

        comment_textview = new Granite.HyperTextView () {
            accepts_tab = false,
            wrap_mode = WORD_CHAR,
            top_margin = 3,
            right_margin = 3,
            bottom_margin = 3,
            left_margin = 3,
        };

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
            child = image,
            has_frame = false,
            tooltip_text = loc_name
        };

        popover.position = Gtk.PositionType.TOP;
        child = menubutton;

        name_entry.changed.connect (on_changed);
        comment_textview.buffer.changed.connect (on_changed);
        delete_button.clicked.connect (delete_marker);
    }

    public void delete_marker () {
        popover.popdown ();
        deletion_requested (this);
    }

    public void popup () {
        popover.popup ();
    }

    // We use a dedicated handler as there may be a lot of markers
    // To avoid the infamous vala lambda leak bug
    public void on_changed () {
        changed ();
    }

    public MarkerData to_markerdata () {
        return new MarkerData (latitude, longitude) {
            name = loc_name,
            comments = loc_comments
        };;
    }
}
