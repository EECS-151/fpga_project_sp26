/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <sys/printk.h>

#include <shell/shell.h>

extern int coremark_main(int argc, char *argv[]);

static int cmd_run_coremark(const struct shell *shell, size_t argc, char **argv)
{
    shell_print(shell, "Starting CoreMark");
    return coremark_main(argc, argv);
}

SHELL_CMD_REGISTER(coremark, NULL, "Run CoreMark benchmark", cmd_run_coremark);

void main(void)
{
	printk("Hello World! %s\n", CONFIG_BOARD);
}
