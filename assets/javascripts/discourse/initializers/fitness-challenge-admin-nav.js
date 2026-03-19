import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-fitness-challenge";

export default {
  name: "fitness-challenge-admin-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser?.admin) {
      return;
    }

    withPluginApi((api) => {
      api.addAdminPluginConfigurationNav(PLUGIN_ID, [
        {
          label: "fitness_challenge.admin.nav.dashboard",
          route: "adminPlugins.show.discourse-fitness-challenge-dashboard",
        },
        {
          label: "fitness_challenge.admin.nav.challenges",
          route: "adminPlugins.show.discourse-fitness-challenge-challenges",
        },
      ]);
    });
  },
};
