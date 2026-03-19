import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseDailyChallengeDashboardRoute extends DiscourseRoute {
  async model() {
    return ajax("/admin/plugins/discourse-daily-challenge/dashboard");
  }
}
