function(
    target,
) std.manifestJson(
  {
    "*": {
      Releases: [
        target,
      ],
    },
  }
)