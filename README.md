# How to use this project

```bash
pipenv install
pipenv shell
dbt deps
dbt build
```

# DBT artifacts

[dbt artifacts](https://github.com/brooklyn-data/dbt_artifacts) will keep a record of all your artifacts in your snowflake warehouse.

This will upload your local metadata files and then build out the models
```bash
dbt --no-write-json run-operation upload_dbt_artifacts_v2
dbt build -s dbt_artifacts 
```