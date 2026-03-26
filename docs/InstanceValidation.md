# Instance validation

The initial screen (`src/states/initial.lua`) calls `InstanceApi:validate` (`src/api/instance.lua`) before switching to auth.

## What is checked

Validation follows [NodeInfo](https://nodeinfo.diaspora.software/) discovery, but **only the `software` object from the NodeInfo document is used as the pass/fail criterion**.

After a successful `GET` on the resolved NodeInfo URL (HTTP 200), the client treats the instance as valid **if and only if**:

- `response.software.name` is exactly the string `wildleague`.

No other NodeInfo fields (version, protocols, metadata, usage, etc.) are validated. The game does not verify API compatibility, federation, or server capabilities beyond this name check at the moment.
