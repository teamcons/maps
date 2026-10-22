/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.MarkerData : Object {

    private static int last_id = 0;

    public double latitude {get; set;}
    public double longitude {get; set;}
    public string name {get; set;}
    public string notes {get; set;}
    public int id {get; private set;}

    public MarkerData () {
        id = last_id;
        last_id++;
    }

    /**
    * Used to recreate individual points of interest from storage data
    */
    public MarkerData.from_json (Json.Object node) {
        latitude = node.get_double_member ("lat");
        longitude = node.get_double_member ("long");
        name = node.get_string_member ("name");
        notes = node.get_string_member ("notes");
    }

    /*************************************************/
    /**
    * Used to convert points of interest into objects we can store
    */
    public Json.Object to_json () {
        var builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("lat");
        builder.add_double_value (latitude);
        builder.set_member_name ("long");
        builder.add_double_value (longitude);
        builder.set_member_name ("name");
        builder.add_string_value (name);
        builder.set_member_name ("notes");
        builder.add_string_value (notes);
        builder.end_object ();

        return builder.get_root ().get_object ();
    }
}
