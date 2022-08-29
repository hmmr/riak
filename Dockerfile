FROM erlang:22 AS compile-image

RUN apt-get update && apt-get install -y cmake libboost-all-dev libpam0g-dev libncurses-dev autoconf automake

WORKDIR /usr/src/riak
COPY . /usr/src/riak

# When running in a docker container, ideally we would want our app to
# be configurable via environment variables (option --env-file to
# docker run).  For that reason, We use a pared-down, cuttlefish-less
# rebar.config.  Configuration from environment now becomes possible,
# via rebar's own method of generating sys.config from
# /sys.config.src.
RUN make rel-docker

FROM debian:11 AS runtime-image

COPY --from=compile-image /usr/src/riak/rel/riak /opt/riak

ENV LEVELED_SNAPSHOT_TIMEOUT_LONG=86400 \
    LEVELED_SNAPSHOT_TIMEOUT_SHORT=1800 \
    LEVELED_SINGLEFILE_COMPACTIONPERCENTAGE=25.0 \
    LEVELED_MAXRUNLENGTH_COMPACTIONPERCENTAGE=75.0 \
    LEVELED_MAX_RUN_LENGTH=4 \
    LEVELED_COMPACTION_TOP_HOUR=23 \
    LEVELED_COMPACTION_LOW_HOUR=0 \
    LEVELED_COMPACTION_SCORES_PERDAY=2 \
    LEVELED_COMPACTION_RUNS_PERDAY=24 \
    LEVELED_LEDGER_PAGECACHELEVEL=4 \
    LEVELED_JOURNAL_OBJECTCOUNT=200000 \
    LEVELED_JOURNAL_SIZE=1000000000 \
    LEVELED_LOG_LEVEL=info \
    LEVELED_COMPRESSION_POINT=on_receipt \
    LEVELED_COMPRESSION_METHOD=native \
    LEVELED_PENCILLER_CACHE_SIZE=20000 \
    LEVELED_CACHE_SIZE=2000 \
    LEVELED_SYNC_STRATEGY=none \
    LEVELED_DATA_ROOT="./data/leveled" \
    RIAK_REPL_FULLSYNC_USE_BACKGROUND_MANAGER=true \
    RIAK_REPL_RT_HEARTBEAT_TIMEOUT=15 \
    RIAK_REPL_RT_HEARTBEAT_INTERVAL=15 \
    RIAK_REPL_RTQ_MAX_BYTES=104857600 \
    RIAK_REPL_FULLSYNC_ON_CONNECT=true \
    RIAK_REPL_MAX_FSSINK_NODE=1 \
    RIAK_REPL_FSSOURCE_RETRY_WAIT=60 \
    RIAK_REPL_MAX_FSSOURCE_SOFT_RETRIES=100 \
    RIAK_REPL_MAX_FSSOURCE_NODE=1 \
    RIAK_REPL_MAX_FSSOURCE_CLUSTER=5 \
    RIAK_REPL_DATA_ROOT="./data/riak_repl" \
    RIAK_REPL_PROXY_GET=disabled \
    RIAK_REPL_FULLSYNC_INTERVAL=30 \
    RIAK_CORE_CLUSTER_MGR_IP="127.0.0.1" \
    RIAK_CORE_CLUSTER_MGR_PORT=10016 \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_LAST_WRITE_WINS=false \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_ALLOW_MULT=false \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_BASIC_QUORUM=false \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_NOTFOUND_OK=true \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_RW=quorum \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_DW=quorum \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_PW=0 \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_W=quorum \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_R=quorum \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_PR=0 \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_DVV_ENABLED=false \
    RIAK_CORE_DEFAULT_BUCKET_PROPS_N_VAL=3 \
    RIAK_CORE_PARTICIPATE_IN_COVERAGE=true \
    RIAK_CORE_FULL_REBALANCE_ONLEAVE=false \
    RIAK_CORE_VNODE_MANAGEMENT_TIMER=10000 \
    RIAK_CORE_USE_BACKGROUND_MANAGER=false \
    RIAK_CORE_ENABLE_CONSENSUS=false \
    RIAK_CORE_PLATFORM_LOG_DIR="./log" \
    RIAK_CORE_PLATFORM_LIB_DIR="./lib" \
    RIAK_CORE_PLATFORM_ETC_DIR="./etc" \
    RIAK_CORE_PLATFORM_DATA_DIR="./data" \
    RIAK_CORE_PLATFORM_BIN_DIR="./bin" \
    RIAK_CORE_DTRACE_SUPPORT=false \
    RIAK_CORE_DISABLE_INBOUND_HANDOFF=false \
    RIAK_CORE_DISABLE_OUTBOUND_HANDOFF=false \
    RIAK_CORE_HANDOFF_PORT=10019 \
    RIAK_CORE_HANDOFF_IP="127.0.0.1" \
    RIAK_CORE_RING_STATE_DIR="./data/ring" \
    RIAK_CORE_HANDOFF_CONCURRENCY=2 \
    RIAK_CORE_RING_CREATION_SIZE=64 \
    ELEVELDB_WHOLE_FILE_EXPIRY=true \
    ELEVELDB_EXPIRY_ENABLED=false \
    ELEVELDB_CACHE_OBJECT_WARMING=true \
    ELEVELDB_FADVISE_WILLNEED=false \
    ELEVELDB_ELEVELDB_THREADS=71 \
    ELEVELDB_VERIFY_COMPACTION=true \
    ELEVELDB_VERIFY_CHECKSUMS=true \
    ELEVELDB_BLOCK_SIZE_STEPS=16 \
    ELEVELDB_BLOCK_RESTART_INTERVAL=16 \
    ELEVELDB_SST_BLOCK_SIZE=4096 \
    ELEVELDB_BLOCK_CACHE_THRESHOLD=33554432 \
    ELEVELDB_USE_BLOOMFILTER=true \
    ELEVELDB_WRITE_BUFFER_SIZE_MAX=62914560 \
    ELEVELDB_WRITE_BUFFER_SIZE_MIN=31457280 \
    ELEVELDB_LIMITED_DEVELOPER_MEM=true \
    ELEVELDB_SYNC=false \
    ELEVELDB_TOTAL_LEVELDB_MEM_PERCENT=70 \
    ELEVELDB_DATA_ROOT="./data/leveldb" \
    ELEVELDB_COMPRESSION=lz4 \
    ELEVELDB_DELETE_THRESHOLD=1000 \
    ELEVELDB_TIERED_SLOW_LEVEL=0 \
    ELEVELDB_EXPIRY_MINUTES=0 \
    RIAK_SYSMON_BUSY_DIST_PORT=true \
    RIAK_SYSMON_BUSY_PORT=true \
    RIAK_SYSMON_PORT_LIMIT=2 \
    RIAK_SYSMON_PROCESS_LIMIT=30 \
    RIAK_SYSMON_GC_MS_LIMIT=0 \
    RIAK_SYSMON_SCHEDULE_MS_LIMIT=0 \
    RIAK_SYSMON_HEAP_WORD_LIMIT=20055500 \
    RIAK_KV_REPLRTQ_SRCQUEUELIMIT=300000 \
    RIAK_KV_WORKER_POOL_SIZE=5 \
    RIAK_KV_LOG_INDEX_FSM=false \
    RIAK_KV_TIMESERIES_QUERY_BUFFERS_INCOMPLETE_RELEASE_MS=9000 \
    RIAK_KV_TIMESERIES_QUERY_BUFFERS_EXPIRE_MS=5000 \
    RIAK_KV_TIMESERIES_QUERY_BUFFERS_HARD_WATERMARK=4294967296 \
    RIAK_KV_TIMESERIES_QUERY_BUFFERS_SOFT_WATERMARK=1073741824 \
    RIAK_KV_TIMESERIES_QUERY_BUFFERS_ROOT_PATH="./data/query_buffers" \
    RIAK_KV_TIMESERIES_QUERY_MAX_RETURNED_DATA_SIZE=10000000 \
    RIAK_KV_TIMESERIES_QUERY_MAX_RUNNING_FSMS=20 \
    RIAK_KV_TIMESERIES_QUERY_QUEUE_LENGTH=15 \
    RIAK_KV_CONCURRENT_QUERIES=3 \
    RIAK_KV_LEVELED_RELOAD_RECALC=false \
    RIAK_KV_REPLRTQ_PEER_DISCOVERY=false \
    RIAK_KV_REPLRTQ_SINKWORKERS=24 \
    RIAK_KV_REPLRTQ_SINKQUEUE=q1_ttaaefs \
    RIAK_KV_REPLRTQ_ENABLESINK=false \
    RIAK_KV_REPLRTQ_COMPRESSONWIRE=false \
    RIAK_KV_REPLRTQ_SRCQUEUE="q1_ttaaefs:block_rtq" \
    RIAK_KV_REPLRTQ_SRCOBJECTSIZE=204800 \
    RIAK_KV_REPLRTQ_SRCOBJECTLIMIT=1000 \
    RIAK_KV_REPLRTQ_ENABLESRC=false \
    RIAK_KV_AAE_FETCHCLOCKS_REPAIR=false \
    RIAK_KV_TTAAEFS_LOGREPAIRS=false \
    RIAK_KV_TTAAEFS_AUTOCHECK=24 \
    RIAK_KV_TTAAEFS_RANGECHECK=0 \
    RIAK_KV_TTAAEFS_DAYCHECK=0 \
    RIAK_KV_TTAAEFS_HOURCHECK=0 \
    RIAK_KV_TTAAEFS_NOCHECK=0 \
    RIAK_KV_TTAAEFS_ALLCHECK=0 \
    RIAK_KV_TTAAEFS_PEERPROTOCOL=pb \
    RIAK_KV_TTAAEFS_REMOTENVAL=3 \
    RIAK_KV_TTAAEFS_LOCALNVAL=3 \
    RIAK_KV_TTAAEFS_RANGEBOOST=16 \
    RIAK_KV_TTAAEFS_MAXRESULTS=32 \
    RIAK_KV_TTAAEFS_CLUSTER_SLICE=1 \
    RIAK_KV_TTAAEFS_QUEUENAME_PEER=disabled \
    RIAK_KV_TTAAEFS_QUEUENAME=q1_ttaaefs \
    RIAK_KV_TTAAEFS_SCOPE=disabled \
    RIAK_KV_AAE_USE_BACKGROUND_MANAGER=false \
    RIAK_KV_HANDOFF_REJECTED_MAX=6 \
    RIAK_KV_HANDOFF_USE_BACKGROUND_MANAGER=false \
    RIAK_KV_MAX_SIBLINGS=100 \
    RIAK_KV_WARN_SIBLINGS=25 \
    RIAK_KV_MAX_OBJECT_SIZE=512000 \
    RIAK_KV_WARN_OBJECT_SIZE=51200 \
    RIAK_KV_JMX_DUMMY=false \
    RIAK_KV_SECURE_REFERER_CHECK=true \
    RIAK_KV_MBOX_CHECK_ENABLED=true \
    RIAK_KV_RETRY_PUT_COORDINATOR_FAILURE=true \
    RIAK_KV_ANTI_ENTROPY_LEVELDB_OPTS_USE_BLOOMFILTER=true \
    RIAK_KV_ANTI_ENTROPY_LEVELDB_OPTS_MAX_OPEN_FILES=20 \
    RIAK_KV_ANTI_ENTROPY_LEVELDB_OPTS_WRITE_BUFFER_SIZE=4194304 \
    RIAK_KV_AAE_THROTTLE_ENABLED=true \
    RIAK_KV_ANTI_ENTROPY_DATA_DIR="./data/anti_entropy" \
    RIAK_KV_ANTI_ENTROPY_TICK=15000 \
    RIAK_KV_ANTI_ENTROPY_CONCURRENCY=2 \
    RIAK_KV_ANTI_ENTROPY_EXPIRE=604800000 \
    RIAK_KV_TOMBSTONE_PAUSE=2 \
    RIAK_KV_BACKEND_PAUSE_MS=10 \
    RIAK_KV_BE_WORKER_POOL_SIZE=1 \
    RIAK_KV_AF4_WORKER_POOL_SIZE=1 \
    RIAK_KV_AF3_WORKER_POOL_SIZE=4 \
    RIAK_KV_AF2_WORKER_POOL_SIZE=1 \
    RIAK_KV_AF1_WORKER_POOL_SIZE=2 \
    RIAK_KV_NODE_WORKER_POOL_SIZE=4 \
    RIAK_KV_WORKER_POOL_STRATEGY=dscp \
    RIAK_KV_TICTACAAE_PRIMARYONLY=true \
    RIAK_KV_TICTACAAE_RANGEBOOST=2 \
    RIAK_KV_TICTACAAE_REPAIRLOOPS=4 \
    RIAK_KV_TICTACAAE_MAXRESULTS=64 \
    RIAK_KV_TICTACAAE_REBUILDTICK=3600000 \
    RIAK_KV_TICTACAAE_EXCHANGETICK=480000 \
    RIAK_KV_TICTACAAE_STOREHEADS=false \
    RIAK_KV_TICTACAAE_REBUILDDELAY=345600 \
    RIAK_KV_TICTACAAE_REBUILDWAIT=336 \
    RIAK_KV_TICTACAAE_PARALLELSTORE=leveled_ko \
    RIAK_KV_REPLRTQ_OVERFLOW_LIMIT=10000000 \
    RIAK_KV_REAPER_OVERFLOW_LIMIT=10000000 \
    RIAK_KV_ERASER_OVERFLOW_LIMIT=10000000 \
    RIAK_KV_REPLRTQ_DATAROOT="./data/kv_replrtqsrc" \
    RIAK_KV_READER_DATAROOT="./data/kv_reader" \
    RIAK_KV_REAPER_DATAROOT="./data/kv_reaper" \
    RIAK_KV_ERASER_DATAROOT="./data/kv_eraser" \
    RIAK_KV_TICTACAAE_DATAROOT="./data/tictac_aae" \
    RIAK_KV_AAE_TOKENBUCKET=true \
    RIAK_KV_TICTACAAE_ACTIVE=passive \
    RIAK_KV_ANTI_ENTROPY={off,[]} \
    RIAK_KV_STORAGE_BACKEND=riak_kv_eleveldb_backend \
    RIAK_KV_ANTI_ENTROPY_BUILD_LIMIT_LO=1 \
    RIAK_KV_ANTI_ENTROPY_BUILD_LIMIT_HI=3600000 \
    RIAK_KV_FSM_LIMIT=50000 \
    RIAK_KV_OBJECT_FORMAT=v1 \
    RIAK_KV_VNODE_MD_CACHE_SIZE=0 \
    RIAK_KV_TTAAEFS_ALLCHECK_WINDOW=always \
    RIAK_KV_MAX_QUERY_QUANTA=5000 \
    RIAK_KV_TIMESERIES_QUERY_TIMEOUT_MS=10000 \
    RIAK_KV_TIMESERIES_QUERY_MAX_QUANTA_SPAN=5000 \
    RIAK_KV_TIMESERIES_MAX_CONCURRENT_QUERIES=3 \
    RIAK_DT_BINARY_COMPRESSION=1 \
    RIAK_API_PB_KEEPALIVE=true \
    RIAK_API_DISABLE_PB_NAGLE=true \
    RIAK_API_PB_BACKLOG=128 \
    RIAK_API_HTTP_IP="127.0.0.1" \
    RIAK_API_HTTP_PORT=8098 \
    RIAK_API_PB_IP="127.0.0.1" \
    RIAK_API_PB_PORT=8087 \
    RIAK_API_HONOR_CIPHER_ORDER=false \
    RIAK_API_CHECK_CRL=true \
    KERNEL_LOGGER_LEVEL=info \
    KERNEL_LOGGER_DEFAULT_FILE="./log/console.log" \
    KERNEL_LOGGER_DEFAULT_MAX_NO_BYTES=1048576 \
    KERNEL_LOGGER_DEFAULT_MAX_NO_FILES=10 \
    KERNEL_LOGGER_SASL_FILE="./log/reports.log" \
    KERNEL_LOGGER_SASL_MAX_NO_BYTES=1048576 \
    KERNEL_LOGGER_SASL_MAX_NO_FILES=10 \
    SETUP_HOME="./data/setup"

EXPOSE $RIAK_API_PB_PORT $RIAK_API_HTTP_PORT $RIAK_CORE_HANDOFF_PORT $RIAK_CORE_CLUSTER_MGR_PORT

WORKDIR /opt/riak
ENV RIAK_PATH=/opt/riak
RUN mkdir lib/schema && mv lib/*/priv/*.schema /opt/riak/lib/schema
CMD /opt/riak/bin/riak foreground
