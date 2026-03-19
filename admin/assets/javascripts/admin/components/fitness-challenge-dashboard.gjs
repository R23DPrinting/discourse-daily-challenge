import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import DPageSubheader from "discourse/components/d-page-subheader";
import DStatTiles from "discourse/components/d-stat-tiles";
import avatar from "discourse/helpers/avatar";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import { eq, gt } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

// Inline progress bar component — uses a class getter so htmlSafe lives in JS.
class ProgressBar extends Component {
  get barStyle() {
    const pct = Math.min(100, Math.max(0, this.args.pct ?? 0));
    return htmlSafe(`width: ${pct}%`);
  }

  <template>
    <div class="fcd-progress">
      <div class="fcd-progress__bar" style={{this.barStyle}}></div>
    </div>
    <span class="fcd-progress__label">{{@pct}}%</span>
  </template>
}

// Renders one active challenge: stats tiles + expandable leaderboard rows.
class FitnessChallengeSection extends Component {
  @tracked selectedUserId = null;

  get challenge() {
    return this.args.data.challenge;
  }

  get leaderboard() {
    return this.args.data.leaderboard ?? [];
  }

  get stats() {
    return this.args.data.stats ?? {};
  }

  get selectedUser() {
    if (this.selectedUserId === null) {
      return null;
    }
    return this.leaderboard.find((e) => e.user_id === this.selectedUserId) ?? null;
  }

  // Returns an array of weeks, each week an array of 7 day objects.
  // Used to render the GitHub-style contribution grid for the selected user.
  get checkInGrid() {
    const user = this.selectedUser;
    const challenge = this.challenge;
    if (!user || !challenge) {
      return [];
    }

    const checkedDates = new Set(user.check_in_dates);
    const challengeStart = new Date(challenge.start_date + "T00:00:00");
    const challengeEnd = new Date(challenge.end_date + "T00:00:00");
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const gridEnd = challengeEnd < today ? challengeEnd : today;

    // Align grid start to the Monday of the challenge's start week (ISO week: Mon=0)
    const gridStart = new Date(challengeStart);
    const isoDay = (gridStart.getDay() + 6) % 7; // Mon=0, Sun=6
    gridStart.setDate(gridStart.getDate() - isoDay);

    const days = [];
    const cursor = new Date(gridStart);

    while (cursor <= gridEnd) {
      const iso = cursor.toISOString().split("T")[0];
      const inChallenge = cursor >= challengeStart && cursor <= gridEnd;
      days.push({
        date: iso,
        inChallenge,
        checkedIn: inChallenge && checkedDates.has(iso),
        label: cursor.toLocaleDateString(undefined, {
          month: "short",
          day: "numeric",
        }),
      });
      cursor.setDate(cursor.getDate() + 1);
    }

    // Pad to a full week so the grid is rectangular
    while (days.length % 7 !== 0) {
      const iso = cursor.toISOString().split("T")[0];
      days.push({ date: iso, inChallenge: false, checkedIn: false, label: "" });
      cursor.setDate(cursor.getDate() + 1);
    }

    const weeks = [];
    for (let i = 0; i < days.length; i += 7) {
      weeks.push(days.slice(i, i + 7));
    }
    return weeks;
  }

  @action
  toggleUser(userId) {
    this.selectedUserId = this.selectedUserId === userId ? null : userId;
  }

  <template>
    <div class="fcd-section">
      <div class="fcd-section__header">
        <span class="fcd-challenge-meta__hashtag">#{{this.challenge.hashtag}}</span>
        {{#if this.challenge.topic_title}}
          <a
            href={{this.challenge.topic_url}}
            class="fcd-challenge-meta__topic"
            target="_blank"
            rel="noopener noreferrer"
          >{{this.challenge.topic_title}}</a>
        {{/if}}
        <span class="fcd-challenge-meta__progress">
          {{i18n
            "fitness_challenge.dashboard.day_progress"
            elapsed=this.challenge.elapsed_days
            total=this.challenge.total_days
          }}
        </span>
      </div>

      <DStatTiles class="fcd-stats" as |tiles|>
        <tiles.Tile
          @label={{i18n "fitness_challenge.dashboard.stats.participants"}}
          @value={{this.stats.total_participants}}
        />
        <tiles.Tile
          @label={{i18n "fitness_challenge.dashboard.stats.avg_check_ins"}}
          @value={{this.stats.avg_check_ins}}
        />
        <tiles.Tile
          @label={{i18n "fitness_challenge.dashboard.stats.progress"}}
          @value={{this.stats.progress_pct}}
        />
      </DStatTiles>

      {{#if (gt this.leaderboard.length 0)}}
        <div class="fcd-leaderboard">
          <table class="fcd-leaderboard__table">
            <thead>
              <tr>
                <th class="fcd-leaderboard__th--rank">
                  {{i18n "fitness_challenge.dashboard.col.rank"}}
                </th>
                <th class="fcd-leaderboard__th--user">
                  {{i18n "fitness_challenge.dashboard.col.participant"}}
                </th>
                <th class="fcd-leaderboard__th--checkins">
                  {{i18n "fitness_challenge.dashboard.col.check_ins"}}
                </th>
                <th class="fcd-leaderboard__th--streak">
                  {{i18n "fitness_challenge.dashboard.col.streak"}}
                </th>
                <th class="fcd-leaderboard__th--completion">
                  {{i18n "fitness_challenge.dashboard.col.completion"}}
                </th>
              </tr>
            </thead>
            <tbody>
              {{#each this.leaderboard as |entry|}}
                <tr
                  class={{concatClass
                    "fcd-leaderboard__row"
                    (if (eq this.selectedUserId entry.user_id) "is-expanded")
                  }}
                  role="button"
                  tabindex="0"
                  {{on "click" (fn this.toggleUser entry.user_id)}}
                >
                  <td class="fcd-leaderboard__rank">
                    {{#if (eq entry.rank 1)}}
                      <span class="fcd-rank fcd-rank--gold">1</span>
                    {{else if (eq entry.rank 2)}}
                      <span class="fcd-rank fcd-rank--silver">2</span>
                    {{else if (eq entry.rank 3)}}
                      <span class="fcd-rank fcd-rank--bronze">3</span>
                    {{else}}
                      <span class="fcd-rank">{{entry.rank}}</span>
                    {{/if}}
                  </td>
                  <td class="fcd-leaderboard__user">
                    {{avatar entry imageSize="tiny"}}
                    <span class="fcd-leaderboard__username">{{entry.username}}</span>
                  </td>
                  <td class="fcd-leaderboard__checkins">
                    {{entry.total_check_ins}}
                  </td>
                  <td class="fcd-leaderboard__streak">
                    {{#if entry.streak}}
                      {{icon "fire" class="fcd-streak-icon"}}
                      {{entry.streak}}
                    {{else}}
                      <span class="fcd-streak-none">—</span>
                    {{/if}}
                  </td>
                  <td class="fcd-leaderboard__completion">
                    <ProgressBar @pct={{entry.completion_pct}} />
                  </td>
                </tr>

                {{#if (eq this.selectedUserId entry.user_id)}}
                  <tr class="fcd-history-row">
                    <td colspan="5">
                      <div class="fcd-history">
                        <p class="fcd-history__summary">
                          {{i18n
                            "fitness_challenge.dashboard.history.summary"
                            username=entry.username
                            count=entry.total_check_ins
                            streak=entry.streak
                          }}
                        </p>
                        <div class="fcd-history__grid-wrap">
                          <div class="fcd-history__grid">
                            {{#each this.checkInGrid as |week|}}
                              <div class="fcd-history__week">
                                {{#each week as |day|}}
                                  <div
                                    class={{concatClass
                                      "fcd-history__day"
                                      (if day.checkedIn "is-checked")
                                      (unless day.inChallenge "is-outside")
                                    }}
                                    title={{day.label}}
                                  ></div>
                                {{/each}}
                              </div>
                            {{/each}}
                          </div>
                        </div>
                      </div>
                    </td>
                  </tr>
                {{/if}}
              {{/each}}
            </tbody>
          </table>
        </div>
      {{else}}
        <p class="admin-plugin-config-area__empty-list">
          {{i18n "fitness_challenge.dashboard.no_participants"}}
        </p>
      {{/if}}
    </div>
  </template>
}

export default class FitnessChallengeDashboard extends Component {
  get activeChallenges() {
    return this.args.dashboard?.active_challenges ?? [];
  }

  get archivedChallenges() {
    return this.args.dashboard?.archived_challenges ?? [];
  }

  get archivedHasMore() {
    return this.args.dashboard?.archived_has_more ?? false;
  }

  <template>
    <DBreadcrumbsItem
      @path="/admin/plugins/discourse-fitness-challenge/dashboard"
      @label={{i18n "fitness_challenge.dashboard.title"}}
    />

    <div class="fitness-challenge-dashboard admin-detail">
      <DPageSubheader @titleLabel={{i18n "fitness_challenge.dashboard.title"}} />

      {{#if (gt this.activeChallenges.length 0)}}
        {{#each this.activeChallenges as |data|}}
          <FitnessChallengeSection @data={{data}} />
        {{/each}}
      {{else}}
        <p class="admin-plugin-config-area__empty-list">
          {{i18n "fitness_challenge.dashboard.no_active_challenge"}}
        </p>
      {{/if}}

      {{#if (gt this.archivedChallenges.length 0)}}
        <div class="fcd-archived">
          <h3 class="fcd-archived__title">
            {{i18n "fitness_challenge.dashboard.archived.title"}}
          </h3>
          {{#each this.archivedChallenges as |archived|}}
            <details class="fcd-archived__item">
              <summary class="fcd-archived__summary">
                <span class="fcd-archived__summary-hashtag">
                  #{{archived.hashtag}}
                </span>
                {{#if archived.topic_title}}
                  <span class="fcd-archived__summary-name">
                    {{archived.topic_title}}
                  </span>
                {{/if}}
                <span class="fcd-archived__summary-dates">
                  {{i18n
                    "fitness_challenge.dashboard.archived.dates"
                    start=archived.start_date
                    end=archived.end_date
                  }}
                </span>
              </summary>

              <div class="fcd-archived__body">
                <ul class="fcd-archived__stats">
                  <li>
                    {{i18n
                      "fitness_challenge.dashboard.archived.participants_count"
                      count=archived.total_participants
                    }}
                  </li>
                  {{#if archived.winner}}
                    <li>
                      {{avatar archived.winner imageSize="tiny"}}
                      {{i18n
                        "fitness_challenge.dashboard.archived.winner"
                        username=archived.winner.username
                        count=archived.winner.total_check_ins
                      }}
                    </li>
                  {{else}}
                    <li>{{i18n "fitness_challenge.dashboard.archived.no_participants"}}</li>
                  {{/if}}
                  <li>
                    {{i18n
                      "fitness_challenge.dashboard.archived.completion_rate"
                      rate=archived.completion_rate
                    }}
                  </li>
                </ul>
                {{#if archived.topic_url}}
                  <a
                    href={{archived.topic_url}}
                    class="fcd-archived__topic-link"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    {{icon "arrow-up-right-from-square"}}
                    {{i18n "fitness_challenge.dashboard.archived.view_topic"}}
                  </a>
                {{/if}}
              </div>
            </details>
          {{/each}}
          {{#if this.archivedHasMore}}
            <p class="fcd-archived__overflow-notice">
              {{i18n "fitness_challenge.dashboard.archived.overflow"}}
            </p>
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
}
