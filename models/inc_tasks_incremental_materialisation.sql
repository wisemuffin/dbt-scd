{{
  config(
    materialized = 'incremental',
    unique_key = 'task_id',
    on_schema_change='fail'
    )
}}
with tasks as (
    select *
    from {{ ref('stg_tasks') }}

    where true

    {% if is_incremental() %}
      and UPDATED_AT_TS > coalesce((select max(UPDATED_AT_TS) from {{ this }}), '1900-01-01')

    {% endif %}
)
, renamed as (
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
    from tasks
)
select *
from renamed