# Concepts and Terminology

Somleng SCFM is build around the following key concepts.

## Contacts

A [contact](https://github.com/somleng/somleng-scfm/blob/master/app/models/contact.rb) represents a person who has a [msisdn (aka: phone number)](https://en.wikipedia.org/wiki/MSISDN). Contacts are uniquely indexed by their msisdn. You cannot create two contacts with the same msisdn. Contacts can be created with custom metadata.

## Callouts

A [callout](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout.rb) represents a collection of contacts that need to be called for a particular purpose. For example, you might create a callout to notify your customers of a new product. A callout has a status and can be *started*, *stopped*, *paused* or *resumed*.

## Callout Populations

A [callout population](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout_population.rb) represents the population of a callout with participants. For example, you might create a callout population for only a subset of your customers that live in a certain area. You can inspect the callout population to see who will be called before populating it. A callout population has a status and can be *preview*, *populated*.

## Callout Participations

A [callout participation](https://github.com/somleng/somleng-scfm/blob/master/app/models/callout_participation.rb) represents a contact who needs to be called for a particular callout. One callout participation may have have multiple phone calls. Callout participations are uniquely indexed by the callout and contact. You cannot create two callout participations with the same callout and contact.

## Phone Calls

A [phone call](https://github.com/somleng/somleng-scfm/blob/master/app/models/phone_call.rb) represents a single attempt at a phone call. A phone call has a status which represents the outcome of the phone call. There may be muliple phone calls for single participation on a callout.

# Architecture

<pre>
    +----------------+
    |   Contacts     |
    +----------------+
 +--| * id           |---+
 |  | * msisdn       |   |
 |  | * metadata     |   |
 |  |                |   |
 |  +----------------+   |
 |                       |
 |  +----------------+   |  +-----------------------+
 |  |    Callouts    |   |  | CalloutParticipations |
 |  +----------------+   |  +-----------------------+
 |  | * id           |-+ |  | * id                  |-+
 |  | * status       | | |  | * msisdn              | |
 |  | * metadata     | | |  | * metadata            | |
 |  |                | | +->| * contact_id          | |
 |  |                | +--->| * callout_id          | |
 |  |                |      |                       | |
 |  +----------------+      +---------------------- + |
 |                                                    |
 |  +----------------------------+                    |
 |  |         PhoneCalls         |                    |
 |  +----------------------------+                    |
 |  | * id                       |--+                 |
 |  | * status                   |  |                 |
 |  | * callout_participation_id |<-+-----------------+
 +->| * contact_id               |  |
    | * ...                      |  |
    +----------------------------+  |
                                    |
    +----------------------------+  |
    |     PhoneCallEvents        |  |
    +----------------------------+  |
    | * id                       |  |
    | * metadata                 |  |
    | * phone_call_id            |<-+
    | * ...                      |
    +----------------------------+
</pre>

