#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraperwiki'
require 'wikidata/fetcher'
require 'csv'

query = <<QUERY
SELECT ?item ?itemLabel ?itemAltLabel ?start ?end ?email ?constituency
WHERE
{
  ?item p:P39 ?position .
    OPTIONAL { ?item wdt:P968 ?email . }
    ?position ps:P39 wd:Q21328621 ;
              pq:P2937 wd:Q28861051 .
    OPTIONAL { ?position pq:P580 ?start . }
    OPTIONAL { ?position pq:P582 ?end . }
    OPTIONAL { ?position pq:P768 ?constituency . }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
}
QUERY

WIKIDATA_SPARQL_ENDPOINT = 'https://query.wikidata.org/sparql'

result = RestClient.get(WIKIDATA_SPARQL_ENDPOINT, params: { query: query }, accept: 'text/csv')
data = CSV.parse(result.to_s, headers: true, header_converters: :symbol, converters: nil)

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite(%i(item), data.map(&:to_h))
