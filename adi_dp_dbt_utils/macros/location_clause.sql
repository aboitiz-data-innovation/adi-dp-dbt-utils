{% macro location_clause() %}

  {%- set default_schema = target.schema -%}
  {%- set location_root = config.get('location_root', validator=validation.any[basestring]) -%}
  {%- set identifier = model['alias'] -%}
  {%- set fqn = model['fqn'] -%}

  {%- set catalog = model['database'] -%}
  {%- set model_layer = fqn[1] -%}

  {%- if location_root is not none %}

    {%- set location = location_root ~ '/' ~ identifier -%}

  {%- else -%}

    {%- set s3_bucket = 'aidia-' ~ catalog|replace("_", "-") -%}
    {%- set db_name = fqn[2] -%}

    {%- if model_layer == 'clean' or model_layer == 'inst' -%}

      {%- if target_schema == 'prod' -%}

        {%- set location = 's3://' ~ s3_bucket ~ '/' ~ model_layer ~ '/' ~ db_name ~ '/' ~ identifier -%}

      {%- else -%}

        {%- set location = 's3://' ~ s3_bucket ~ '/' ~ model_layer ~ '/' ~ db_name ~ '_' ~ default_schema ~ '/' ~ identifier -%}

      {%- endif -%}

    {%- endif %}

  {%- endif %}

  {{ log('Writing the data files to ' ~ location, True) }}
  location '{{ location }}'

{%- endmacro -%}
