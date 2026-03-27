import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ChallengesIndexIndexRoute extends DiscourseRoute {
  async model() {
    return ajax("/challenges/challenges");
  }
}
