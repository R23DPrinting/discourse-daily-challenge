import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminFitnessChallengeChallengesRoute extends DiscourseRoute {
  async model() {
    return ajax("/admin/plugins/discourse-fitness-challenge/challenges");
  }
}
