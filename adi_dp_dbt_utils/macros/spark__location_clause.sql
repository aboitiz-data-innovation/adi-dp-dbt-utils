{% macro spark__location_clause() %}

  location '{{ construct_location() }}'

{%- endmacro -%}
