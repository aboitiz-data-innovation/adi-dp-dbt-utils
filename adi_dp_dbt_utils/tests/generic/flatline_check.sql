{% comment %}

    checks if the value of the specified column is flatlining,
    i.e. value does not change for a period of time.

    args:
    -----
        ts_column_name: name of timestamp column
        count: a positive integer. e.g. count=1, period=hour, the flatlining
            check will be done on the most recent 1 hour data from the current timestamp
        period: minute | hour | day | month | year
        consecutive_thresh: the test fails when the number of
            consecutive flatlining data points is more than or
            equal to this value 

    example usage:
    --------------
    version: 2
    models:
    - name: some_model
        columns:
        - name: some_column
            tests:
            - flatline_check:
                ts_column_name: timestamp
                count: 1
                period: hour
                consecutive_thresh: 3

{% endcomment %}

{% test flatline_check(model, column_name, ts_column_name, count, period, consecutive_thresh) %}

    {% set column_name = column_name %}
    {% set ts_column_name = ts_column_name %}
    {% set where_clause %}
        {{ ts_column_name }} >= current_timestamp - interval {{ count }} {{ period }} 
    {% endset %}

    {% set base_query_str %}
        select
            {{ ts_column_name }} as ts,
            {{ column_name }} as col_to_check
        from {{ model }}
        where {{ where_clause }}
        order by {{ ts_column_name }} desc
        limit {{ consecutive_thresh }}
    {% endset %}

    {% if execute %}
        {% set sql_statement %}
            select distinct
                col_to_check
            from ({{ base_query_str }})
        {% endset %}
        {% set results = run_query(sql_statement) %}
        {% set col_to_check_distinct_values = results.columns[0].values() %}
    {% else %}
        {% set col_to_check_distinct_values = [] %}
    {% endif %}

    -- raise exception if base has no rows returned
    {% set row_cnt_check_sql_statement %}
        select count(*) from (
            {{ base_query_str }}
        )
    {% endset %}

    -- only run this block during actual dbt executions, not during dbt compilations
    {% if execute %}
        {% set row_cnt = dbt_utils.get_single_value(row_cnt_check_sql_statement) %}
        {% if row_cnt == 0 %}
            {{ exceptions.raise_compiler_error("Flatline check failed because the model returns no records when filtering for the data for validation. Query: " ~ base_query_str) }}
        {% endif %}
    {% endif %}

    {% set col_to_check_distinct_values_tuple_str = '(' ~ col_to_check_distinct_values|join(',') ~ ')' %}

    with base as (
        {{ base_query_str }}
    ),

    grouped as (
        select
            col_to_check,
            count(*) as cnt
        from base 
        group by col_to_check
    )

    select
        *
    from grouped
    {% if col_to_check_distinct_values|length > 1 %} {# test passed - return no rows #}
        where col_to_check not in {{ col_to_check_distinct_values_tuple_str }}
    {% else %} {# test failed - return > 0 rows #}
        where col_to_check in {{ col_to_check_distinct_values_tuple_str }}
    {% endif %}

{% endtest %}
