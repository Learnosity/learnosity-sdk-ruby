# Learnosity SDK - Ruby

This gem allows to ease integration with the following Learnosity APIs,

- Author API [author-api-doc]
- Assess API [assess-api-doc]
- Data API [data-api-doc]
- Events API [events-api-doc]
- Items API [items-api-doc]
- Questions API [questions-api-doc]
- Report API [report-api-doc]

## Installation

### Ruby Gem

The SDK should be available from RubyGems [learnosity-sdk-rubygems]

    gem install learnosity-sdk

### git clone

You can build and install the SDK directly from a Git clone, with

    git clone https://github.com/Learnosity/learnosity-sdk-ruby/
    cd learnosity-sdk-ruby/
    bundle install
    rake build
    gem install --user-install pkg/learnosity-sdk-0.1.0.gem

If `bundle` is missing, you can install it with

    gem install --user-install bundler

## Usage

Some usage examples can be found in the `examples/` subdirectory.

### Init

This class generates and signs init options for all supported APIs. Its
constructor takes four mandatory arguments, and one optional argument.

- `service`: the name of the API to sign initialisation options for,
- `security_packet`: a hash with at least the `consumer_key`, optionally the
  `domain` and `timestamp`; `user_id` is also mandatory for Questions API,
- `consumer_secret`
- `request`: the request you want to get a signature for
- `action` [Data API only]: the action of your request, either `get` or `post`

The `Init#generate` method can then be used to generate the options. By default,
it will generate a JSON string. It however takes one parameter, `encode` which,
if false, will simply return a native Ruby Hash with the signed options.

Given your consumer key and secret, and the request you want to run against,
say, the `items` API, you just need to instantiate the
`Learnosity::Sdk::Request::Init`, and call its `generate` method.

```ruby
require "learnosity/sdk/request/init"

security_packet = {
        'consumer_key'   => 'yis0TYCu7U9V4o7M',
        'domain'         => 'localhost',
}
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
items_request = { 'limit' => 50 }

init = Learnosity::Sdk::Request::Init.new(
        'items',
        security_packet,
        consumer_secret,
        items_request
)

puts init.generate
```

This will return a string of signed options suitable for initialisation of
the API.

```html
<html>
    <head>
    </head>

    <body>
	    <script src="//items.learnosity.com/"></script>

	    <script>
	    var itemsApp = LearnosityItems.init(INSERT OPTIONS HERE);
	    </script>

    </body>
</html>
```


### Data API

When the `service` parameter is `data`, the `action` parameter is mandatory.
Moreover, `Init#generate`'s `encode` parameter is ignored, and a native Ruby Hash
with the signed options is unconditionally returned, for use with your favourite
HTTP library (note that, regardless of the `action` parameter, you should always
send `POST` requests).

```ruby
require 'net/http'
require "learnosity/sdk/request/init"

security_packet = {
        'consumer_key'   => 'yis0TYCu7U9V4o7M',
        'domain'         => 'localhost',
}
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
data_request = { 'limit' => 50 }

init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
	'get'
)

request = init.generate

Net::HTTP.post_form URI('https://data.learnosity.com/latest/itembank/items'), request
```

### Recursive Queries

tl;dr: not currently implemented

Some requests are paginated to the `limit` passed in the request, or some
server-side default. Responses to those requests contain a `next` parameter in
their `meta` property, which can be placed in the next request to access another
page of data.

For the time being, you can iterate through pages by looping over the
`Init#new`/`Init#generate`/`Net::HTTP#post_form`, updating the `next` attribute
in the request.

	data_request['next'] = JSON.parse(res.body)['meta']['next']

This will `require 'json'` to be able to parse the response.

## Testing

Just run

    rake spec

to exercise the testsuite


[author-api-doc]: https://docs.learnosity.com/authoring/author
[assess-api-doc]: https://docs.learnosity.com/assessment/assess
[data-api-doc]: https://docs.learnosity.com/analytics/data
[events-api-doc]: https://docs.learnosity.com/analytics/events
[items-api-doc]: https://docs.learnosity.com/assessment/items
[questions-api-doc]: https://docs.learnosity.com/assessment/questions
[report-api-doc]: https://docs.learnosity.com/analytics/report
[learnosity-sdk-rubygems]: https://rubygems.org/gems/learnosity-sdk
