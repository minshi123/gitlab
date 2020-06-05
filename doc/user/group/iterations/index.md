---
type: reference
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Iterations **(STARTER)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/214713) in [GitLab Starter](https://about.gitlab.com/pricing/) 13.1.

Iterations are a way to track issues over a period of time. This allows teams
to track velocity and volatility metrics. Iterations can be used with [milestones](../../project/milestones/index.md)
for tracking over different time periods. For example:

- Milestones for Program Increments, which span 8-12 weeks
- Iterations for Sprints, which span 2 weeks

Iterations are similar to milestones, with a few differences:

- Iterations are only available to groups
- A group can only have one active iteration at a time
- Iterations require both a start and an end date
- Iteration date ranges can not overlap

## View the iterations list

To view the iterations list, in a group, go to **{issues}** **Issues > Iterations**.
From there you can create a new iteration or click an iteration to get a more detailed view.

## Create an iteration

NOTE: **Note:**
A permission level of [Developer or higher](../../permissions.md) is required to create iterations.

To create an iteration:

1. In a group, go to **{issues}** **Issues > Iterations**.
1. Click **New iteration**.
1. Enter the title, a description (optional), a start date, and a due date.
1. Click **Create iteration**. The iteration details page opens.

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
