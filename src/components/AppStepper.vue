<template>
  <v-stepper
    :value="value"
    alt-labels
    flat
  >
    <v-stepper-header>
      <v-stepper-step
        step="1"
      />
      <v-divider></v-divider>
      <v-stepper-step
        step="2"
      />
    </v-stepper-header>
  </v-stepper>
</template>

<script>
export default {
  props: {
    display: {
      type: Boolean,
      default: false,
    },
    value: {
      type: String,
      default: '1',
    },
  },
};
</script>
