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

