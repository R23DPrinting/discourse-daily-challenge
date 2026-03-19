import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminDailyChallengeChallengesShowRoute extends DiscourseRoute {
  async model(params) {
    const id = parseInt(params.id, 10);

    const [challengeResponse, checkInsResponse] = await Promise.all([
      ajax(`/admin/plugins/discourse-daily-challenge/challenges/${id}`),
      ajax(
        `/admin/plugins/discourse-daily-challenge/challenges/${id}/check_ins`
      ),
    ]);

    return {
      ...challengeResponse.challenge,
      check_ins: checkInsResponse.check_ins,
    };
  }
}
