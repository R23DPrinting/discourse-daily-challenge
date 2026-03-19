import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-daily-challenge";

export default {
  name: "daily-challenge-admin-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser?.admin) {
      return;
    }

    withPluginApi((api) => {
      api.addAdminPluginConfigurationNav(PLUGIN_ID, [
        {
          label: "daily_challenge.admin.nav.dashboard",
          route: "adminPlugins.show.discourse-daily-challenge-dashboard",
        },
        {
          label: "daily_challenge.admin.nav.challenges",
          route: "adminPlugins.show.discourse-daily-challenge-challenges",
        },
      ]);
    });
  },
};
