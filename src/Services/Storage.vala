/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.Storage : Object {

    private const string STORAGE_FILENAME = "locations.json";
    private File datadir;
    private string storage_file_path;

    construct {
        var path_data = Environment.get_user_data_dir ();
        datadir = File.new_for_path (path_data);
        ensure_datadir ();

        storage_file_path = GLib.Path.build_path (Path.DIR_SEPARATOR_S, path_data, STORAGE_FILENAME);
    }

    /*************************************************/
    /**
    * Persistently check for the data directory and create if there is none 
    */
    private void ensure_datadir () {
        debug ("do we have a data directory?");
        if (datadir.query_exists ()) {
            debug ("Yes, nevermind");
            return;
        }

        try {
            datadir.make_directory_with_parents ();
            debug ("yes we do now");

        } catch (Error e) {
            warning ("Failed to prepare target data directory %s", e.message);
        }
    }

    /*************************************************/
    /**
    * Converts a Json.Node into a string and take care of saving it
    */
    public void save (Json.Array json_data) {
        ensure_datadir ();
        debug ("Writing %u elements (Should be same number as points of interest)", json_data.get_length ());

        try {
            var generator = new Json.Generator ();
            var node = new Json.Node (Json.NodeType.ARRAY);
            node.set_array (json_data);
            generator.set_root (node);
            generator.to_file (storage_file_path);

        } catch (Error e) {
            warning ("Failed to save points of interest %s", e.message);
        }
    }

    /*************************************************/
    /**
    * Grab from storage, into a Json.Node we can parse. Insist if necessary
    */
    public Json.Array load () {

        var parser = new Json.Parser ();
        var array = new Json.Array ();

        try {
            parser.load_from_mapped_file (storage_file_path);
            var node = parser.get_root ();
            array = node.get_array ();

        } catch (Error e) {
            warning ("Failed to load from storage %s", e.message);

        }

        debug ("Retrieved %ui elements", array.get_length ());
        return array;
    }
}
