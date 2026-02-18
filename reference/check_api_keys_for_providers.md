# Check API Keys for Providers

Internal function to filter providers to only those with API keys
available. Warns about skipped providers but allows cascade to continue.

## Usage

``` r
check_api_keys_for_providers(providers)
```

## Arguments

- providers:

  Character vector of provider names

## Value

Character vector of providers that have API keys
