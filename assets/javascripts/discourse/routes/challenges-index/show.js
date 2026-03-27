import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ChallengesIndexShowRoute extends DiscourseRoute {
  async model(params) {
    const id = parseInt(params.id, 10);

    const [challengeResponse, checkInsResponse] = await Promise.all([
      ajax(`/challenges/challenges/${id}`),
      ajax(`/challenges/challenges/${id}/check_ins`),
    ]);

    return {
      ...challengeResponse.challenge,
      check_ins: checkInsResponse.check_ins,
    };
  }
}
