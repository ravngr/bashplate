# bashplate
Some useful bash code for general projects.

## Use
To use the library, just include `bashplate.sh` in your script.

```bash
# Source bashplate
. "${BASHPLATE_PATH}/bashplate.sh"
```

## Useful functions
### `print_style <message> [<code>, <code>, ...]`
Prints message with provided escape codes. Resets terminal output at the end to clear codes. *Should* handle printing in non-interactive terminals.

### `print_[debug|info|success|warn|error|critical] <message>`
Prints with nice colours and debugging information like source file and line number. Behaviour is tweaked via environment variables:
- `TERM_DEBUG=<anything>` to print `print_debug` messages that are suppressed by default.
- `TERM_PREFIX_OFFSET=n` set to non-zero value to offset caller lookup by `n`, defaults to 0. Useful for showing callers to functions instead of intermediates.
- `TERM_PREFIX=<anything>` prefixed to printed messages in all functions. Useful to provide a logger name or context.
