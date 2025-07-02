---
name: Deployment Build
about: Follow these steps to prepare and publish a deployment build for QA and Production
title: "Deployment Build: version: "
labels: deployment_build
assignees: ''
---

Follow the steps below to prepare a deployment build of OnDemand Loop.

> \U0001F4A1 This process creates and publishes build artifacts to environment branches. **Deployment itself is performed externally (e.g., by Puppet).**

1. **Prepare the issue**
   - Ensure the title starts with `Deployment Build: version: <tag>`.  
     Example:
     ```
     Deployment Build: version: v0.5.13+2025-07-01
     ```
   - Assign at least one maintainer to this issue.

2. **Create a QA deployment build**
   - Comment the following slash command on this issue:
     ```
     /deployment_build env=QA
     ```
   - This builds the specified version and pushes it to the `iqss_qa` branch.

3. **Test and approve**
   - Test the deployment in the QA environment.
   - When ready, approve the deployment by commenting:
     ```
     build approved
     ```

4. **Create a Production deployment build**
   - After approval, publish to production by commenting:
     ```
     /deployment_build env=Production
     ```
   - This pushes the same version to a new production branch (e.g., `iqss_production_<version>`).

5. **Finish up**
   - The workflow will comment with the result of the build publication (success or failure), including a link to the workflow run.
   - Close this issue once the production deployment is complete and verified.

_Only authorized users can execute the slash commands above._
