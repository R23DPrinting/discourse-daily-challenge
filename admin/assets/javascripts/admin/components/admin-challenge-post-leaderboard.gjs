import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AdminChallengePostLeaderboard extends Component {
  @service toasts;

  @tracked loading = false;

  @action
  async postLeaderboard() {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      await ajax(
        `/admin/plugins/discourse-daily-challenge/challenges/${this.args.challenge.id}/post_leaderboard`,
        { type: "POST" }
      );
      this.toasts.success({
        duration: "short",
        data: {
          message: i18n("daily_challenge.admin.challenges.leaderboard_posted"),
        },
      });
    } catch (err) {
      popupAjaxError(err);
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="daily-challenge-admin__leaderboard-actions">
      <DButton
        @label="daily_challenge.admin.challenges.post_leaderboard"
        @icon="dumbbell"
        @action={{this.postLeaderboard}}
        @disabled={{this.loading}}
        class="btn-default"
      />
    </div>
  </template>
}
