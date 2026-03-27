import DailyChallengeDashboard from "discourse/plugins/discourse-daily-challenge/components/daily-challenge-dashboard";

export default <template>
  <div class="container">
    <DailyChallengeDashboard
      @dashboard={{@model}}
      @breadcrumbPath="/challenges/dashboard"
    />
  </div>
</template>
