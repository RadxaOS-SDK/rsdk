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

4. Decide whether to configure package mirrors (optional).  
   Before starting the actual build, `rsdk-tui` will ask whether you want to
   configure alternative package mirrors (Radxa radxa-deb mirror and
   Debian/Ubuntu mirror). If you select **No**, default mirrors will be used
   and the build will proceed directly to confirmation. If you select **Yes**,
   TUI will guide you to choose mirrors (including selecting the default
   entries). If you cancel during mirror selection, the wizard will return to
   this question so you can decide again:

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│ Do you want to configure alternative      │
│ package mirror?                           │
│                                           │
│          <Yes>             <No>           │
│                                           │
└───────────────────────────────────────────┘
```

If you choose **Yes**, you will be guided to select the Radxa APT mirror:

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│ Select Radxa APT mirror (radxa-deb):      │
│                                           │
│  (*) Use official Radxa repository        │
│  ( ) mirrors.aghost.cn (radxa-deb)        │
│  ( ) mirrors.lzu.edu.cn (radxa-deb)       │
│  ( ) mirrors.hust.edu.cn (radxa-deb)      │
│  ( ) mirrors.sdu.edu.cn (radxa-deb)       │
│  ( ) mirror.nju.edu.cn (radxa-deb)        │
│  ( ) mirror.nyist.edu.cn (radxa-deb)      │
│                                           │
│         <Ok>             <Cancel>         │
│                                           │
└───────────────────────────────────────────┘
```

Then select an optional Debian/Ubuntu mirror (or keep the default):

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│ Select Debian/Ubuntu mirror (optional):   │
│                                           │
│  (*) Use default Debian/Ubuntu mirror     │
│  ( ) mirrors.ustc.edu.cn                  │
│  ( ) mirrors.tuna.tsinghua.edu.cn         │
│  ( ) mirrors.lzu.edu.cn                   │
│  ( ) mirrors.hust.edu.cn                  │
│  ( ) mirrors.sdu.edu.cn                   │
│  ( ) mirror.nju.edu.cn                    │
│  ( ) mirror.nyist.edu.cn                  │
│                                           │
│         <Ok>             <Cancel>         │
│                                           │
└───────────────────────────────────────────┘
```

5. Confirm and start the build.  
   After mirrors (if any) are configured, `rsdk-tui` will show a summary of the
   selected product and mirrors. This corresponds to the final CLI command that
   will be executed (equivalent to passing `-M`/`-m` to `rsdk build` when
   mirrors are set). Review the summary carefully and choose **Yes** to start
   the build, or **No** to go back:

```bash
┌─────────────────┤ RSDK ├──────────────────┐
│                                           │
│ Are you sure to build with:               │
│                                           │
│ Product: rock-5b-6_1                      │
│ Radxa mirror: https://mirrors.example/r…  │
│ Debian/Ubuntu mirror: https://mirrors…    │
│                                           │
│                                           │
│          <Yes>             <No>           │
│                                           │
└───────────────────────────────────────────┘
```

Advanced build should use [`rsdk-build`](../cmd/rsdk-build.md) command instead.
