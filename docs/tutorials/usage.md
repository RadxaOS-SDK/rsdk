# Basic usage

`rsdk` comes with `bash-completion` to assist its CLI usage.

After typing `rsdk` into your terminal, if there is no subcommand suggestion after you press Tab key twice, you should run `rsdk shell` to enter the development environment.

From there, you can use autocompletion to query the supported command list.

Running a command with `--help` argument will display its help text.

## Use TUI to run guided tasks

`rsdk` command is the common CLI entry point.

When it is run without any argument, `rsdk-tui` will be run instead.

1. Start TUI Wizard by running `rsdk` in the terminal.

2. Select the task you want to run.  
   You can use arrow key to navigate, use Enter key to select, and use Escape key to leave current window.  
   In this example, we will choose `Build system image`:

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│ Please select a task:                     │
│                                           │
│            Build system image             │
│            =========                      │
│            About                          │
│                                           │
│         <Ok>             <Cancel>         │
│                                           │
└───────────────────────────────────────────┘
```

3. Select the product you want to build.  
   You can use the space bar to select the product, and the chosen product will have asterisk symbol placed in the parentheses.   
   **Enter key does not select the product when used alone!**  
   In this example, we will choose `rock-5b-6_1`:

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│ Please select a product:                  │
│                                           │
│  ( ) radxa-e25                        ▒   │
│  (*) rock-5b-6_1                      ▒   │
│  ( ) rock-5b                          ▒   │
│                                           │
│         <Ok>             <Cancel>         │
│                                           │
└───────────────────────────────────────────┘
```

4. Select `Yes` to start the build process.  
   `rsdk-tui` will then run the associated CLI commands to complete the task:

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│                                           │
│ Are you sure to build for 'rock-5b-6_1'?  │
│                                           │
│                                           │
│          <Yes>             <No>           │
│                                           │
└───────────────────────────────────────────┘
```

Advanced build should use [`rsdk-build`](../cmd/rsdk-build.md) command instead.