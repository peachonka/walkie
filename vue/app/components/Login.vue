<template>
  <Page>
    <ActionBar title="Walky - Login" class="bg-blue-500" />

    <ScrollView>
      <StackLayout class="p-6">
        <Label text="🐾" class="text-6xl text-center mb-4" />
        <Label text="Welcome to Walky" class="text-3xl font-bold text-center mb-2" />
        <Label text="Walk with your virtual pet" class="text-center text-gray-600 mb-8" />

        <TextField
          v-model="email"
          hint="Email"
          keyboardType="email"
          autocorrect="false"
          autocapitalizationType="none"
          class="input mb-4 p-4 bg-gray-100 rounded-lg"
        />

        <TextField
          v-model="password"
          hint="Password"
          secure="true"
          class="input mb-2 p-4 bg-gray-100 rounded-lg"
        />

        <Label
          text="Forgot Password?"
          class="text-blue-500 text-right mb-6"
          @tap="goToForgotPassword"
        />

        <Button
          text="Login"
          class="btn btn-primary bg-blue-500 text-white font-bold py-4 rounded-lg mb-4"
          @tap="handleLogin"
          :isEnabled="!loading"
        />

        <StackLayout orientation="horizontal" class="justify-center">
          <Label text="Don't have an account? " class="text-gray-600" />
          <Label
            text="Register"
            class="text-blue-500 font-bold"
            @tap="goToRegister"
          />
        </StackLayout>

        <ActivityIndicator :busy="loading" class="mt-4" v-if="loading" />

        <Label
          v-if="errorMessage"
          :text="errorMessage"
          class="text-red-500 text-center mt-4"
        />
      </StackLayout>
    </ScrollView>
  </Page>
</template>

<script lang="ts">
import Vue from 'nativescript-vue';
import authService from '../services/auth.service';
import Register from './Register.vue';
import ForgotPassword from './ForgotPassword.vue';
import Home from './Home.vue';

export default Vue.extend({
  name: 'Login',
  data() {
    return {
      email: '',
      password: '',
      loading: false,
      errorMessage: ''
    };
  },
  methods: {
    async handleLogin() {
      if (!this.email || !this.password) {
        this.errorMessage = 'Please fill in all fields';
        return;
      }

      this.loading = true;
      this.errorMessage = '';

      try {
        const result = await authService.login({
          email: this.email,
          password: this.password
        });

        this.loading = false;

        if (result.status === 'success') {
          this.$navigateTo(Home, {
            clearHistory: true
          });
        } else {
          this.errorMessage = result.message || 'Login failed';
        }
      } catch (error) {
        this.loading = false;
        this.errorMessage = 'Connection error';
      }
    },
    goToRegister() {
      this.$navigateTo(Register);
    },
    goToForgotPassword() {
      this.$navigateTo(ForgotPassword);
    }
  }
});
</script>

<style scoped lang="scss">
.input {
  border-width: 1;
  border-color: #e5e7eb;
}

.btn {
  background-color: #3b82f6;
  color: white;
}
</style>