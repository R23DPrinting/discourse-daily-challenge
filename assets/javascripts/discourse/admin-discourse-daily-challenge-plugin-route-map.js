export default {
  resource: "admin.adminPlugins.show",
  path: "/plugins",
  map() {
    this.route(
      "discourse-daily-challenge-challenges",
      { path: "challenges" },
      function () {
        this.route("show", { path: "/:id" });
      }
    );
    this.route("discourse-daily-challenge-dashboard", { path: "dashboard" });
  },
};
