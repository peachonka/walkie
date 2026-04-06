<template>
  <Page>
    <ActionBar title="Walky" class="bg-blue-500">
      <ActionItem
        text="Profile"
        android.position="popup"
        @tap="goToProfile"
      />
    </ActionBar>

    <ScrollView>
      <StackLayout class="p-4">
        <StackLayout v-if="pet" class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label :text="getPetEmoji(pet.type)" class="text-7xl text-center mb-2" />
          <Label :text="pet.name" class="text-2xl font-bold text-center mb-1" />
          <Label :text="`Level ${pet.level}`" class="text-lg text-center text-gray-600 mb-4" />

          <StackLayout class="mb-2">
            <Label text="Experience" class="text-sm text-gray-600 mb-1" />
            <StackLayout class="bg-gray-200 rounded-full h-6">
              <StackLayout
                :width="`${(pet.exp / pet.exp_to_next_level) * 100}%`"
                class="bg-green-500 rounded-full h-6"
              />
            </StackLayout>
            <Label
              :text="`${pet.exp} / ${pet.exp_to_next_level} XP`"
              class="text-xs text-center text-gray-500 mt-1"
            />
          </StackLayout>
        </StackLayout>

        <StackLayout v-if="stats" class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label text="Your Statistics" class="text-xl font-bold mb-4" />

          <GridLayout rows="auto, auto" columns="*, *" class="mb-2">
            <StackLayout row="0" col="0" class="text-center mb-4">
              <Label text="🚶" class="text-3xl mb-1" />
              <Label :text="stats.total_walks || 0" class="text-2xl font-bold" />
              <Label text="Walks" class="text-sm text-gray-600" />
            </StackLayout>

            <StackLayout row="0" col="1" class="text-center mb-4">
              <Label text="📏" class="text-3xl mb-1" />
              <Label :text="formatDistance(stats.total_distance_meters)" class="text-2xl font-bold" />
              <Label text="Distance" class="text-sm text-gray-600" />
            </StackLayout>

            <StackLayout row="1" col="0" class="text-center">
              <Label text="⏱️" class="text-3xl mb-1" />
              <Label :text="formatDuration(stats.total_duration_seconds)" class="text-2xl font-bold" />
              <Label text="Time" class="text-sm text-gray-600" />
            </StackLayout>

            <StackLayout row="1" col="1" class="text-center">
              <Label text="🎁" class="text-3xl mb-1" />
              <Label :text="stats.total_items_collected || 0" class="text-2xl font-bold" />
              <Label text="Items" class="text-sm text-gray-600" />
            </StackLayout>
          </GridLayout>
        </StackLayout>

        <Button
          text="🚶 Start Walk"
          class="btn btn-primary bg-green-500 text-white font-bold py-4 rounded-lg mb-3 text-xl"
          @tap="goToWalk"
        />

        <Button
          text="📜 Walk History"
          class="btn bg-blue-500 text-white font-bold py-4 rounded-lg mb-3"
          @tap="goToHistory"
        />

        <Button
          text="🎁 My Collection"
          class="btn bg-purple-500 text-white font-bold py-4 rounded-lg mb-3"
          @tap="goToCollection"
        />

        <Button
          text="🏆 Achievements"
          class="btn bg-yellow-500 text-white font-bold py-4 rounded-lg mb-3"
          @tap="goToAchievements"
        />

        <ActivityIndicator :busy="loading" class="mt-4" v-if="loading" />
      </StackLayout>
    </ScrollView>
  </Page>
</template>

<script lang="ts">
import Vue from "nativescript-vue";
import petService from '../services/pet.service';
import userService from '../services/user.service';
import authService from '../services/auth.service';

export default Vue.extend({
  data() {
    return {
      pet: null as any,
      stats: null as any,
      loading: true
    };
  },

  async mounted() {
    await this.checkAuth();
    await this.loadData();
  },

  methods: {
    async checkAuth() {
      const session = await authService.getSession();
      if (!session) {
        const Login = (await import('./Login.vue')).default;
        this.$navigateTo(Login, { clearHistory: true });
      }
    },

    async loadData() {
      this.loading = true;

      const petResult = await petService.getPet();
      if ('id' in petResult) {
        this.pet = petResult;
      }

      const statsResult = await userService.getStatistics();
      if (statsResult.status === 'success') {
        this.stats = statsResult.data;
      }

      this.loading = false;
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

    async goToWalk() {
      const WalkScreen = (await import('./WalkScreen.vue')).default;
      this.$navigateTo(WalkScreen);
    },

    async goToHistory() {
      const WalkHistory = (await import('./WalkHistory.vue')).default;
      this.$navigateTo(WalkHistory);
    },

    async goToCollection() {
      const Collection = (await import('./Collection.vue')).default;
      this.$navigateTo(Collection);
    },

    async goToAchievements() {
      const Achievements = (await import('./Achievements.vue')).default;
      this.$navigateTo(Achievements);
    },

    async goToProfile() {
      const Profile = (await import('./Profile.vue')).default;
      this.$navigateTo(Profile);
    }
  }
});
</script>

<style scoped lang="scss">
/* Стили будут добавлены позже */
</style>