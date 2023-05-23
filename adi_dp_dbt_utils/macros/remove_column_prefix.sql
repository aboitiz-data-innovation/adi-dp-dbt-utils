{% comment %}

    removes a specified prefix from a list of column names.
    if the column name starts with the prefix, remove the prefix.
    if the column name does not start with the prefix, return the original column name.
    returns a dict of original_col as key and renamed_col (or not renamed) as value.

    example usage:
    {% set cols_renamed_dict = adi_dp_dbt_utils.remove_column_prefix(cols_list, 'some_prefix') %}

{% endcomment %}

{% macro remove_column_prefix(col_list, prefix) %}

    {% set final_cols = {} %}

    {% for col in col_list %}

        {% if col.startswith(prefix) %}

            {% set renamed_col = col[prefix|length:] %}
            {% set _ = final_cols.update({col: renamed_col}) %}

        {% else %}

            {% set _ = final_cols.update({col: col}) %}

        {% endif %}

    {% endfor %}

    {{ return(final_cols) }}

{%- endmacro -%}
