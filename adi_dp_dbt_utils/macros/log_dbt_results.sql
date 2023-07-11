{% macro log_dbt_results(results) %}
    -- depends_on: {{ ref('dbt_run_results') }}
    {%- if execute -%}
        {%- set parsed_results = adi_dp_dbt_utils.parse_dbt_results(results) -%}
        {%- if parsed_results | length  > 0 -%}
            {% set insert_dbt_results_query -%}
                insert into {{ ref('dbt_run_results') }}
                    (
                        result_id,
                        invocation_id,
                        unique_id,
                        database_name,
                        schema_name,
                        target,
                        name,
                        resource_type,
                        status,
                        run_start,
                        execution_time,
                        rows_affected,
                        failures,
                        test_name,
                        column_name,
                        depends_on_nodes,
                        test_config_where
                ) values
                    {%- for parsed_result_dict in parsed_results -%}
                        {% set depends_on_nodes = parsed_result_dict.get('depends_on_nodes') %}
                        -- convert jinja2 list to sql array
                        {%- if depends_on_nodes | length  > 0 -%}
                            {% set depends_on_nodes_array = 'array' ~ depends_on_nodes|string|replace('[', '(')|replace(']', ')') %}
                        {% else %}
                            {% set depends_on_nodes_array = 'array()' %}
                        {% endif %}

                        (
                            '{{ parsed_result_dict.get('result_id') }}',
                            '{{ parsed_result_dict.get('invocation_id') }}',
                            '{{ parsed_result_dict.get('unique_id') }}',
                            '{{ parsed_result_dict.get('database_name') }}',
                            '{{ parsed_result_dict.get('schema_name') }}',
                            '{{ parsed_result_dict.get('target') }}',
                            '{{ parsed_result_dict.get('name') }}',
                            '{{ parsed_result_dict.get('resource_type') }}',
                            '{{ parsed_result_dict.get('status') }}',
                            '{{ parsed_result_dict.get('run_start') }}',
                            {{ parsed_result_dict.get('execution_time') }},
                            {{ parsed_result_dict.get('rows_affected') }},
                            {{ parsed_result_dict.get('failures') }},
                            '{{ parsed_result_dict.get('test_name') }}',
                            '{{ parsed_result_dict.get('column_name') }}',
                            {{ depends_on_nodes_array }},
                            '{{ parsed_result_dict.get('test_config_where') }}'
                        ) {{- "," if not loop.last else "" -}}
                    {%- endfor -%}
            {%- endset -%}
            {%- do run_query(insert_dbt_results_query) -%}
        {%- endif -%}
    {%- endif -%}
    -- This macro is called from an on-run-end hook and therefore must return a query txt to run. Returning an empty string will do the trick
    {{ return ('') }}
{% endmacro %}
