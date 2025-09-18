# Admin Guide

This section provides everything you need to deploy, configure, and customize OnDemand Loop in production environments. Whether you're setting up environment variables, managing YAML configuration files, or customizing the user interface, this guide is your comprehensive reference for system administration.

### Quick Start

OnDemand Loop configuration is managed through the `ConfigurationSingleton` class, which provides a centralized interface for accessing all configurable properties. Each property has sensible defaults and can be overridden using:

1. **Environment Variables** — Loaded from `.env` files or system-level environment variables
2. **YAML Files** — Located in `/etc/loop/config/loop.d` by default

The documentation is organized by topic to help you find what you need quickly:

- [Configuration](configuration.md)
  Core system settings, paths, timeouts, and runtime behavior that control how OnDemand Loop operates in your environment.

- [Customizations](customizations.md)
  Interface customization, branding, and navigation modifications to tailor OnDemand Loop for your organization.

Each page is self-contained but builds on shared understanding of the configuration system.
If you're new to OnDemand Loop administration, we recommend starting with:

- [Configuration](configuration.md)
- [Setting Configuration Values](configuration.md#setting-configuration-values)