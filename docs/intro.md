# Why another system builder?

`rsdk` is yet another evolution of Radxa's system builder. The primary goal is to
move away from [`debos`](https://github.com/go-debos/debos) for following reasons:

1. (Previously) [Lack of ARM64 support](https://github.com/go-debos/debos/issues/363).
2. We use pagefile to workaround dkms build failure, which [requires KVM to be available](https://github.com/radxa-repo/rbuild/issues/16#issuecomment-1534176754).
3. Go templates leave much to be desired.
4. [Provided actions](https://pkg.go.dev/github.com/go-debos/debos/actions) are becoming limiting to achieve our desired result.

Beyond those, our system has grown into 100+ repositories, interconnected by various CI/CD workflows.
From an operational standpoint we also need a tool to centrally manage them, with the added bonus that
customers can use the very same tool to reproduce our setup for their own use.

Finally, we want to have a short answer to the commonly asked question "where can I download the SDK for X".
So far, our answer has always been a brief explanation of the system design, because of its complexity.
We want to have something that matches customer's expectation more closely, where there is only a single
entry to all related Radxa source code.

Thus, `rsdk` is born.
