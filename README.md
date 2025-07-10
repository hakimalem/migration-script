## Project Migration Script

This script migrates all existing projects to conform to the new project model requirements.

### Migration Logic

- **Attributes kept as they are (copied from old to new):**
  - `acronym`
  - `type` (set to `"FundedProject"`)
  - `name`
  - `homePage`
  - `description`
  - `created`
  - `updated`
  - `creator`

- **Attributes required in the new model but missing in old:**
  - `keywords`: Set to `[acronym]` (array with the acronym) because `keywords` is required.
  - `ontologyUsed`: If missing or empty, set to `["https://data.earthportal.eu/ontologies/SWEET"]` (required in new model).

- **Attributes set to `nil` (not required and did not exist in old model):**
  - `contact`
  - `organization`
  - `grant_number`
  - `start_date`
  - `end_date`
  - `funder`
  - `logo`
  - `source`
