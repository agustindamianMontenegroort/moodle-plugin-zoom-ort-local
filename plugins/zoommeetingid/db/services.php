<?php
// This file is part of Moodle - http://moodle.org/

defined('MOODLE_INTERNAL') || die();

$functions = [
    'local_zoommeetingid_get_user_meetings' => [
        'classname'   => 'local_zoommeetingid\external',
        'methodname'  => 'get_user_zoom_meetings',
        'classpath'   => '',
        'description' => 'Get all Zoom meetings for a specific user',
        'type'        => 'read',
        'ajax'        => true,
        'services'    => [MOODLE_OFFICIAL_MOBILE_SERVICE],
    ],
];

$services = [
    'Zoom Meeting ID API' => [
        'functions' => ['local_zoommeetingid_get_user_meetings'],
        'restrictedusers' => 0,
        'enabled' => 1,
        'shortname' => 'zoom_meeting_api',
        'downloadfiles' => 0,
        'uploadfiles' => 0,
    ],
];
