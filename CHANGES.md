0.1.27 (2015-11-03)
-------------------

* Fix: Allow attributes to have value = 'test' by monkey patching activemodel

0.1.26 (2015-09-11)
-------------------

* FIX: Discard empty string attributes before saving the document, since DynamoDB does not store these by design

0.1.25 (2015-09-11)
-------------------

* Add missing syntax update for primary_key hash

0.1.24 (2015-09-11)
-------------------

* Add missing translations

0.1.23 (2015-09-09)
-------------------

* New - add support to toggle validation of records on save
* increase robustness of number type handling


0.1.22 (2015-09-09)
-------------------

* Fix/New - Check document validity before storing the document
* Change - permit storing nil values on boolean fields, fields need to be able to be nil on creation (in the current implementation), thus permit nil as value even on a boolean field

0.1.21 (2015-09-09)
-------------------

* Fix logic to check for resp.item.nil? on mismatching get_item requests

0.1.20 (2015-09-09)
-------------------

* Fix - do not coerce a BigDecimal from nil, when typecasting Numeric values

0.1.19 (2015-09-09)
-------------------

* New/Fix - support deletion of documents with range key

0.1.18 (2015-09-09)
-------------------

* remove stale pry require

0.1.17 (2015-09-08)
-------------------

* Use simple_attributes: false by default and enforce/ coerce attributes to be of specified Class as per model

0.1.16 (2015-09-04)
-------------------

* New - Add boolean field type support and introduce type checking on setting field values to assert correct type coercion, when setting values

0.1.15 (2015-09-04)
-------------------

* New - add query proxy method, to support arbitrary queries to dynamodb

0.1.14 (2015-08-31)
-------------------

* Fix - TinyDyno::Document.create now returns either the persisted document or nil

0.1.13 (2015-07-06)
-------------------

* Fix - return nil (not false), when a .where lookup does not match a document

0.1.12 (2015-07-04)
-------------------

* New - simple range_key support

0.1.11 (2015-07-04)
-------------------

* Fix - retract update_item support
        Instead add a modified put operation, which will overwrite an entire record, when saving an update to an already existing object
        
0.1.10 (2015-07-04)
-------------------

* New - (basic) update_item support, for atomic PUT and DELETE actions, no support for ADD action yet

0.1.9 (2015-07-01)
-----------------

* Fixes - clean up of a few stale require 'pry'

0.1.8 (2015-07-01)
------------------

* Fixes - Raise Error, if multiple hash keys are being defined
* Fixes - On Create use 'expected' clause to achieve intended behavior on create,
          to not overwrite an existing record, but only create a new record

