Camptocamp's Rancher Catalog
============================

[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)


This catalog provides Rancher templates created by Camptocamp.

It currently includes the following:

* [Conplicity](https://github.com/camptocamp/conplicity), a backup tool for Docker volumes
* A [Gogs](https://gogs.io) setup with an external PostgreSQL database
* A [Jenkins CI](https://jenkins.io) with one master and global working nodes (in swarm mode)
* A [Minio](https://www.minio.io) cloud storage stack
* Mopper, a Docker cleaning stack
* A full [Puppet](https://puppet.com)/MCollective/Puppetboard stack
* An [S3fs](https://github.com/s3fs-fuse/s3fs-fuse) stack to mount volumes from S3 buckets
* An [S3proxy](https://github.com/andrewgaul/s3proxy) stack which can be composed with the S3fs template
* [Upkick](https://github.com/camptocamp/upkick), a small tool for container unattended upgrades
* An IPsec Status stack to send IPsec tunnel metrics to a Prometheus push gateway.
* A [Terraboard](https://github.com/camptocamp/terraboard) stack


## How to use

In order to use this catalog, simply add it to your Rancher server (Admin → Settings → Add Catalog):

![Adding catalog](add_catalog.png)


## License

Copyright (c) 2017 [Camptocamp](http://www.camptocamp.com).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
