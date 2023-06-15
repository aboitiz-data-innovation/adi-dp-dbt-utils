{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {# Check if the model does not contain a subfolder (e.g, models created at the MODELS root folder) #}

    {% if node.fqn[1:-1]|length == 0 %}

        {%- set folder_structure_schema = '' -%}

        {# we save dbt seeds in the `dbt_seeds` schema #}
        {% if node.resource_type == 'seed' %}

            {%- if default_schema == 'prod' -%}

                {% set folder_structure_schema = 'dbt_seeds' %}

            {% else %}

                {% set folder_structure_schema = 'dbt_seeds' ~ '_' ~ default_schema | trim %}

            {% endif %}

        {% endif %}

    {% else %}

        {%- set model_layer = node.fqn[1] -%}
        {%- set db_name = node.fqn[2] -%}

        {% if model_layer == 'clean' or model_layer == 'inst' or model_layer == 'mart' %}

            {%- if default_schema == 'prod' -%}

                {% set folder_structure_schema = model_layer ~ '__' ~ db_name | trim %}

            {% else %}

                {% set folder_structure_schema = model_layer ~ '__' ~ db_name ~ '_' ~ default_schema | trim %}

            {% endif %}

        {% else %}  {# other than transform tables - sources, tests, etc. #}

            {% set folder_structure_schema = node.fqn[1:-1] | join('__') | trim %}

        {% endif %}

    {% endif %}

    {# add `custom_schema_name` to schema name if provided #}
    {%- if custom_schema_name is none -%}

        {%- set final_schema = folder_structure_schema -%}

    {%- else -%}

        {%- set final_schema = folder_structure_schema + '_' + custom_schema_name -%}

    {%- endif -%}

    {{ final_schema }}

{%- endmacro %}
