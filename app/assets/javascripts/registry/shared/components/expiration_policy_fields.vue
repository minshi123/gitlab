<script>
import { uniqueId } from 'lodash';
import { GlFormGroup, GlToggle, GlFormSelect, GlFormTextarea, GlSprintf } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import { NAME_REGEX_LENGTH } from '../constants';
import { mapComputedToEvent } from '../utils';

export default {
  components: {
    GlFormGroup,
    GlToggle,
    GlFormSelect,
    GlFormTextarea,
    GlSprintf,
  },
  props: {
    formOptions: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    value: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    labelCols: {
      type: [Number, String],
      required: false,
      default: 3,
    },
    labelAlign: {
      type: String,
      required: false,
      default: 'right',
    },
  },
  textAreaInvalidFeedback: s__(
    'ContainerRegistry|The value of this input should be less than 255 characters',
  ),
  selectList: [
    {
      name: 'expiration-policy-interval',
      label: s__('ContainerRegistry|Expiration interval:'),
      model: 'older_than',
      optionKey: 'olderThan',
    },
    {
      name: 'expiration-policy-schedule',
      label: s__('ContainerRegistry|Expiration schedule:'),
      model: 'cadence',
      optionKey: 'cadence',
    },
    {
      name: 'expiration-policy-latest',
      label: s__('ContainerRegistry|Number of tags to retain:'),
      model: 'keep_n',
      optionKey: 'keepN',
    },
  ],
  textAreaList: [
    {
      name: 'expiration-policy-name-matching',
      label: s__(
        'ContainerRegistry|Docker tags with names matching this regex pattern will expire:',
      ),
      model: 'name_regex',
      placeholder: '.*',
      stateVariable: 'nameRegexState',
      description: s__(
        'ContainerRegistry|Wildcards such as %{codeStart}.*-stable%{codeEnd} or %{codeStart}production/.*%{codeEnd} are supported.  To select all tags, use %{codeStart}.*%{codeEnd}',
      ),
    },
    {
      name: 'expiration-policy-keep-name',
      label: s__(
        'ContainerRegistry|Docker tags with names matching this regex pattern will be preserved:',
      ),
      model: 'name_regex_keep',
      placeholder: null,
      stateVariable: 'nameKeepRegexState',
      description: s__(
        'ContainerRegistry|Wildcards such as %{codeStart}.*-stable%{codeEnd} or %{codeStart}production/.*%{codeEnd} are supported',
      ),
    },
  ],
  data() {
    return {
      uniqueId: uniqueId(),
    };
  },
  computed: {
    ...mapComputedToEvent(
      ['enabled', 'cadence', 'older_than', 'keep_n', 'name_regex', 'name_regex_keep'],
      'value',
    ),
    policyEnabledText() {
      return this.enabled ? __('enabled') : __('disabled');
    },
    textAreaState() {
      return {
        nameRegexState: this.isRegexValid(this.name_regex),
        nameKeepRegexState: this.isRegexValid(this.name_regex_keep),
      };
    },
    fieldsValidity() {
      return (
        this.textAreaState.nameRegexState !== false &&
        this.textAreaState.nameKeepRegexState !== false
      );
    },
    isFormElementDisabled() {
      return !this.enabled || this.isLoading;
    },
  },
  watch: {
    fieldsValidity: {
      immediate: true,
      handler(valid) {
        if (valid) {
          this.$emit('validated');
        } else {
          this.$emit('invalidated');
        }
      },
    },
  },
  methods: {
    isRegexValid(value) {
      return value ? value.length <= NAME_REGEX_LENGTH : null;
    },
    idGenerator(id) {
      return `${id}_${this.uniqueId}`;
    },
    updateModel(value, key) {
      this[key] = value;
    },
  },
};
</script>

<template>
  <div ref="form-elements" class="lh-2">
    <gl-form-group
      :id="idGenerator('expiration-policy-toggle-group')"
      :label-cols="labelCols"
      :label-align="labelAlign"
      :label-for="idGenerator('expiration-policy-toggle')"
      :label="s__('ContainerRegistry|Expiration policy:')"
    >
      <div class="d-flex align-items-start">
        <gl-toggle
          :id="idGenerator('expiration-policy-toggle')"
          v-model="enabled"
          :disabled="isLoading"
        />
        <span class="mb-2 ml-1 lh-2">
          <gl-sprintf
            :message="s__('ContainerRegistry|Docker tag expiration policy is %{toggleStatus}')"
          >
            <template #toggleStatus>
              <strong>{{ policyEnabledText }}</strong>
            </template>
          </gl-sprintf>
        </span>
      </div>
    </gl-form-group>

    <gl-form-group
      v-for="select in $options.selectList"
      :id="idGenerator(`${select.name}-group`)"
      :key="select.name"
      :label-cols="labelCols"
      :label-align="labelAlign"
      :label-for="idGenerator(select.name)"
      :label="select.label"
    >
      <gl-form-select
        :id="idGenerator(select.name)"
        :value="value[select.model]"
        :disabled="isFormElementDisabled"
        @input="updateModel($event, select.model)"
      >
        <option
          v-for="option in formOptions[select.optionKey]"
          :key="option.key"
          :value="option.key"
        >
          {{ option.label }}
        </option>
      </gl-form-select>
    </gl-form-group>

    <gl-form-group
      v-for="textarea in $options.textAreaList"
      :id="idGenerator(`${textarea.name}-group`)"
      :key="textarea.name"
      :label-cols="labelCols"
      :label-align="labelAlign"
      :label-for="idGenerator(textarea.name)"
      :label="textarea.label"
      :state="textAreaState[textarea.stateVariable]"
      :invalid-feedback="$options.textAreaInvalidFeedback"
    >
      <gl-form-textarea
        :id="idGenerator(textarea.name)"
        :value="value[textarea.model]"
        :placeholder="textarea.placeholder"
        :state="textAreaState[textarea.stateVariable]"
        :disabled="isFormElementDisabled"
        trim
        @input="updateModel($event, textarea.model)"
      />
      <template #description>
        <span ref="regex-description">
          <gl-sprintf :message="textarea.description">
            <template #code="{content}">
              <code>{{ content }}</code>
            </template>
          </gl-sprintf>
        </span>
      </template>
    </gl-form-group>
  </div>
</template>
