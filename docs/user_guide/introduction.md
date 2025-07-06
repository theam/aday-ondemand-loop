# Introduction

OnDemand Loop is a companion application for [Open OnDemand](https://openondemand.org/) that lets you move data between HPC storage and remote repositories. It uses a pluggable connector framework so new services can be added easily. [Dataverse](https://dataverse.org/) is the reference connector and others such as Zenodo can also be enabled.

You organise your work using **projects**. A project keeps everything you download from or upload to a specific repository. Inside a project you create **download files** to pull remote data to the cluster, and **upload bundles** to stage local files for pushing results back to a dataset. Each bundle targets a single dataset but you can create multiple bundles within the same project.
