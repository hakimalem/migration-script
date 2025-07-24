# Project Migration Script

This script migrates all existing projects to conform to the new project model requirements.

## Migration Logic

- **Attributes normalized or copied:**
  - `acronym`: Normalized (converted to uppercase, spaces replaced with dashes, non-alphanumeric characters removed).
  - `name`: Copied as-is.
  - `homePage`: Copied as-is.
  - `description`: Copied as-is.
  - `created`: Copied as-is.
  - `updated`: Copied as-is.
  - `creator`: Copied as-is.

- **Attributes required in the new model but missing in old:**
  - `keywords`: Set to `[acronym]` (array with the normalized acronym because it's required in the new model).
  - `ontologyUsed`: If missing or empty, set to `["SWEET"]` (required in new model). Otherwise, ontology URLs are converted to acronyms.

- **Attributes with default or conditional values:**
  - `type`: Defaults to `"FundedProject"`. If your project JSON has a non-funded project, set `"type": "NonFundedProject"` in the JSON.
  - `grant_number`: Set to the value from JSON if present, otherwise `nil`.
  - `funder`: Set to the value from JSON if present, otherwise `nil`. If present, only the UUID part of the funder URI is used.
  - `source`: Set to the value from JSON if present, otherwise `nil`.

- **Attributes always set to `nil` (not required or not present in old model):**
  - `contact`
  - `organization`
  - `start_date`
  - `end_date`
  - `logo`

## Notes

- If you want to add `grant_number`, `funder`, or `source`, include them in your JSON input.
- For `acronym`, the script will always normalize it (uppercase, dashes, no spaces).
- For `type`, set `"type": "NonFundedProject"` in your JSON for non-funded projects; otherwise, it defaults to `"FundedProject"`.

**Field mapping summary:**

| Field         | Source/Logic                                                                 |
|---------------|------------------------------------------------------------------------------|
| acronym       | Normalized (uppercase, dashes, no spaces)                                    |
| type          | `"FundedProject"` by default, or `"NonFundedProject"` if set in JSON         |
| name          | Copied from old                                                              |
| homePage      | Copied from old                                                              |
| description   | Copied from old                                                              |
| ontologyUsed  | Acronyms from ontology URLs, or `["SWEET"]` if missing/empty                 |
| created       | Copied from old                                                              |
| updated       | Copied from old                                                              |
| keywords      | `[acronym]`                                                                  |
| contact       | `nil`                                                                        |
| organization  | `nil`                                                                        |
| grant_number  | From JSON if present, else `nil`                                             |
| start_date    | `nil`                                                                        |
| end_date      | `nil`                                                                        |
| funder        | UUID from funder URI if present, else `nil`                                  |
| logo          | `nil`                                                                        |
| source        | From JSON if present, else `nil`                                             |
| creator       | Copied from old                                                              |
