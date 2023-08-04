import { getInfo, getInfoFromPullRequest } from "@changesets/get-github-info";

import type { ChangelogFunctions } from "@changesets/types";
// @ts-ignore
import { config } from "dotenv";

config();

function validate(options: Record<string, any> | null) {
  if (!options || !options.repo) {
    throw new Error(
      'Please provide a repo to this changelog generator like this:\n"changelog": ["@svitejs/changesets-changelog-github-compact", { "repo": "org/repo" }]'
    );
  }
}

const changelogFunctions: ChangelogFunctions = {
  getDependencyReleaseLine: async (
    changesets,
    dependenciesUpdated,
    options
  ) => {
    validate(options);
    if (dependenciesUpdated.length === 0) return "";

    const changesetLink = `- Updated dependencies [${(
      await Promise.all(
        changesets.map(async (cs) => {
          if (cs.commit) {
            const { links } = await getInfo({
              repo: options.repo,
              commit: cs.commit,
            });
            return links.commit;
          }
        })
      )
    )
      .filter((_) => _)
      .join(", ")}]:`;

    const updatedDepenenciesList = dependenciesUpdated.map(
      (dependency) => `  - ${dependency.name}@${dependency.newVersion}`
    );

    return [changesetLink, ...updatedDepenenciesList].join("\n");
  },
  getReleaseLine: async (changeset, type, options) => {
    validate(options);
    const repo = options!.repo;
    let prFromSummary: number | undefined;
    let commitFromSummary: string | undefined;

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

    const linkifyIssueHints = (line: string) =>
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

    await (async () => {
      if (prFromSummary !== undefined) {
        await getInfoFromPullRequest({
          repo,
          pull: prFromSummary,
        });
        if (commitFromSummary) {
          await getInfo({
            repo,
            commit: commitFromSummary,
          });
        }
      }
      const commitToFetchFrom = commitFromSummary || changeset.commit;
      if (commitToFetchFrom) {
        await getInfo({
          repo,
          commit: commitToFetchFrom,
        });
      }
    })();

    return `\n- ${firstLine}\n${futureLines.map((l) => `  ${l}`).join("\n")}`;
  },
};

export default changelogFunctions;
