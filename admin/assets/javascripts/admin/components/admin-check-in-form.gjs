import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { array, fn, hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import Form from "discourse/components/form";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import EmailGroupUserChooser from "discourse/select-kit/components/email-group-user-chooser";
import { i18n } from "discourse-i18n";

export default class AdminCheckInForm extends Component {
  @service toasts;

  @tracked loading = false;

  get formData() {
    return { username: null, check_in_date: "" };
  }

  // EmailGroupUserChooser calls onChange with an array of usernames.
  // We only allow one selection (maximum=1), so store just the first element.
  @action
  setUsername(field, usernames) {
    field.set(usernames[0] ?? null);
  }

  @action
  async onSubmit(data) {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const result = await ajax(
        `/admin/plugins/discourse-daily-challenge/challenges/${this.args.challengeId}/check_ins`,
        { type: "POST", data }
      );
      this.toasts.success({
        duration: "short",
        data: { message: i18n("daily_challenge.admin.check_ins.added") },
      });
      this.args.onSave?.(result.check_in);
    } catch (err) {
      popupAjaxError(err);
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="daily-check-in-form">
      <Form @data={{this.formData}} @onSubmit={{this.onSubmit}} as |form|>
        <form.Field
          @name="username"
          @title={{i18n "daily_challenge.admin.check_ins.user"}}
          @validation="required"
          @type="custom"
          as |field|
        >
          {{! field is from the outer block; Control just wraps in a div and yields }}
          <field.Control>
            <EmailGroupUserChooser
              @value={{if field.value (array field.value) (array)}}
              @onChange={{fn this.setUsername field}}
              @options={{hash
                maximum=1
                excludeGroups=true
                filterPlaceholder="daily_challenge.admin.check_ins.user_search_placeholder"
              }}
            />
          </field.Control>
        </form.Field>

        <form.Field
          @name="check_in_date"
          @title={{i18n "daily_challenge.admin.check_ins.date"}}
          @validation="required"
          @type="input-date"
          as |field|
        >
          <field.Control />
        </form.Field>

        <form.Actions>
          <form.Submit
            @label="daily_challenge.admin.check_ins.add"
            @disabled={{this.loading}}
          />
          <form.Button
            @label="daily_challenge.admin.form.cancel"
            @action={{@onCancel}}
            class="btn-default"
          />
        </form.Actions>
      </Form>
    </div>
  </template>
}
