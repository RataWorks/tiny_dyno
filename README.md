Minimalist ODM for commonly used operations with dynamodb.
==========================================================

This is not a complete ODM for DynamoDB!
Check https://gitter.im/aws/aws-sdk-ruby or http://ruby.awsblog.com/ for that instead, rumour has it one might be appearing soon.

This work is heavily influenced in layout by the awesome mongoid gem, which I have used for years. Since I shouldn't be writing a full ODM I have borrowed as much as needed, especially to implement ActiveSupport::Concern way of module dependency resolution.
I also shied away from reinventing perfectly valid methods if they were in Mongoid. So, if code looks familiar to you, it probably is.

So, thanks goes to Durran Jordan @ mongoid/mongoid. 

Beyond that, TinyDyno is a <working>, no frills abstraction to work with DynamoDB on EC2 within ruby apps.

If you're new to DynamoDB, it is highly recommended to read the following:

[GettingStartedDynamoDB](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html)

[GuidelinesForTables](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GuidelinesForTables.html)


Supported Operations
--------------------

create_table
------------

Indexes in dynamo are created at table creation time.

either Model.create_table

rake tiny_dyno:create_tables

delete_table
------------

Model.delete_table

put_item
--------

http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method
Invoked upon create/create!

supported keys;

* table_name
* item

update_item
-----------

http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#update_item-instance_method
Invoked upon save on existing objects.

supported_keys;

* table_name
* key
* attribute_updates


Installation
============

Add this line to your application's Gemfile:

```ruby
gem 'tiny_dyno'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tiny_dyno

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RataWorks/tiny_dyno.

