import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DiscourseFitnessChallengeDashboardRoute extends DiscourseRoute {
  async model() {
    return ajax("/admin/plugins/discourse-fitness-challenge/dashboard");
  }
}
