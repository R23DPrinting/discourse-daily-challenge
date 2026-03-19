import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import AdminChallengePostLeaderboard from "discourse/plugins/discourse-fitness-challenge/admin/components/admin-challenge-post-leaderboard";
import AdminCheckInManager from "discourse/plugins/discourse-fitness-challenge/admin/components/admin-check-in-manager";
import AdminFitnessChallengeForm from "discourse/plugins/discourse-fitness-challenge/admin/components/admin-fitness-challenge-form";

export default class ShowFitnessChallenge extends Component {
  @service router;

  @action
  refreshModel() {
    this.router.refresh();
  }

  <template>
    <div class="fitness-challenge-admin admin-detail">
      <AdminFitnessChallengeForm
        @challenge={{@model}}
        @onSave={{this.refreshModel}}
      />
      <AdminChallengePostLeaderboard @challenge={{@model}} />
      <AdminCheckInManager @challenge={{@model}} />
    </div>
  </template>
}
