# optionchain

This repository includes a simple Azure Function project demonstrating a timer trigger. The `TimerTriggerFunction` runs every five minutes and logs the current UTC time. You can deploy or run it locally using the Azure Functions Core Tools.

## Project structure

- `TimerTriggerFunction/` – Directory containing the timer triggered function
  - `__init__.py` – Python function code
  - `function.json` – Function configuration with schedule
- `host.json` – Function app configuration

## Running locally

Install [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local) and execute:

```bash
func start
```

