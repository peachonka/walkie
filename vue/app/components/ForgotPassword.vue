<template>
  <Page>
    <ActionBar title="Reset Password" class="bg-blue-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <ScrollView>
      <StackLayout class="p-6">
        <Label text="🔐" class="text-6xl text-center mb-4" />
        <Label text="Forgot Password?" class="text-3xl font-bold text-center mb-2" />
        <Label
          text="Enter your email to receive a password reset link"
          class="text-center text-gray-600 mb-8"
          textWrap="true"
        />

        <TextField
          v-model="email"
          hint="Email"
          keyboardType="email"
          autocorrect="false"
          autocapitalizationType="none"
          class="input mb-6 p-4 bg-gray-100 rounded-lg"
        />

        <Button
          text="Send Reset Link"
          class="btn btn-primary bg-blue-500 text-white font-bold py-4 rounded-lg mb-4"
          @tap="handleResetPassword"
          :isEnabled="!loading"
        />

        <ActivityIndicator :busy="loading" class="mt-4" v-if="loading" />

        <Label
          v-if="successMessage"
          :text="successMessage"
          class="text-green-500 text-center mt-4"
          textWrap="true"
        />

        <Label
          v-if="errorMessage"
          :text="errorMessage"
          class="text-red-500 text-center mt-4"
          textWrap="true"
        />
      </StackLayout>
    </ScrollView>
  </Page>
</template>

<script lang="ts">
import Vue from 'nativescript-vue';
import authService from '../services/auth.service';

export default Vue.extend({
  data() {
    return {
      email: '',
      loading: false,
      errorMessage: '',
      successMessage: ''
    };
  },

  methods: {
    async handleResetPassword() {
      if (!this.email) {
        this.errorMessage = 'Please enter your email';
        return;
      }

      this.loading = true;
      this.errorMessage = '';
      this.successMessage = '';

      const result = await authService.resetPassword(this.email);

      this.loading = false;

      if (result.status === 'success') {
        this.successMessage = 'Password reset link sent to your email';
        this.email = '';
      } else {
        this.errorMessage = result.message || 'Failed to send reset link';
      }
    },

    goBack() {
      this.$navigateBack();
    }
  }
});
</script>
