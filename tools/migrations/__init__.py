# Migrations module initialization
# This file enables importing from migrations as a package

from migrations.add_timecreated_column import migration_name as add_timecreated_migration_name, check_preconditions as add_timecreated_check_preconditions, needs_to_run as add_timecreated_needs_to_run
from migrations.add_instance_zone_column import migration_name as add_instance_zone_migration_name, check_preconditions as add_instance_zone_check_preconditions, needs_to_run as add_instance_zone_needs_to_run
from migrations.add_daily_tally_column import migration_name as add_daily_tally_migration_name, check_preconditions as add_daily_tally_check_preconditions, needs_to_run as add_daily_tally_needs_to_run
from migrations.broken_linkshells import migration_name as broken_linkshells_migration_name, check_preconditions as broken_linkshells_check_preconditions, needs_to_run as broken_linkshells_needs_to_run
from migrations.char_points_weekly_unity import migration_name as char_points_weekly_unity_migration_name, check_preconditions as char_points_weekly_unity_check_preconditions, needs_to_run as char_points_weekly_unity_needs_to_run
from migrations.char_profile_unity_leader import migration_name as char_profile_unity_leader_migration_name, check_preconditions as char_profile_unity_leader_check_preconditions, needs_to_run as char_profile_unity_leader_needs_to_run
from migrations.char_timestamp import migration_name as char_timestamp_migration_name, check_preconditions as char_timestamp_check_preconditions, needs_to_run as char_timestamp_needs_to_run
from migrations.char_unlock_table_columns import migration_name as char_unlock_table_columns_migration_name, check_preconditions as char_unlock_table_columns_check_preconditions, needs_to_run as char_unlock_table_columns_needs_to_run
from migrations.crystal_storage import migration_name as crystal_storage_migration_name, check_preconditions as crystal_storage_check_preconditions, needs_to_run as crystal_storage_needs_to_run
from migrations.cop_mission_ids import migration_name as cop_mission_ids_migration_name, check_preconditions as cop_mission_ids_check_preconditions, needs_to_run as cop_mission_ids_needs_to_run
from migrations.currency_columns import migration_name as currency_columns_migration_name, check_preconditions as currency_columns_check_preconditions, needs_to_run as currency_columns_needs_to_run
from migrations.eminence_blob import migration_name as eminence_blob_migration_name, check_preconditions as eminence_blob_check_preconditions, needs_to_run as eminence_blob_needs_to_run
from migrations.extend_mission_log import migration_name as extend_mission_log_migration_name, check_preconditions as extend_mission_log_check_preconditions, needs_to_run as extend_mission_log_needs_to_run
from migrations.HP_masks_to_blobs import migration_name as HP_masks_to_blobs_migration_name, check_preconditions as HP_masks_to_blobs_check_preconditions, needs_to_run as HP_masks_to_blobs_needs_to_run
from migrations.mission_blob_extra import migration_name as mission_blob_extra_migration_name, check_preconditions as mission_blob_extra_check_preconditions, needs_to_run as mission_blob_extra_needs_to_run
from migrations.spell_blobs_to_spell_table import migration_name as spell_blobs_to_spell_table_migration_name, check_preconditions as spell_blobs_to_spell_table_check_preconditions, needs_to_run as spell_blobs_to_spell_table_needs_to_run
from migrations.spell_family_column import migration_name as spell_family_column_migration_name, check_preconditions as spell_family_column_check_preconditions, needs_to_run as spell_family_column_needs_to_run
from migrations.unnamed_flags import migration_name as unnamed_flags_migration_name, check_preconditions as unnamed_flags_check_preconditions, needs_to_run as unnamed_flags_needs_to_run

# Export all migration functions with consistent names
__all__ = [
    'unnamed_flags',
    'spell_blobs_to_spell_table',
    'char_unlock_table_columns',
    'HP_masks_to_blobs',
    'crystal_storage',
    'broken_linkshells',
    'spell_family_column',
    'extend_mission_log',
    'mission_blob_extra',
    'cop_mission_ids',
    'add_daily_tally_column',
    'add_timecreated_column',
    'eminence_blob',
    'char_timestamp',
    'currency_columns',
    'add_instance_zone_column',
    'char_points_weekly_unity',
    'char_profile_unity_leader',
]
