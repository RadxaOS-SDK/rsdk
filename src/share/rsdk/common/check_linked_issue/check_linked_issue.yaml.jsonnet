function() std.manifestYamlDoc(
    {
        name: "Check linked issues",
        on: {
            pull_request_target: {
                types: [
                    "opened",
                    "reopened",
                ],
            },
        },
        permissions: {},
        jobs: {
            check_pull_requests: {
                "runs-on": "ubuntu-latest",
                name: "Check linked issues",
                permissions: {
                    issues: "write",
                    "pull-requests": "write",
                },
                steps: [
                    {
                        name: "Check linked issues",
                        uses: "nearform-actions/github-action-check-linked-issues@v1",
                    },
                ],
            },
        }
    },
    quote_keys=false,
)
