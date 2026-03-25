import { schedule } from "@ember/runloop";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

const PLUGIN_ID = "discourse-daily-challenge";
const PLUGIN_BASE_PATH = "/admin/plugins/discourse-daily-challenge";
const STAFF_NAV_ITEM_CLASS = "dc-staff-nav-item";

const STAFF_NAV_LINKS = [
  {
    path: `${PLUGIN_BASE_PATH}/dashboard`,
    labelKey: "daily_challenge.admin.nav.dashboard",
  },
  {
    path: `${PLUGIN_BASE_PATH}/challenges`,
    labelKey: "daily_challenge.admin.nav.challenges",
  },
];

function removeStaffNav() {
  document
    .querySelectorAll(`li.${STAFF_NAV_ITEM_CLASS}`)
    .forEach((el) => el.remove());

  document.querySelectorAll("li[data-dc-hidden]").forEach((el) => {
    el.style.removeProperty("display");
    delete el.dataset.dcHidden;
  });
}

function injectStaffNav(activePath) {
  schedule("afterRender", () => {
    removeStaffNav();

    // HorizontalOverflowNav spreads ...attributes onto its <ul>, so
    // class="d-nav-submenu__tabs" (from DPageHeader) lands on the <ul>.
    const tabsList = document.querySelector("ul.d-nav-submenu__tabs");
    if (!tabsList) {
      return;
    }

    // Hide the Settings tab injected by Discourse core's AdminPluginNavManager.
    const settingsAnchor = tabsList.querySelector('li a[href$="/settings"]');
    if (settingsAnchor) {
      const settingsItem = settingsAnchor.closest("li");
      settingsItem.dataset.dcHidden = "true";
      settingsItem.style.display = "none";
    }

    // Inject Dashboard and Challenges as native-style <li><a> tab items so
    // they inherit nav-pills styles (padding, active underline) automatically.
    for (const link of STAFF_NAV_LINKS) {
      const li = document.createElement("li");
      li.className = `admin-plugin-config-page__top-nav-item ${STAFF_NAV_ITEM_CLASS}`;

      const a = document.createElement("a");
      a.href = link.path;
      if (link.path === activePath) {
        a.className = "active";
      }
      a.textContent = i18n(link.labelKey);

      li.appendChild(a);
      tabsList.appendChild(li);
    }
  });
}

export default {
  name: "daily-challenge-admin-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser?.staff) {
      return;
    }

    withPluginApi((api) => {
      if (currentUser.admin) {
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
      } else {
        api.addSidebarSection(
          (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
            return class extends BaseCustomSidebarSection {
              get name() {
                return "daily-challenges";
              }

              get title() {
                return i18n("daily_challenge.sidebar.title");
              }

              get text() {
                return i18n("daily_challenge.sidebar.title");
              }

              get links() {
                return [
                  new (class extends BaseCustomSidebarSectionLink {
                    get name() {
                      return "daily-challenges-dashboard";
                    }

                    get href() {
                      return `${PLUGIN_BASE_PATH}/dashboard`;
                    }

                    get title() {
                      return i18n("daily_challenge.admin.nav.dashboard");
                    }

                    get text() {
                      return i18n("daily_challenge.admin.nav.dashboard");
                    }

                    get prefixType() {
                      return "icon";
                    }

                    get prefixValue() {
                      return "chart-bar";
                    }
                  })(),
                  new (class extends BaseCustomSidebarSectionLink {
                    get name() {
                      return "daily-challenges-list";
                    }

                    get href() {
                      return `${PLUGIN_BASE_PATH}/challenges`;
                    }

                    get title() {
                      return i18n("daily_challenge.admin.nav.challenges");
                    }

                    get text() {
                      return i18n("daily_challenge.admin.nav.challenges");
                    }

                    get prefixType() {
                      return "icon";
                    }

                    get prefixValue() {
                      return "flag";
                    }
                  })(),
                ];
              }
            };
          }
        );

        api.onPageChange((url) => {
          const activeLink = STAFF_NAV_LINKS.find((l) =>
            url.startsWith(l.path)
          );

          if (activeLink) {
            injectStaffNav(activeLink.path);
          } else {
            removeStaffNav();
          }
        });
      }
    });
  },
};
