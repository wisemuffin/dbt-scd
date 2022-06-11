# How to use this project

```bash
pipenv install
pipenv shell
dbt seed
dbt deps
dbt build
```

# data

I am using the data from [customer-360-view-identity-resolution dbt blog](https://docs.getdbt.com/blog/customer-360-view-identity-resolution) the data consists of:

- 823 gaggles
- 5,781 users (unique by email, can only be associated with one gaggle)
- 120,307 events (‘recipe_viewed’, ‘recipe_favorited’, or ‘order_placed’)

# dbt artifacts

[dbt artifacts](https://github.com/brooklyn-data/dbt_artifacts) will keep a record of all your artifacts in your snowflake warehouse.

This will upload your local metadata files and then build out the models
```bash
dbt --no-write-json run-operation upload_dbt_artifacts_v2
dbt build -s dbt_artifacts 
```

# dbt pre commit

[link](https://github.com/offbi/pre-commit-dbt)

Optionally run on every commit locally. As it takes a bit of time to run might be better to just run this when pull request created.

```bash
pre-commit install
```

this will install the hooks to be run before each commit at:

.git/hooks/pre-commit

But definitely run on every pull request e.g. with github actions.

Unfortunately, you **cannot natively use pre-commit-dbt** if you are using **dbt Cloud**. But you can run checks after you push changes into Github.