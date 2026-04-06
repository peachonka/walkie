<template>
  <Page>
    <ActionBar title="Profile" class="bg-blue-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <ScrollView>
      <StackLayout class="p-4">
        <StackLayout v-if="profile" class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label text="Account" class="text-2xl font-bold mb-4" />

          <StackLayout class="mb-3">
            <Label text="Username" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="profile.profile.username"
              class="text-lg font-bold"
            />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="Email" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="profile.profile.email"
              class="text-lg"
            />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="Member Since" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="formatDate(profile.profile.created_at)"
              class="text-lg"
            />
          </StackLayout>
        </StackLayout>

        <StackLayout v-if="profile && profile.pet" class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label text="Your Pet" class="text-2xl font-bold mb-4" />

          <StackLayout class="text-center mb-4">
            <Label :text="getPetEmoji(profile.pet.type)" class="text-7xl mb-2" />
            <Label :text="profile.pet.name" class="text-2xl font-bold mb-1" />
            <Label
              :text="`Level ${profile.pet.level} ${profile.pet.type}`"
              class="text-lg text-gray-600 capitalize"
            />
          </StackLayout>

          <Button
            text="Change Pet Name"
            class="btn bg-blue-500 text-white font-bold py-3 rounded-lg"
            @tap="showChangePetNameDialog"
          />
        </StackLayout>

        <StackLayout v-if="profile && profile.statistics" class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label text="Lifetime Statistics" class="text-2xl font-bold mb-4" />

          <GridLayout rows="auto, auto, auto" columns="*, *" class="mb-2">
            <StackLayout row="0" col="0" class="mb-3">
              <Label text="Total Walks" class="text-sm text-gray-600 mb-1" />
              <Label
                :text="`${profile.statistics.total_walks || 0}`"
                class="text-xl font-bold"
              />
            </StackLayout>

            <StackLayout row="0" col="1" class="mb-3">
              <Label text="Total Distance" class="text-sm text-gray-600 mb-1" />
              <Label
                :text="formatDistance(profile.statistics.total_distance_meters)"
                class="text-xl font-bold"
              />
            </StackLayout>

            <StackLayout row="1" col="0" class="mb-3">
              <Label text="Total Time" class="text-sm text-gray-600 mb-1" />
              <Label
                :text="formatDuration(profile.statistics.total_duration_seconds)"
                class="text-xl font-bold"
              />
            </StackLayout>

            <StackLayout row="1" col="1" class="mb-3">
              <Label text="Items Found" class="text-sm text-gray-600 mb-1" />
              <Label
                :text="`${profile.statistics.total_items_collected || 0}`"
                class="text-xl font-bold"
              />
            </StackLayout>

            <StackLayout row="2" col="0" colSpan="2">
              <Label text="Longest Walk" class="text-sm text-gray-600 mb-1" />
              <Label
                :text="formatDistance(profile.statistics.longest_walk_meters)"
                class="text-xl font-bold text-green-500"
              />
            </StackLayout>
          </GridLayout>
        </StackLayout>

        <Button
          text="Logout"
          class="btn bg-red-500 text-white font-bold py-4 rounded-lg mb-3"
          @tap="handleLogout"
        />

        <ActivityIndicator :busy="loading" class="mt-4" v-if="loading" />

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
import userService from '../services/user.service';
import authService from '../services/auth.service';
import petService from '../services/pet.service';
import { prompt } from '@nativescript/core';

export default Vue.extend({
  data() {
    return {
      profile: null as any,
      loading: true,
      errorMessage: ''
    };
  },

  async mounted() {
    await this.loadProfile();
  },

  methods: {
    async loadProfile() {
      this.loading = true;
      this.errorMessage = '';

      const result = await userService.getProfile();

      if (result.status === 'success') {
        this.profile = result.data;
      } else {
        this.errorMessage = result.message || 'Failed to load profile';
      }

      this.loading = false;
    },

    async showChangePetNameDialog() {
      const result = await prompt({
        title: 'Change Pet Name',
        message: 'Enter a new name for your pet:',
        okButtonText: 'Change',
        cancelButtonText: 'Cancel',
        defaultText: this.profile.pet.name,
        inputType: 'text'
      });

      if (result.result && result.text && result.text.trim()) {
        await this.changePetName(result.text.trim());
      }
    },

    async changePetName(newName: string) {
      this.loading = true;

      const result = await petService.updatePetName(newName);

      if ('success' in result) {
        this.profile.pet.name = newName;
      } else {
        this.errorMessage = result.error || 'Failed to update pet name';
      }

      this.loading = false;
    },

    async handleLogout() {
      const confirm = require('@nativescript/core').confirm;
      const result = await confirm({
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        okButtonText: 'Logout',
        cancelButtonText: 'Cancel'
      });

      if (result) {
        await authService.logout();
        const Login = (await import('./Login.vue')).default;
        this.$navigateTo(Login, {
          clearHistory: true
        });
      }
    },

    getPetEmoji(type: string): string {
      const emojis: { [key: string]: string } = {
        dog: '🐕',
        cat: '🐈',
        rabbit: '🐰',
        hamster: '🐹'
      };
      return emojis[type] || '🐾';
    },

    formatDate(dateString: string): string {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        month: 'long',
        day: 'numeric',
        year: 'numeric'
      });
    },

    formatDistance(meters: number): string {
      if (!meters) return '0 km';
      const km = meters / 1000;
      return km < 1 ? `${Math.round(meters)} m` : `${km.toFixed(1)} km`;
    },

    formatDuration(seconds: number): string {
      if (!seconds) return '0 min';
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);

      if (hours > 0) {
        return `${hours}h ${minutes}m`;
      }
      return `${minutes} min`;
    },

    goBack() {
      this.$navigateBack();
    }
  }
});
</script>
