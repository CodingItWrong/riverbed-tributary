# Hydrant

An iOS share extension to send content to a web service. Currently configured as a custom integration with List App.

## Setup

- Clone repo.
- Duplicate `HydrantShare/Config.sample.swift` as `HydrantShare/Config.swift` and fill in the `webhookURL` and `apiKey` values.
  - `webhookURL` should be the path `/webhooks/hydrant` under your `firehose` installation
  - `apiKey` should be the `API_KEY` environment variable set for the `firehose` installation.
- Build the app to a device.

## Attribution

“[Fire Hydrant](https://thenounproject.com/term/fire-hydrant/20308/)” by [Lee Nathan](https://thenounproject.com/howtopals/) is licensed under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)

## License

MIT
