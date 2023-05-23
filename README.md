# adi-dp-dbt-utils

This repository contains the common dbt macros and tests that can be used across the Aboitiz Data Innovation's dbt projects. 

## Dependencies

Some of the dbt macros in this repo uses `dbt_utils` macro. You will need to install the [dbt-utils](https://github.com/dbt-labs/dbt-utils) package as well.

## Installation

Install `adi_dp_dbt_utils` as a dbt public git package. Add the following to your dbt project's `packages.yml` and run `dbt deps`.

```
packages:
  - git: "https://github.com/aboitiz-data-innovation/adi-dp-dbt-utils.git"
    revision: <branch name>
```

## Usage

Calling a dbt package's macro or test is simple. Just add the dbt package's name in front of the macro or test name. For example, 

```

{% macro some_macro() %}

  ...

  {{ adi_dp_dbt_utils.macro_a() }}

  ...

{%- endmacro -%}

```

## Uninstall

To uninstall dbt packages, run `dbt clean`.

## Contributing

To contribute to this dbt package, clone the repo, and install the repo as a local package. In your dbt project's `packages.yml` add the following and run `dbt deps`.

```
packages:
  - local: "/path/to/adi-dp-dbt-utils/adi_dp_dbt_utils"
```

> Note: After you have made changes to the local `adi-dp-dbt-utils` repo, you don't have to run `dbt deps` again because dbt can automatically detects the changes. Just rerun your test or model to validate your work.

Refer to this excellent [guide](https://discourse.getdbt.com/t/contributing-to-an-external-dbt-package/657) that explains how to contribute to an external dbt package.
