export default {
  resource: "admin.adminPlugins.show",
  path: "/plugins",
  map() {
    this.route(
      "discourse-fitness-challenge-challenges",
      { path: "challenges" },
      function () {
        this.route("show", { path: "/:id" });
      }
    );
    this.route("discourse-fitness-challenge-dashboard", { path: "dashboard" });
  },
};
