{% macro location_clause() %}

  location '{{ construct_location() }}'

{%- endmacro -%}
