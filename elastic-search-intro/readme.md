# Setup

Start elasticsearch with docker

```
docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch \
-e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.6.2
```

Check if you are getting some response from elasticsearch (You may need to wait for the elasticsearch to startup).

```
curl -XGET localhost:9200
```

You can check the health of the elasticsearch cluster by running.

```
curl localhost:9200/_cluster/health?pretty
```

# Insert Data

An Elasticsearch cluster can contain multiple Indices (databases), which in turn contain multiple Types (tables). These types hold multiple Documents (rows), and each document has Properties(columns). The index allows the elasticsearch to partition data across the different shards. For logging application, a standard format is to assign a new index for each day, e.g.
- logs-2021-09-01
- logs-2021-09-02
- logs-2021-09-03


Example: The following command will add a person document to the "test" index with the type "users".

```
curl -XPOST -H "Content-Type: application/json" localhost:9200/test/users/1?pretty -d '{
    "first_name": "Thomas",
    "last_name": "Chan",
    "gender": "male",
    "hobbies": "I like playing badminton",
    "age": 25
}'
```

We can also send the JSON from file `data.json`.

```
curl -XPOST -H "Content-Type: application/json" localhost:9200/test/users/_bulk?pretty --data-binary "@test.json"
```

Define `test.json` as follows.
```
{"index": {}}
{"first_name": "Alice","last_name": "Wong","gender": "female", "age": 33}
{"index": {}}
{"first_name": "Sammy","last_name": "Chung","gender": "male", "age": 55, "city": "Hong kong"}


```


# Query/Search
Searching and querying takes the format of: http://localhost:9200/[index]/[type]/[operation]

Search all documents.
```
curl -XGET localhost:9200/test/users/_search?pretty
```


Get document by ID
```
curl -XGET localhost:9200/test/users/1?pretty
```



Full text search:

```
curl -XGET -H 'Content-Type: application/json' localhost:9200/test/users/_search?pretty -d '{
    "query": {
        "match": {
            "hobbies": "badminton"
        }
    }
}'
```

Partial match:

```
curl -XGET -H 'Content-Type: application/json' localhost:9200/test/users/_search?pretty -d '{
    "query": {
        "query_string": {
            "query": "play*",
            "fields": ["hobbies"]
        }
    }
}'
```

# Update


Option 1: Replace the whole document.

```
curl -XPUT -H "Content-Type: application/json" localhost:9200/test/users/1?pretty -d '{
    "first_name": "Thomas",
    "last_name": "Chan",
    "gender": "male",
    "hobbies": "I like playing badminton",
    "age": 27
}'
```

Check the updated document.

```
curl -XGET localhost:9200/test/users/1?pretty
```


Option 2: Update a single field in a document.

curl -XPOST -H "Content-Type: application/json" localhost:9200/test/_update/1?pretty -d '{ "doc":{ "hobbies": "I like playing badminton and piano" } }'


Check the updated document.

```
curl -XGET localhost:9200/test/users/1?pretty
```



# Delete

Examples:

```
curl -XDELETE localhost:9200/test/users/1?pretty
```

Check that the document with ID 1 is deleted.

```
curl -XGET localhost:9200/test/users/_search?pretty
```



# Sample data

Sample data:

```
https://www.elastic.co/guide/en/kibana/6.8/tutorial-load-dataset.html
```

Download the sample data:

```
wget https://download.elastic.co/demos/kibana/gettingstarted/shakespeare_6.0.json
wget https://download.elastic.co/demos/kibana/gettingstarted/accounts.zip
wget https://download.elastic.co/demos/kibana/gettingstarted/logs.jsonl.gz
```

Unzip the files:

```
unzip accounts.zip
gzip logs.jsonl.gz
```

View the downloaded data.

```
head shakespeare_6.0.json
head accounts.json
head logs.jsonl
```


Index the downloaded data into elasticsearch.

```
curl -XPOST -H "Content-Type: application/json" localhost:9200/accounts/_bulk?pretty --data-binary "@accounts.json"
```

```
curl -XPOST -H "Content-Type: application/json" localhost:9200/accounts/_bulk?pretty --data-binary "@shakespeare_6.0.json"
```

```
curl -XPOST -H "Content-Type: application/json" localhost:9200/accounts/_bulk?pretty --data-binary "@logs.jsonl"
```


# Running Kibana

```
docker run -d --link elasticsearch:elasticsearch -p 5601:5601 --name kibana docker.elastic.co/kibana/kibana:7.6.2
```


Access Kibana at `http://localhost:5601` in browser.

Under the Discover tab (left menu bar), 
- Create an index pattern: logstash*
- Select Time Filter field name: @timestamp

Click the `Discover` button again to view the logs.

Select the time (e.g. to show the Last 15 years) to show all log entries.

# Reference
 - https://www.katacoda.com/liptanbiswas/scenarios/elasticsearch-intro
 - https://www.elastic.co/blog/what-is-an-elasticsearch-index
 - https://www.youtube.com/watch?v=gS_nHTWZEJ8
