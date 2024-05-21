/**
 * Fortishield API RESTful
 * Copyright (C) 2015-2020 Fortishield, Inc. All rights reserved.
 * Fortishield.com
 *
 * This program is a free software; you can redistribute it
 * and/or modify it under the terms of the GNU General Public
 * License (version 2) as published by the FSF - Free Software
 * Foundation.
 */

exports.configuration_file = function() {
    var config_fields = ['ossec_path', 'host', 'port', 'https', 'basic_auth', 'BehindProxyServer', 'logs', 'cors', 'cache_enabled', 'cache_debug', 'cache_time', 'log_path'];

    for (i = 0; i < config_fields.length; i++) {

        // Exist
        if (!(config_fields[i] in config)){
            console.log("Configuration error: Element '" + config_fields[i] + "' not found. Exiting.");
            return -1;
        }

        if (config_fields[i] != "python"){
            // String
            if (typeof config[config_fields[i]] !== "string") {
                console.log("Configuration error: Element '" + config_fields[i] + "' must be an string. Exiting.");
                return -1;
            }
            // Empty
            if (!config[config_fields[i]].trim()){
                console.log("Configuration error: Element '" + config_fields[i] + "' is empty. Exiting.");
                return -1;
            }
        }
    }

    return 0;
}


// Check Fortishield version
exports.fortishield = function(my_logger) {
    try {
        var fs = require("fs");
        var fortishield_version_mayor = 0;
        var version_regex = new RegExp('VERSION="v(.+)"');
        var fortishield_version = "v0";

        fs.readFileSync('/etc/ossec-init.conf').toString().split('\n').forEach(function (line) {
            var match = line.match(version_regex);
            if (match) {
                fortishield_version = match[1]
                fortishield_version_mayor = parseInt(fortishield_version[0]);
                return;
            }
        });

        // Fortishield 2.0 or newer required
        if (fortishield_version_mayor < 2) {
            if (fortishield_version_mayor == 0)
                var msg = "not";
            else
                var msg = fortishield_version;

            var f_msg = "ERROR: Fortishield manager v" + msg + " found. It is required Fortishield manager v2.0.0 or newer. Exiting.";
            console.log(f_msg);
            my_logger.log(f_msg);
            return -1;
        }

        // Fortishield major.minor == API major.minor
        var fortishield_api_mm = info_package.version.substring(0, 3)
        if ( fortishield_version.substring(0, 3) != fortishield_api_mm ){
            var f_msg = "ERROR: Fortishield manager v" + fortishield_version + " found. Fortishield manager v" + fortishield_api_mm + ".x expected. Exiting.";
            console.log(f_msg);
            my_logger.log(f_msg);
            return -1;
        }
    } catch (e) {
        var f_msg = "WARNING: The installed version of Fortishield manager could not be determined. It is required Fortishield Manager 2.0 or newer.";
        console.log(f_msg);
        my_logger.log(f_msg);
    }

    return 0;
}
