{% comment %}

    get columns that starts with a specified string from a dbt relation
    and returns it as a list.

    example usage:
    {% set col_list = adi_dp_dbt_utils.filter_columns_startswith(
        relation=source('db', 'tbl'),
        startswith='some_str',
        except=["some_col"])
    %}

{% endcomment %}

{% macro filter_columns_startswith(relation, startswith, except=[]) %}

    {% set cols = dbt_utils.get_filtered_columns_in_relation(from=relation, except=except) %}
    {% set final_cols = [] %}

    {% for col in cols %}
        {% if col.startswith(startswith) %}
            {% do final_cols.append(col) %}
        {% endif %}
    {% endfor %}

    {{ return(final_cols) }}

{%- endmacro -%}
