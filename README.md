# Slowly changing dimension in dbt
# Motivation for this project

> If you’ve ever had a KPI for last week change out from under you, or if a member of the finance team tells you that the values they exported to Excel no longer match what your BI tool is saying, you’re probably experiencing the pain of mutable data. Working with mutable data can make you feel like you’re building your analytics on top of quicksand.

source: [dbt](https://www.getdbt.com/blog/track-data-changes-with-dbt-snapshots/)


If this is you read on friend, i wrote this for you. You are welcome!

# How to use this project

```bash
pipenv install
pipenv shell
dbt seed
dbt deps
dbt build
```

# data context

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

# Pre requisite to SCD Type 2 - Immutable Data

## Watch out mutable data is about
**You need immutable records** to build SCD Type 2 dimensions.

> If you’ve ever had a KPI for last week change out from under you, or if a member of the finance team tells you that the values they exported to Excel no longer match what your BI tool is saying, you’re probably experiencing the pain of mutable data. Working with mutable data can make you feel like you’re building your analytics on top of quicksand.

## Types of Data

**Mutable:** Records are updated in-place over time. A typical example is an orders table,  where the status column changes as the order is processed.

**Immutable:** Once a record is created, it is never updated again. A typical example is clickstream data, like a page_viewed or link_clicked. Once that event is recorded, it won’t be updated again.

## Loading Immutable data into the warehouse

:TODO based on SAF

add boilerplate columns:
- effective_from_ts
- effective_to_ts

## Why do we need dbt snapshots (change mutable to immutable data):

Applications often store data in mutable tables. The engineers that design these applications typically want to read and modify the current state of a row – recording and managing the historical values for every row in a database is extra work that costs brain power and CPU cycles.

## How to implement dbt snapshots

[How to track data changes with dbt snapshots](https://www.getdbt.com/blog/track-data-changes-with-dbt-snapshots/)

## limitations of dbt snapshots

**snapshotting will not replace having a full history table.**

Snapshots, by their very nature, are not idempotent. The results of a snapshot operation will vary depending on if you run dbt snapshot once per hour or once per day. Further, there’s no way to go back in time and re-snapshot historical data. Once a source record has been mutated, the previous state of that record is effectively lost forever. By snapshotting your sources, you can maximize the amount of data that you track, and in turn, maximize your modeling optionality.


# Handling Slow Change Dimensions (SCD) Type 2


## steps for SCD type 2

steps for handling SCD Type 2
- make sure your data is immutable (or you wont be able to reproduce history when business rules change). See section: **Pre requisite to SCD Type 2 - Immutable Data**
- identify the grain
- remove partial duplicates
- snapshot (snapshots cant handle duplicates in source so need to be removed by prior step to just active record)...thus can never truly do SCD

## identify grain

The combination of entity_id + [changing column(s)] you want to capture becomes the grain of your model.

# limitations

## dbt snapshot with multiple SCD rows

Will never be able to get all history due to snapshots only can reference the latest SCD.

example of the error when adding in multiple entries to raw_users. I have 3 entries

```csv
id,name,email,gaggle_id,created_at,updated_at
1000,Theresa Lange,theresalange@mandatoryfun.co,1000,2021-09-01 02:55:59,2022-06-10 23:59:59
1000,Theresa Lange,theresalange@aeros.co,1000,2021-09-01 02:55:59,2022-06-11 08:59:59
1000,Theresa Lange,theresalange@badtothebone.com,1000,2021-09-01 02:55:59,2022-06-12 08:59:59
```

but the snapshot will first check to see existing entries remove them e.g. first entry, but then we have 2 left. which gives us this error:

```log
23:41:51    100090 (42P18): Duplicate row detected during DML action
23:41:51    Row Values: [1000, "Theresa Lange", "theresalange@mandatoryfun.co", 1000, 1630464959000000000, 1654905599000000000, "396c5e777719a64aee7226e703372c15", 1654905599000000000, 1654905599000000000, NULL]
```

As a result we have to only give the active record to dbt's snapshot.