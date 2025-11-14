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
 * Library functions for Zoom Meeting ID plugin.
 *
 * @package     local_zoommeetingid
 * @copyright   2024
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

/**
 * Obtiene todas las actividades de Zoom y sus Meeting IDs con filtros opcionales.
 *
 * @param array $filters Array con filtros: courseid, search, startdate, enddate
 * @return array Array de objetos con información de las reuniones de Zoom
 */
function local_zoommeetingid_get_all_meetings($filters = []) {
    global $DB;

    $meetings = [];

    try {
        // Verificar si el módulo mod_zoom existe
        if (!$DB->get_manager()->table_exists('zoom')) {
            return $meetings;
        }
    } catch (Exception $e) {
        debugging('Error checking zoom table: ' . $e->getMessage(), DEBUG_NORMAL);
        return $meetings;
    }

    // Construir condiciones WHERE
    $where = ['cm.deletioninprogress = 0'];
    $params = [];

    // Filtro por curso
    if (!empty($filters['courseid'])) {
        $where[] = 'z.course = :courseid';
        $params['courseid'] = $filters['courseid'];
    }

    // Búsqueda por nombre de reunión o Meeting ID
    if (!empty($filters['search'])) {
        $where[] = '(z.name LIKE :search OR z.meeting_id LIKE :search2)';
        $searchterm = '%' . $DB->sql_like_escape($filters['search']) . '%';
        $params['search'] = $searchterm;
        $params['search2'] = $searchterm;
    }

    // Filtro por fecha de inicio
    if (!empty($filters['startdate'])) {
        $where[] = 'z.start_time >= :startdate';
        $params['startdate'] = $filters['startdate'];
    }

    // Filtro por fecha de fin
    if (!empty($filters['enddate'])) {
        $where[] = 'z.start_time <= :enddate';
        $params['enddate'] = $filters['enddate'];
    }

    $whereclause = implode(' AND ', $where);

    try {
        // Obtener todas las actividades de Zoom
        $sql = "SELECT z.id, z.course, z.name, z.meeting_id, z.password, z.start_time, 
                       z.duration, z.join_url, c.fullname as coursename, z.start_time as start_timestamp
                FROM {zoom} z
                JOIN {course_modules} cm ON cm.instance = z.id AND cm.module = (
                    SELECT id FROM {modules} WHERE name = 'zoom'
                )
                JOIN {course} c ON c.id = z.course
                WHERE $whereclause
                ORDER BY z.start_time DESC";

        $records = $DB->get_records_sql($sql, $params);
    } catch (Exception $e) {
        debugging('Error fetching zoom meetings: ' . $e->getMessage(), DEBUG_NORMAL);
        return $meetings;
    }

    foreach ($records as $record) {
        $meetings[] = [
            'id' => $record->id,
            'courseid' => $record->course,
            'coursename' => $record->coursename,
            'name' => $record->name,
            'meeting_id' => $record->meeting_id,
            'password' => $record->password ?? '',
            'start_time' => $record->start_time ? userdate($record->start_time) : '',
            'start_timestamp' => $record->start_timestamp ?? 0,
            'duration' => $record->duration ?? 0,
            'join_url' => $record->join_url ?? '',
        ];
    }

    return $meetings;
}

/**
 * Obtiene la lista de cursos que tienen actividades de Zoom.
 *
 * @return array Array de cursos con id y nombre
 */
function local_zoommeetingid_get_courses_with_zoom() {
    global $DB;

    $courses = [];

    try {
        // Verificar si el módulo mod_zoom existe
        if (!$DB->get_manager()->table_exists('zoom')) {
            return $courses;
        }

        $sql = "SELECT DISTINCT c.id, c.fullname
                FROM {course} c
                JOIN {zoom} z ON z.course = c.id
                JOIN {course_modules} cm ON cm.instance = z.id AND cm.module = (
                    SELECT id FROM {modules} WHERE name = 'zoom'
                )
                WHERE cm.deletioninprogress = 0
                ORDER BY c.fullname";

        $records = $DB->get_records_sql($sql);
    } catch (Exception $e) {
        debugging('Error fetching courses with zoom: ' . $e->getMessage(), DEBUG_NORMAL);
        return $courses;
    }

    foreach ($records as $record) {
        $courses[$record->id] = $record->fullname;
    }

    return $courses;
}

/**
 * Obtiene las Meeting IDs de un curso específico.
 *
 * @param int $courseid ID del curso
 * @return array Array de objetos con información de las reuniones de Zoom
 */
function local_zoommeetingid_get_course_meetings($courseid) {
    return local_zoommeetingid_get_all_meetings(['courseid' => $courseid]);
}

/**
 * Exporta las Meeting IDs a formato CSV.
 *
 * @param array $meetings Array de reuniones
 * @return string Contenido CSV
 */
function local_zoommeetingid_export_csv($meetings) {
    if (empty($meetings)) {
        return '';
    }

    $output = fopen('php://temp', 'r+');

    if ($output === false) {
        throw new moodle_exception('errorcreatingcsv', 'local_zoommeetingid');
    }

    // Encabezados
    fputcsv($output, [
        'ID',
        'Curso',
        'Nombre de Reunión',
        'Meeting ID',
        'Contraseña',
        'Hora de Inicio',
        'Duración (min)',
        'URL de Unión'
    ]);

    // Datos
    foreach ($meetings as $meeting) {
        fputcsv($output, [
            $meeting['id'] ?? '',
            $meeting['coursename'] ?? '',
            $meeting['name'] ?? '',
            $meeting['meeting_id'] ?? '',
            $meeting['password'] ?? '',
            $meeting['start_time'] ?? '',
            $meeting['duration'] ?? 0,
            $meeting['join_url'] ?? ''
        ]);
    }

    rewind($output);
    $csv = stream_get_contents($output);
    fclose($output);

    return $csv;
}

/**
 * Exporta las Meeting IDs a formato JSON.
 *
 * @param array $meetings Array de reuniones
 * @return string Contenido JSON
 */
function local_zoommeetingid_export_json($meetings) {
    if (empty($meetings)) {
        return json_encode([], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

    $json = json_encode($meetings, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
    if ($json === false) {
        throw new moodle_exception('errorcreatingjson', 'local_zoommeetingid');
    }

    return $json;
}

