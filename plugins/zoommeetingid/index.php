<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Main page to display Zoom Meeting IDs.
 *
 * @package     local_zoommeetingid
 * @copyright   2024
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require_once(__DIR__ . '/../../config.php');
require_once($CFG->libdir . '/adminlib.php');
require_once(__DIR__ . '/lib.php');

// Require login and capabilities
require_login();
$context = context_system::instance();
require_capability('local/zoommeetingid:view', $context);

$PAGE->set_url(new moodle_url('/local/zoommeetingid/index.php'));
$PAGE->set_context(context_system::instance());
$PAGE->set_title(get_string('pluginname', 'local_zoommeetingid'));
$PAGE->set_heading(get_string('pluginname', 'local_zoommeetingid'));

// Get filter parameters
$courseid = optional_param('courseid', 0, PARAM_INT);
$search = optional_param('search', '', PARAM_TEXT);
$startdatestr = optional_param('startdate', '', PARAM_TEXT);
$enddatestr = optional_param('enddate', '', PARAM_TEXT);
$page = optional_param('page', 0, PARAM_INT);
$perpage = 20;

// Convert date strings to timestamps
$startdate = 0;
if (!empty($startdatestr)) {
    $startdate = strtotime($startdatestr . ' 00:00:00');
}
$enddate = 0;
if (!empty($enddatestr)) {
    $enddate = strtotime($enddatestr . ' 23:59:59');
}

// Build filters array
$filters = [];
if ($courseid > 0) {
    $filters['courseid'] = $courseid;
}
if (!empty($search)) {
    $filters['search'] = $search;
}
if ($startdate > 0) {
    $filters['startdate'] = $startdate;
}
if ($enddate > 0) {
    $filters['enddate'] = $enddate;
}

// Handle export requests
$export = optional_param('export', '', PARAM_ALPHA);
if ($export === 'csv' || $export === 'json') {
    try {
        $meetings = local_zoommeetingid_get_all_meetings($filters);
        
        if ($export === 'csv') {
            $csv = local_zoommeetingid_export_csv($meetings);
            header('Content-Type: text/csv; charset=utf-8');
            header('Content-Disposition: attachment; filename="zoom_meetings_' . date('Y-m-d') . '.csv"');
            echo $csv;
            exit;
        } else if ($export === 'json') {
            $json = local_zoommeetingid_export_json($meetings);
            header('Content-Type: application/json; charset=utf-8');
            header('Content-Disposition: attachment; filename="zoom_meetings_' . date('Y-m-d') . '.json"');
            echo $json;
            exit;
        }
    } catch (Exception $e) {
        throw new moodle_exception('errorexporting', 'local_zoommeetingid', $PAGE->url, $e->getMessage());
    }
}

// Get all meetings with filters
$allmeetings = local_zoommeetingid_get_all_meetings($filters);
$totalcount = count($allmeetings);

// Pagination
$meetings = array_slice($allmeetings, $page * $perpage, $perpage);

// Get courses for filter dropdown
$courses = local_zoommeetingid_get_courses_with_zoom();

// Output page
echo $OUTPUT->header();

// Build export URL with current filters
$exportparams = $filters;
$exportparams['export'] = 'csv';
$exportcsvurl = new moodle_url('/local/zoommeetingid/index.php', $exportparams);
$exportparams['export'] = 'json';
$exportjsonurl = new moodle_url('/local/zoommeetingid/index.php', $exportparams);

// Filter form
echo html_writer::start_tag('form', ['method' => 'get', 'action' => $PAGE->url, 'class' => 'mb-3']);
echo html_writer::start_div('row');

// Course filter
echo html_writer::start_div('col-md-3 mb-2');
echo html_writer::label(get_string('filtercourse', 'local_zoommeetingid'), 'courseid', false, ['class' => 'sr-only']);
$courseoptions = [0 => get_string('allcourses', 'local_zoommeetingid')] + $courses;
echo html_writer::select($courseoptions, 'courseid', $courseid, false, ['class' => 'form-control', 'id' => 'courseid']);
echo html_writer::end_div();

// Search filter
echo html_writer::start_div('col-md-3 mb-2');
echo html_writer::label(get_string('search', 'local_zoommeetingid'), 'search', false, ['class' => 'sr-only']);
echo html_writer::empty_tag('input', [
    'type' => 'text',
    'name' => 'search',
    'id' => 'search',
    'value' => $search,
    'class' => 'form-control',
    'placeholder' => get_string('searchplaceholder', 'local_zoommeetingid')
]);
echo html_writer::end_div();

// Start date filter
echo html_writer::start_div('col-md-2 mb-2');
echo html_writer::label(get_string('startdate', 'local_zoommeetingid'), 'startdate', false, ['class' => 'sr-only']);
echo html_writer::empty_tag('input', [
    'type' => 'date',
    'name' => 'startdate',
    'id' => 'startdate',
    'value' => $startdatestr,
    'class' => 'form-control'
]);
echo html_writer::end_div();

// End date filter
echo html_writer::start_div('col-md-2 mb-2');
echo html_writer::label(get_string('enddate', 'local_zoommeetingid'), 'enddate', false, ['class' => 'sr-only']);
echo html_writer::empty_tag('input', [
    'type' => 'date',
    'name' => 'enddate',
    'id' => 'enddate',
    'value' => $enddatestr,
    'class' => 'form-control'
]);
echo html_writer::end_div();

// Buttons
echo html_writer::start_div('col-md-2 mb-2');
echo html_writer::empty_tag('input', [
    'type' => 'submit',
    'value' => get_string('filter', 'local_zoommeetingid'),
    'class' => 'btn btn-primary mr-1'
]);
echo html_writer::link(
    $PAGE->url,
    get_string('clear', 'local_zoommeetingid'),
    ['class' => 'btn btn-secondary']
);
echo html_writer::end_div();

echo html_writer::end_div();
echo html_writer::end_tag('form');

// Export buttons and results count
echo html_writer::start_div('mb-3 d-flex justify-content-between align-items-center');
echo html_writer::start_div('');
echo html_writer::link(
    $exportcsvurl,
    get_string('exportcsv', 'local_zoommeetingid'),
    ['class' => 'btn btn-primary mr-2']
);
echo html_writer::link(
    $exportjsonurl,
    get_string('exportjson', 'local_zoommeetingid'),
    ['class' => 'btn btn-secondary']
);
echo html_writer::end_div();
if ($totalcount > 0) {
    echo html_writer::div(
        get_string('resultsfound', 'local_zoommeetingid', $totalcount),
        'text-muted'
    );
}
echo html_writer::end_div();

// Display meetings table
if (empty($meetings)) {
    echo $OUTPUT->notification(get_string('nozoomactivities', 'local_zoommeetingid'), 'info');
} else {
    $table = new html_table();
    $table->head = [
        get_string('meetingid', 'local_zoommeetingid'),
        get_string('meetingname', 'local_zoommeetingid'),
        get_string('coursename', 'local_zoommeetingid'),
        get_string('starttime', 'local_zoommeetingid'),
        get_string('duration', 'local_zoommeetingid'),
        get_string('password', 'local_zoommeetingid'),
        get_string('joinurl', 'local_zoommeetingid'),
    ];
    $table->attributes['class'] = 'generaltable';

    foreach ($meetings as $meeting) {
        $table->data[] = [
            $meeting['meeting_id'],
            $meeting['name'],
            $meeting['coursename'] ?? '',
            $meeting['start_time'],
            $meeting['duration'] . ' min',
            $meeting['password'] ? '***' : '-',
            $meeting['join_url'] ? html_writer::link($meeting['join_url'], get_string('joinurl', 'local_zoommeetingid'), ['target' => '_blank']) : '-',
        ];
    }

    echo html_writer::table($table);

    // Pagination
    if ($totalcount > $perpage) {
        $baseurl = new moodle_url($PAGE->url, $filters);
        $pagingbar = $OUTPUT->paging_bar($totalcount, $page, $perpage, $baseurl);
        echo $pagingbar;
    }
}

echo $OUTPUT->footer();

