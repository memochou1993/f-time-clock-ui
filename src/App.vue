<template>
  <v-app>
    <v-main>
      <v-container
        fill-height
      >
        <AppForm/>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import AppForm from './components/AppForm.vue';

export default {
  name: 'App',
  components: {
    AppForm,
  },
};
</script>
