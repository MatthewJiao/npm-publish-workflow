const { ChangelogFunctions } = require("@changesets/types");

function validate(options) {
  if (!options || !options.repo) {
    throw new Error(
      'Please provide a repo to this changelog generator like this:\n"changelog": ["@svitejs/changesets-changelog-github-compact", { "repo": "org/repo" }]'
    );
  }
}

const changelogFunctions = {
  getDependencyReleaseLine: async (
    changesets,
    dependenciesUpdated,
    options
  ) => {
    validate(options);
    if (dependenciesUpdated.length === 0) return "";

    const updatedDepenenciesList = dependenciesUpdated.map(
      (dependency) => `  - ${dependency.name}@${dependency.newVersion}`
    );

    return [...updatedDepenenciesList].join("\n");
  },
  getReleaseLine: async (changeset, type, options) => {
    validate(options);
    const repo = options.repo;
    let prFromSummary;
    let commitFromSummary;

    const replacedChangelog = changeset.summary
      .replace(/^\s*(?:pr|pull|pull\s+request):\s*#?(\d+)/im, (_, pr) => {
        const num = Number(pr);
        if (!isNaN(num)) prFromSummary = num;
        return "";
      })
      .replace(/^\s*commit:\s*([^\s]+)/im, (_, commit) => {
        commitFromSummary = commit;
        return "";
      })
      .replace(/^\s*(?:author|user):\s*@?([^\s]+)/gim, "")
      .trim();

    const linkifyIssueHints = (line) =>
      line.replace(
        /(?<=\( ?(?:fix|fixes|see) )(#\d+)(?= ?\))/g,
        (issueHash) => {
          return `[${issueHash}](https://github.com/${repo}/issues/${issueHash.substring(
            1
          )})`;
        }
      );
    const [firstLine, ...futureLines] = replacedChangelog
      .split("\n")
      .map((l) => linkifyIssueHints(l.trimRight()));

    return `\n- ${firstLine}\n${futureLines.map((l) => `  ${l}`).join("\n")}`;
  },
};

module.exports = changelogFunctions;
