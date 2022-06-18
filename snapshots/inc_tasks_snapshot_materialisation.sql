{% snapshot inc_tasks_snapshot_materialisation %}

{{
   config(
       target_schema='snapshot',
       unique_key='task_id',

       strategy='timestamp',
       updated_at='UPDATED_AT_TS',
   )
}}

select 
    EMAIL,
    TITLE,
    TASK_ID,
    {# DUE_DATE,
    PRIORITY,
    START_DATE, #}
    DESCRIPTION,
    IS_DELETED_YN,
    UPDATED_AT_TS
from {{ ref('stg_tasks') }}

{% endsnapshot %}