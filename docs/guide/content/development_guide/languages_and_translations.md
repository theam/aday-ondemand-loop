# Languages and Translations

OnDemand Loop uses Rails' internationalization (I18n) framework to manage text in the user interface. Translation files live under `application/config/locales` and are organized by component (for example, `views`, `controllers`, and `shared`). Connector-specific translations are grouped under `application/config/locales/connectors/<connector>` so each connector keeps its own locale files. Only English translations (`en.yml`) are provided by default.

## Translation files

Each directory contains a file per language. The English translations are stored in files ending with `en.yml`. Connector folders can also contain nested subdirectories such as `controllers` when a connector needs more granular organization. When adding another language, replicate the directory structure and provide a corresponding `<locale>.yml` file with translated strings.

## Adding a new language

1. **Create locale files** – Copy the existing English files and rename them with the new locale code. For example, to add French, create `application/config/locales/views/fr.yml` and equivalents for `controllers`, `shared`, and any connectors you need.
2. **Register the locale** – Edit `application/config/initializers/locale.rb` and add the new code to `I18n.available_locales`.
3. **Set the default (optional)** – To make the new language the default, update `Configuration.locale` or set the `OOD_LOOP_LOCALE` environment variable.
4. **Provide translations** – Replace the English strings in each new file with translations.
5. **Rebuild the guide** – Run `make guide` to regenerate documentation if you added docs for the new language.

Once these steps are complete, the new language can be selected by users via the `?locale=` parameter or through any configured language selector in the interface.
