# Commit Message Rules

Every commit in this repository must follow the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification. This applies to every commit, including documentation-only changes.

## Message structure

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

1. The first line is the **header**. It starts with a type, an optional scope in parentheses, an optional `!`, then a colon and one space, then a short description.
2. If there is a body, it starts after **one blank line** below the header. It can have several paragraphs.
3. If there are footers, they start after **one blank line** below the body (or the header, if there is no body).

## Types

| Type | Use it for | Version effect |
| --- | --- | --- |
| `feat` | A new feature for users | MINOR |
| `fix` | A bug fix | PATCH |
| `docs` | Documentation only (README, this file, comments) | none |
| `style` | Formatting, whitespace, naming; no change in behaviour | none |
| `refactor` | Code change that neither fixes a bug nor adds a feature | none |
| `perf` | Code change that improves performance | none |
| `test` | Adding or correcting unit tests or UI tests | none |
| `build` | Build system or dependencies (Xcode project, Swift Package Manager) | none |
| `ci` | CI configuration (GitHub Actions workflows) | none |
| `chore` | Other maintenance that does not touch source or tests | none |
| `revert` | Reverts an earlier commit | depends |

`feat` and `fix` are defined by the specification. The other types follow the widely used `@commitlint/config-conventional` list. Only the types in this table are accepted here. Write types in lowercase.

## Scopes

A scope is an optional noun in parentheses that names the part of the Todo app the commit touches. Use one of these:

| Scope | Area |
| --- | --- |
| `auth` | Sign up, sign in, sign out, password reset, `AuthService`, `AuthViewModel`, auth screens |
| `tasks` | Task create, read, update, delete, `TaskService`, `TaskViewModel`, task screens |
| `model` | Data models such as `TodoTask` and their Firestore mapping |
| `search` | Search bar, filters (All / Active / Completed), sorting |
| `ui` | Shared components, theming, dark mode, Dynamic Type, accessibility |
| `firestore` | Firestore queries, indexes, offline persistence |
| `rules` | Firestore security rules |
| `firebase` | Firebase project configuration and SDK setup |
| `deps` | Dependency updates |
| `repo` | Repository setup, `.gitignore`, templates, this file |

Scopes are lowercase letters, digits and hyphens. Leave the scope out when a change spans many areas. If you need a new scope, add it to this table in the same commit.

## Description

- Use the imperative mood: "add", "fix", "remove", not "added" or "fixes".
- Start with a lowercase letter and do not end with a period.
- Keep the whole header at **72 characters or fewer**.
- Say what the commit does, not how you got there.

## Body

- Explain **what** changed and **why**, not how.
- Wrap lines at about 72 characters.
- Separate paragraphs with a blank line.

## Breaking changes

A breaking change is anything that forces other code, data or users to change: a renamed Firestore field, a moved collection path, a changed model property, a raised minimum iOS version. It triggers a MAJOR version bump and can be used with any type.

Mark it in one or both of these ways:

1. Add `!` right before the colon: `feat(model)!: rename isCompleted to done`.
2. Add a footer that starts with `BREAKING CHANGE:` (uppercase) and explains the change and what others must do.

```
feat(firestore)!: move tasks to a top-level collection

BREAKING CHANGE: tasks now live in /tasks with a userId field instead
of /users/{uid}/tasks. Existing documents must be migrated and the
security rules must be republished before this build is released.
```

`BREAKING-CHANGE:` is accepted as a synonym in footers.

## Footers

Footers use the Git trailer format: a token, then `: ` or ` #`, then a value. Tokens use hyphens instead of spaces, except `BREAKING CHANGE`.

```
Refs: #12
Closes: #34
Reviewed-by: Rahim
```

Reference GitHub issues in footers whenever a commit relates to one.

## One change per commit

If a change fits more than one type, split it into separate commits. For example, a new feature and an unrelated bug fix go in two commits.

## Never commit secrets or local files

- Do not commit `GoogleService-Info.plist` if the repository is public or shared outside your team. Add it to `.gitignore` and share it privately.
- Do not commit `xcuserdata/`, `DerivedData/` or `.DS_Store`.

## Examples

```
feat(tasks): add swipe to delete on task rows
```

```
fix(auth): show friendly message for invalid credentials
```

```
feat(search): filter tasks by active and completed

Adds a segmented control above the list. The filter is applied in
the view model, so the Firestore listener keeps receiving every
task and the list updates instantly when a task changes.

Refs: #18
```

```
docs(repo): add commit message rules
```

```
test(tasks): cover empty title validation in TaskViewModel
```

```
refactor(auth): extract input validation into AuthValidator
```

```
fix(rules): block changing userId on task update
```

```
build(deps): bump firebase-ios-sdk to latest minor version
```

```
revert: let tasks be saved without a title

Refs: 676104e
```

## Messages that are rejected

| Message | Problem |
| --- | --- |
| `Added swipe to delete` | No type |
| `feature(tasks): add swipe to delete` | `feature` is not an accepted type |
| `feat(Tasks): add swipe to delete` | Scope must be lowercase |
| `feat(tasks):add swipe to delete` | Missing space after the colon |
| `feat(tasks): ` | Empty description |
| `fix: update stuff` followed directly by body text | Body must start after a blank line |
| `fix(auth): Fixed the login bug.` | Not imperative, starts with a capital, ends with a period |

## Exceptions

These automatically generated messages are exempt:

- Merge commits created by Git or GitHub (`Merge branch ...`, `Merge pull request ...`).
- `fixup!` and `squash!` commits made by `git commit --fixup`, which must be squashed before pushing.

## Fixing a bad message

- **Last commit, not pushed yet:** `git commit --amend`
- **Older commits, not pushed yet:** `git rebase -i HEAD~N`, then mark the commits as `reword`.
- **Already pushed to `main`:** do not rewrite shared history. Tell the team, and follow the rules from the next commit on.
