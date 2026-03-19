import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AdminFitnessChallengeChallengesIndexController extends Controller {
  @service dialog;
  @service toasts;
  @service router;

  creatingNew = false;

  @action
  resetCreatingNew() {
    this.set("creatingNew", false);
  }

  @action
  destroyChallenge(challenge) {
    this.dialog.deleteConfirm({
      message: i18n("fitness_challenge.admin.challenges.confirm_delete"),
      didConfirm: () => {
        return ajax(
          `/admin/plugins/discourse-fitness-challenge/challenges/${challenge.id}`,
          { type: "DELETE" }
        )
          .then(() => {
            this.toasts.success({
              duration: "short",
              data: {
                message: i18n("fitness_challenge.admin.challenges.deleted"),
              },
            });
            this.router.refresh();
          })
          .catch(popupAjaxError);
      },
    });
  }
}
