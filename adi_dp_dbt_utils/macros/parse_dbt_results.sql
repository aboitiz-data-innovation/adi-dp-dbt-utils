{% macro parse_dbt_results(results) %}
    -- Create a list of parsed results
    {%- set parsed_results = [] %}
    -- Flatten results and add to list
    {% for run_result in results %}
        -- Convert the run result object to a simple dictionary
        {% set run_result_dict = run_result.to_dict() %}

        -- Get the underlying dbt graph node that was executed
        {% set node = run_result_dict.get('node') %}

        {% set test_metadata = node.get('test_metadata') %}
        {% if test_metadata %}
            {% set test_name = test_metadata.get('name') %}
        {% endif %}

        {% set node_config = node.get('config') %}

        {% set rows_affected = run_result_dict.get('adapter_response', {}).get('rows_affected', 0) %}
        {%- if not rows_affected -%}
            {% set rows_affected = 0 %}
        {%- endif -%}

        {% set failures = run_result_dict.get('failures', 0) %}
        {%- if not failures -%}
            {% set failures = 0 %}
        {%- endif -%}

        {% set parsed_result_dict = {
            'result_id': invocation_id ~ '.' ~ node.get('unique_id'),
            'invocation_id': invocation_id,
            'unique_id': node.get('unique_id'),
            'database_name': node.get('database'),
            'schema_name': node.get('schema'),
            'target': target.name,
            'name': node.get('name'),
            'resource_type': node.get('resource_type'),
            'status': run_result_dict.get('status'),
            'run_start': run_started_at,
            'execution_time': run_result_dict.get('execution_time'),
            'rows_affected': rows_affected,
            'failures': failures,
            'test_name': test_name,
            'column_name': node.get('column_name'),
            'depends_on_nodes': node.get('depends_on').get('nodes'),
            'test_config_where': node_config.get('where')
            }%}
        {% do parsed_results.append(parsed_result_dict) %}
    {% endfor %}
    {{ return(parsed_results) }}
{% endmacro %}
