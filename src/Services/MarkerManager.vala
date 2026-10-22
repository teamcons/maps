/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.MarkerManager : Object {
    private Storage storage;
    private Gee.ArrayList<Maps.Marker?> marker_list;
    private unowned Shumate.MarkerLayer markerlayer;


    public MarkerManager (Shumate.MarkerLayer markerlayer) {
        this.markerlayer = markerlayer;
    }

    construct {
        storage = new Storage ();
    }

    public async void populate_layer () {
        var markerdata_array = storage.load ();

        foreach (var markerdata_note in markerdata_array.get_elements ()) {
            var markerdata = new MarkerData.from_json (markerdata_note.get_object ());

            add_marker (markerdata);
        }

        save_all ();
    }

    public void add_marker (MarkerData markerdata) {
        var marker = new Marker (markerdata);
        marker_list.add (marker);
        markerlayer.add_marker (marker);

        marker.deletion_requested.connect (remove_marker);
    }

    public void remove_marker (int marker_id) {

        // 0 is our current location
        if (marker_id == 0) {
            return;
        }

        // Each MarkerData has an unique ID that mirrors their position in the list
        var marker = marker_list[marker_id];
        marker.destroy ();
        marker_list[marker_id] = null;

        save_all ();
    }

    private void save_all () {
        var json_array = new Json.Array ();

        foreach (var marker in marker_list) {
            
            // Deleted markers are set to null
            if (marker == null) {
                continue;
            } 

            json_array.add_object_element (marker.markerdata.to_json ());
        }

        storage.save (json_array);
    }
}