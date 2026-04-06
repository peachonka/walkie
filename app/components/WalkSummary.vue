<template>
  <Page>
    <ActionBar title="Walk Complete!" class="bg-green-500" />

    <ScrollView>
      <StackLayout class="p-6">
        <Label text="🎉" class="text-8xl text-center mb-4" />
        <Label text="Great Walk!" class="text-3xl font-bold text-center mb-2" />
        <Label
          text="Here's what you accomplished"
          class="text-center text-gray-600 mb-8"
        />

        <StackLayout class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label text="Summary" class="text-2xl font-bold mb-4" />

          <StackLayout class="mb-3">
            <Label text="📏 Distance" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="`${summary.summary.distance_km} km`"
              class="text-2xl font-bold text-green-500"
            />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="⏱️ Duration" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="`${summary.summary.duration_min} minutes`"
              class="text-2xl font-bold"
            />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="🎁 Items Found" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="`${summary.items_collected}`"
              class="text-2xl font-bold text-purple-500"
            />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="⭐ Experience Earned" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="`${summary.summary.exp_earned} XP`"
              class="text-2xl font-bold text-yellow-500"
            />
          </StackLayout>
        </StackLayout>

        <StackLayout
          v-if="summary.new_achievements && summary.new_achievements.length > 0"
          class="bg-yellow-50 rounded-lg p-6 mb-4 border-2 border-yellow-500"
        >
          <Label text="🏆 New Achievements!" class="text-2xl font-bold mb-4 text-yellow-700" />

          <StackLayout
            v-for="achievement in summary.new_achievements"
            :key="achievement.id"
            class="mb-3 bg-white p-4 rounded-lg"
          >
            <Label :text="achievement.icon" class="text-4xl text-center mb-2" />
            <Label :text="achievement.name" class="text-lg font-bold text-center mb-1" />
            <Label
              :text="achievement.description"
              class="text-sm text-center text-gray-600"
              textWrap="true"
            />
          </StackLayout>
        </StackLayout>

        <Button
          text="Back to Home"
          class="btn btn-primary bg-blue-500 text-white font-bold py-4 rounded-lg mb-3"
          @tap="goHome"
        />

        <Button
          text="View Walk Details"
          class="btn bg-green-500 text-white font-bold py-4 rounded-lg"
          @tap="viewDetails"
        />
      </StackLayout>
    </ScrollView>
  </Page>
</template>

<script lang="ts">
import Vue from 'nativescript-vue';

export default Vue.extend({
  props: {
    summary: {
      type: Object,
      required: true
    }
  },

  methods: {
    goHome() {
      const Home = require('./Home.vue').default;
      this.$navigateTo(Home, {
        clearHistory: true
      });
    },

    async viewDetails() {
      const WalkDetails = (await import('./WalkDetails.vue')).default;
      this.$navigateTo(WalkDetails, {
        props: {
          walkId: this.summary.walk_id
        }
      });
    }
  }
});
</script>
