# Riak TS 3.0.0 Release Notes

This is the result of uplifting and merging riak\_ts-1.5.2 branches in
riak\_kv, riak\_core (and some others) onto riak_kv\-3.0.9, with the
addition of features (notably, support for LIMIT/ORDER BY and query
buffers) originally to be included in riak\_ts-1.6.0. It is built and
tested on OTP-22.

This release was made possible through sponsorship from [TI Tokyo](https://tiot.jp).

Relevant integration tests can be found in branch
[riak_ts-develop]("https://github.com/TI-Tokyo/riak_test/tree/riak_ts-develop/tests")
of riak\_test repo (ts\_*).

# Riak TS 1.5.2 Release Notes
* http://docs.basho.com/riak/ts/1.5.2/releasenotes/

# Riak TS 1.5.1 Release Notes
* http://docs.basho.com/riak/ts/1.5.1/releasenotes/

# Riak TS 1.5.0 Release Notes
* http://docs.basho.com/riak/ts/1.5.0/releasenotes/

# Riak TS 1.4.0 Release Notes
* http://docs.basho.com/riak/ts/1.4.0/releasenotes/

# Riak TS 1.3.0 Release Notes
* http://docs.basho.com/riak/ts/1.3.0/releasenotes/


# Riak TS 0.9 (Beta) Release Notes

Released November 24, 2015.

Riak TS is a distributed NoSQL database architected to aggregate and analyze massive amounts of sequenced time series data. The Beta release is intended to test the ability to write and read time series data in Riak TS at an appropriate performance level, and better understand customer needs so we can improve future versions of the product.

## Functionality
Features included in 0.9:

* Defining and configuring time series bucket type, including:
  * Data locality based on composite key (including time quantum)
  * Generate schema as bucket properties and install in a bucket type
* Writing data to the time series buckets
* Query TS data using a subset of SQL
* Near-linear scaling
* Ability to store structured and semi-structured data
* Single key gets and deletes
* Clients: Java, Python, Ruby, and Erlang

Features not supported in Beta:

* AAE
* Time series data in Riak Search or SOLR
* MapReduce support for time series data
* Support for Basho Data Platform
* Performance numbers and tuning will be available with the GA of TS 1.0 only
* MDC support
* Running KV and TS workloads in the same cluster
* Upgrades from existing KV clusters to TS clusters


## Known Issues
* When invoking `riak-admin` to create a TS bucket type, do so as the user who
  runs Riak (`riak` if using the Basho packages). Invoking it as another user
  will result in shell script errors related to improper escaping of the JSON.
* For Beta, AAE must be turned off.
* Queries can only range over 1 to 4 quanta
  * If you write too large a range your query will generate too many sub-queries and the query system will refuse to run it.
    * Example: Assume a default system with a 15min quanta.
    * A query of “time > 1 o’clock and time < 2 o’clock” will be fine because it covers 4 quanta.
    * A query of “time > 1 o’clock and time < 3 o’clock” will fail because it covers more than 4 quanta.
