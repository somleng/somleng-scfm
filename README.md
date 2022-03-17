# Somleng SCFM

![Build](https://github.com/somleng/somleng-scfm/workflows/Build/badge.svg)
[![View performance data on Skylight](https://badges.skylight.io/status/YxPzpqwXsqPx.svg)](https://oss.skylight.io/app/applications/YxPzpqwXsqPx)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/29407e68260442a9a84fa44222ea6364)](https://www.codacy.com/gh/somleng/somleng-scfm/dashboard?utm_source=github.com&utm_medium=referral&utm_content=somleng/somleng-scfm&utm_campaign=Badge_Coverage)

Somleng Simple Call Flow Manager (Somleng SCFM) (part of [The Somleng Project](https://github.com/somleng/somleng-project)) is an Open Source Contact Management System and Call Flow manager. It can manage both inbound and outbound calls through [Somleng](https://github.com/somleng/somleng) or [Twilio](https://www.twilio.com/).

Somleng SCFM is best used via the [REST API](https://www.somleng.org/docs/scfm). There is also a dashboard available so you can play around without writing any code.

This repository includes the following core features:

* [REST API](https://www.somleng.org/docs/scfm)
* Dashboard
* [Terraform infrastructure as code](https://github.com/somleng/somleng-scfm/tree/develop/infrastructure) for deployment to AWS

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

:warning: The current infrastructure of Somleng SCFM is rapidly changing as we continue to improve and experiment with new features. We often make breaking changes to the current infrastructure which usually requires some manual migration. We don't recommend that you try to deploy and run your own Somleng stack for production purposes at this stage.

The infrastructure in this repository depends on some shared core infrastructure. This core infrastructure can be found in [The Somleng Project](https://github.com/somleng/somleng-project/tree/master/infrastructure) repository.

The current infrastructure deploys Somleng SCFM to AWS behind an Application Load Balancer (ALB) to Elastic Container Service (ECS). There are two main tasks, a webserver task and a worker task. The webserver task has an [NGINX container](https://github.com/somleng/somleng-scfm/blob/develop/docker/nginx/Dockerfile) which runs as a reverse proxy to the main [Rails webserver container](https://github.com/somleng/somleng-scfm/blob/develop/Dockerfile). The worker task runs as a separate ECS service.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
