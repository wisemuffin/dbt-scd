# How to use this project

```bash
pipenv install
pipenv shell
dbt deps
dbt build
```

# dbt artifacts

[dbt artifacts](https://github.com/brooklyn-data/dbt_artifacts) will keep a record of all your artifacts in your snowflake warehouse.

This will upload your local metadata files and then build out the models
```bash
dbt --no-write-json run-operation upload_dbt_artifacts_v2
dbt build -s dbt_artifacts 
```

# dbt pre commit

[link](https://github.com/offbi/pre-commit-dbt)

Optionally run on every commit locally

```bash
pre-commit install
```

this will install the hooks to be run before each commit at:

.git/hooks/pre-commit

But definitely run on every pull request e.g. with github actions.

Unfortunately, you **cannot natively use pre-commit-dbt** if you are using **dbt Cloud**. But you can run checks after you push changes into Github.