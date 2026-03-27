export default function () {
  this.route("challenges-dashboard", { path: "/challenges/dashboard" });
  this.route("challenges-index", { path: "/challenges/challenges" }, function () {
    this.route("show", { path: "/:id" });
  });
}
