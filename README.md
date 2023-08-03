# Somleng SCFM

![Build](https://github.com/somleng/somleng-scfm/workflows/Build/badge.svg)
[![View performance data on Skylight](https://badges.skylight.io/status/YxPzpqwXsqPx.svg)](https://oss.skylight.io/app/applications/YxPzpqwXsqPx)

Somleng Simple Call Flow Manager (Somleng SCFM) (part of [The Somleng Project](https://github.com/somleng/somleng-project)) is an Open Source Contact Management System and Call Flow manager. It can manage both inbound and outbound calls through [Somleng](https://github.com/somleng/somleng) or [Twilio](https://www.twilio.com/).

Somleng SCFM is best used via the [REST API](https://www.somleng.org/docs/scfm). There is also a dashboard available so you can play around without writing any code.

This repository includes the following core features:

* [REST API](https://www.somleng.org/docs/scfm)
* [Terraform infrastructure as code](https://github.com/somleng/somleng-scfm/tree/develop/infrastructure) for deployment to AWS
* Dashboard

## Concepts

SCFM contains the following core concepts:

* Contact - A person with a phone number and optional custom metadata.
* Callout - A callout to a group of people with a call flow logic defined as code.
* Callout Participation - A participation of a contact in a callout.
* Phone Call - A phone call to the participation.

Unlike [RapidPro](https://community.rapidpro.io/), which provides a graphical user interface for designing call flows, SCFM is powered by programmable call-flow logic.

## Documentation

* [SCFM REST API](https://www.somleng.org/docs/scfm)

## Usage

Somleng SCFM can be run independent of Somleng, so it's not a requirement to have to full Somleng stack up and running. If you want actual phone calls to be delivered/answered then you can either run the full Somleng stack on your development machine by following the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide, or you can connect it to Twilio. Both options can be configured via the Dashboard.

## Deployment

The [infrastructure directory](https://github.com/somleng/somleng-scfm/tree/develop/infrastructure) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy Somleng SCFM to AWS.

The infrastructure in this repository depends on some shared core infrastructure. This core infrastructure can be found in [The Somleng Project](https://github.com/somleng/somleng-project/tree/master/infrastructure) repository.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
