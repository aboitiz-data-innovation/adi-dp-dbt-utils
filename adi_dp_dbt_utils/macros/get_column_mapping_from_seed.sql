{% comment %}

    this macro expects the csv seed file to have 2 columns.
    one column represents the original column name called 'original',
    another column represents the mapped column name called 'mapped'.
    you can override the default column names by passing other values into
    `original_column_name` and `mapped_column_name`.

    example usage:
    --------------
    {% set column_mapping = adi_dp_dbt_utils.get_column_mapping_from_seed(ref('seed_name')) %}

{% endcomment %}

{% macro get_column_mapping_from_seed(seed_relation, original_column_name='original', mapped_column_name='mapped', except=[]) %}

    {% set original_column_name = original_column_name %}
    {% set mapped_column_name = mapped_column_name %}

    {% set sql_statement %}
        select {{ original_column_name }}, {{ mapped_column_name }} from {{ seed_relation }}
    {% endset %}

    {%- set column_mapping = dbt_utils.get_query_results_as_dict(sql_statement) -%}

    {%- set result = {} -%}
    {% for ori, mapped in zip(column_mapping[original_column_name], column_mapping[mapped_column_name]) %}
        {% if ori not in except %}
            {% set _ = result.update({ori: mapped}) %}
        {% endif %}
    {% endfor %}

    {{ return(result) }}

{%- endmacro -%}
