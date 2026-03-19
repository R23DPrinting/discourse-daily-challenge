import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminFitnessChallengeChallengesShowRoute extends DiscourseRoute {
  async model(params) {
    const id = parseInt(params.id, 10);

    const [challengeResponse, checkInsResponse] = await Promise.all([
      ajax(`/admin/plugins/discourse-fitness-challenge/challenges/${id}`),
      ajax(
        `/admin/plugins/discourse-fitness-challenge/challenges/${id}/check_ins`
      ),
    ]);

    return {
      ...challengeResponse.challenge,
      check_ins: checkInsResponse.check_ins,
    };
  }
}
