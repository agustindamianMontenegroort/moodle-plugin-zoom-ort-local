<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

namespace local_zoommeetingid;

defined('MOODLE_INTERNAL') || die();

require_once($CFG->libdir . '/externallib.php');

use external_api;
use external_function_parameters;
use external_value;
use external_single_structure;
use external_multiple_structure;

class external extends external_api {

    public static function get_user_zoom_meetings_parameters() {
        return new external_function_parameters([
            'userid' => new external_value(PARAM_INT, 'User ID', VALUE_REQUIRED),
        ]);
    }

    public static function get_user_zoom_meetings($userid) {
        global $DB;

        $params = self::validate_parameters(self::get_user_zoom_meetings_parameters(), [
            'userid' => $userid,
        ]);

        $context = \context_system::instance();
        self::validate_context($context);

        $user = $DB->get_record('user', ['id' => $params['userid']], '*', MUST_EXIST);
        $enrolledcourses = enrol_get_users_courses($params['userid'], true);

        $meetings = [];

        foreach ($enrolledcourses as $course) {
            $zoommeetings = $DB->get_records('zoom', ['course' => $course->id]);

            foreach ($zoommeetings as $meeting) {
                $meetings[] = [
                    'meetingid' => (string)$meeting->meeting_id,
                    'meetingname' => $meeting->name,
                    'courseid' => (int)$meeting->course,
                    'coursename' => $course->fullname,
                    'courseshortname' => $course->shortname,
                    'starttime' => (int)$meeting->start_time,
                    'duration' => (int)$meeting->duration,
                    'joinurl' => $meeting->join_url,
                    'password' => $meeting->password ?? '',
                ];
            }
        }

        return [
            'userid' => $params['userid'],
            'username' => $user->username,
            'fullname' => fullname($user),
            'email' => $user->email,
            'totalcourses' => count($enrolledcourses),
            'totalmeetings' => count($meetings),
            'meetings' => $meetings,
        ];
    }

    public static function get_user_zoom_meetings_returns() {
        return new external_single_structure([
            'userid' => new external_value(PARAM_INT, 'User ID'),
            'username' => new external_value(PARAM_TEXT, 'Username'),
            'fullname' => new external_value(PARAM_TEXT, 'Full name'),
            'email' => new external_value(PARAM_EMAIL, 'Email'),
            'totalcourses' => new external_value(PARAM_INT, 'Total enrolled courses'),
            'totalmeetings' => new external_value(PARAM_INT, 'Total Zoom meetings'),
            'meetings' => new external_multiple_structure(
                new external_single_structure([
                    'meetingid' => new external_value(PARAM_TEXT, 'Zoom Meeting ID'),
                    'meetingname' => new external_value(PARAM_TEXT, 'Meeting name'),
                    'courseid' => new external_value(PARAM_INT, 'Course ID'),
                    'coursename' => new external_value(PARAM_TEXT, 'Course full name'),
                    'courseshortname' => new external_value(PARAM_TEXT, 'Course short name'),
                    'starttime' => new external_value(PARAM_INT, 'Start time (timestamp)'),
                    'duration' => new external_value(PARAM_INT, 'Duration in seconds'),
                    'joinurl' => new external_value(PARAM_URL, 'Join URL'),
                    'password' => new external_value(PARAM_TEXT, 'Meeting password', VALUE_OPTIONAL),
                ])
            ),
        ]);
    }
}
