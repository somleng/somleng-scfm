# somleng-scfm

[![Build Status](https://travis-ci.org/somleng/somleng-scfm.svg?branch=master)](https://travis-ci.org/somleng/somleng-scfm)
[![Test Coverage](https://codeclimate.com/github/somleng/somleng-scfm/badges/coverage.svg)](https://codeclimate.com/github/somleng/somleng-scfm/coverage)
[![Code Climate](https://codeclimate.com/github/somleng/somleng-scfm/badges/gpa.svg)](https://codeclimate.com/github/somleng/somleng-scfm)

Somleng Simple Call Flow Manager (Somleng SCFM) can be used to enqueue, throttle, update, and process calls through [Somleng](https://github.com/somleng/twilreapi) (or [Twilio](https://www.twilio.com/))

## Architecture

<pre>
+----------------+
|   Contacts     |
+----------------+
| * msisdn       |-|-
| * metadata     |  |
|                |  |
+----------------+  |
                    |
+----------------+  | +----------------+    +-------------------+
|    Callouts    |  | |  PhoneNumbers  |    |     PhoneCalls    |
+----------------+  | +----------------+    +-------------------+
| * status       |  --> * msisdn       |    | * status          |
| * metadata     |-|--> * metadata     |-|--> * metadata        |
|                |    | * contact_id   |    | * phone_number_id |
|                |    | * callout_id   |    | * ...             |
|                |    |                |    |                   |
+----------------+    +----------------+    +-------------------+
</pre>

## Features

* Create contacts with custom metadata
* Create callouts from your contacts
* *start*, *stop*, *pause* and *resume* callouts
* Add your own metadata as JSON to *contacts*, *callouts*, *phone_numbers* and *phone_calls*
* Extend with your own [tasks](https://github.com/somleng/somleng-scfm/tree/master/app/tasks)

## Usage

See [USAGE](https://github.com/somleng/somleng-scfm/blob/master/docs/USAGE.md)

## Deployment

See [DEPLOYMENT](https://github.com/somleng/somleng-scfm/blob/master/docs/DEPLOYMENT.md)

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
