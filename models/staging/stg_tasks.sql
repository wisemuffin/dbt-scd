with source as (
    select *
    from {{ source('mydb', 'tasks') }}
    where true
    {# and _AB_CDC_UPDATED_AT = '1970-01-01T00:00:00Z' #}
)
, renamed as (
    select 
        EMAIL,
        TITLE,
        TASK_ID,
        DUE_DATE,
        PRIORITY,
        START_DATE,
        DESCRIPTION,
        case when _AB_CDC_DELETED_AT is null then 'N' else 'Y' end as IS_DELETED_YN,
        _AB_CDC_UPDATED_AT as UPDATED_AT_TS,
        _AB_CDC_LOG_POS,
        _AB_CDC_LOG_FILE,
        _AB_CDC_DELETED_AT,
        _AB_CDC_UPDATED_AT,
        _AIRBYTE_AB_ID,
        _AIRBYTE_EMITTED_AT,
        _AIRBYTE_NORMALIZED_AT,
        _AIRBYTE_TASKS_HASHID
    from source
)
select * 
from renamed