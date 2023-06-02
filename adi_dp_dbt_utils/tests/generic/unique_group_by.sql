{% comment %}

    extends the original dbt-core `unique` test with the
    additional optional parameter `group_by`. sometimes we want to
    check if a column is unique, but only want to compare
    by groups (i.e. based on another categorical column).

    args:
    -----
        group_by: an optional list of other column names to group by

    example usage:
    --------------
    version: 2
    models:
    - name: some_model
        columns:
        - name: some_unique_column_based_on_groups
            tests:
            - unique_group_by:
                group_by: ["some_categorical_column"]

{% endcomment %}

{% test unique_group_by(model, column_name, group_by=[]) %}

    {% set group_bys_str = ([column_name] + group_by) | join(', ') %}

    select *
    from (

        select
            {{ column_name }}

        from {{ model }}
        where {{ column_name }} is not null
        group by {{ group_bys_str }}
        having count(*) > 1

    ) validation_errors

{%- endtest -%}
