import AdminChallengePostLeaderboard from "discourse/plugins/discourse-fitness-challenge/admin/components/admin-challenge-post-leaderboard";
import AdminCheckInManager from "discourse/plugins/discourse-fitness-challenge/admin/components/admin-check-in-manager";
import AdminFitnessChallengeForm from "discourse/plugins/discourse-fitness-challenge/admin/components/admin-fitness-challenge-form";

export default <template>
  <div class="fitness-challenge-admin admin-detail">
    <AdminFitnessChallengeForm @challenge={{@model}} />
    <AdminChallengePostLeaderboard @challenge={{@model}} />
    <AdminCheckInManager @challenge={{@model}} />
  </div>
</template>
