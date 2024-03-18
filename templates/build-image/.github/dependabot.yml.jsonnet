function(
    product,
    build_org
) std.manifestYamlDoc(
    {
        version: 2,
        updates: [{
            "package-ecosystem": "github-actions",
            directory: "/",
            schedule: {
                interval: "daily"
            }
        }]
    },
    quote_keys=false
)
