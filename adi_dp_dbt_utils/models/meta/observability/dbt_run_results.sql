{{
  config(
    materialized = 'incremental',
    transient = False,
    unique_key = 'result_id'
  )
}}

with empty_table as (
    select
        cast(null as string) as result_id,
        cast(null as string) as invocation_id,
        cast(null as string) as unique_id,
        cast(null as string) as database_name,
        cast(null as string) as schema_name,
        cast(null as string) as target,
        cast(null as string) as name,
        cast(null as string) as resource_type,
        cast(null as string) as status,
        cast(null as timestamp) as run_start,
        cast(null as float) as execution_time,
        cast(null as int) as rows_affected,
        cast(null as int) as failures,
        cast(null as string) as test_name,
        cast(null as string) as column_name,
        cast(null as array<string>) as depends_on_nodes,
        cast(null as string) as test_config_where 
)

select * from empty_table
-- This is a filter so we will never actually insert these values
where 1 = 0
