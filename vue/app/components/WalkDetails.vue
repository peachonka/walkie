<template>
  <Page>
    <ActionBar title="Walk Details" class="bg-blue-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <ScrollView>
      <StackLayout class="p-4">
        <StackLayout v-if="walk" class="bg-white rounded-lg p-6 mb-4 shadow">
          <Label text="Summary" class="text-2xl font-bold mb-4" />

          <StackLayout class="mb-3">
            <Label text="📅 Date" class="text-sm text-gray-600 mb-1" />
            <Label :text="formatDateTime(walk.start_time)" class="text-lg font-bold" />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="📏 Distance" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="formatDistance(walk.distance_meters)"
              class="text-lg font-bold text-green-500"
            />
          </StackLayout>

          <StackLayout class="mb-3">
            <Label text="⏱️ Duration" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="formatDuration(walk.duration_seconds)"
              class="text-lg font-bold"
            />
          </StackLayout>

          <StackLayout class="mb-3" v-if="walk.route && walk.route.length > 0">
            <Label text="📍 Route Points" class="text-sm text-gray-600 mb-1" />
            <Label
              :text="`${walk.route.length} tracking points`"
              class="text-lg font-bold"
            />
          </StackLayout>
        </StackLayout>

        <StackLayout
          v-if="walk && walk.collected_items && walk.collected_items.length > 0"
          class="bg-white rounded-lg p-6 mb-4 shadow"
        >
          <Label text="🎁 Items Collected" class="text-2xl font-bold mb-4" />

          <StackLayout
            v-for="item in walk.collected_items"
            :key="item.id"
            class="bg-gray-50 p-4 rounded-lg mb-3"
          >
            <GridLayout columns="auto, *" rows="auto">
              <Label
                col="0"
                :text="item.item_types.icon"
                class="text-3xl mr-3"
              />
              <StackLayout col="1">
                <Label
                  :text="item.item_types.name"
                  class="text-lg font-bold mb-1"
                />
                <Label
                  :text="getRarityText(item.item_types.rarity)"
                  :class="getRarityClass(item.item_types.rarity)"
                />
                <Label
                  :text="`Found at ${formatTime(item.collected_at)}`"
                  class="text-xs text-gray-500 mt-1"
                />
              </StackLayout>
            </GridLayout>
          </StackLayout>
        </StackLayout>

        <StackLayout
          v-if="walk && (!walk.collected_items || walk.collected_items.length === 0)"
          class="bg-gray-50 rounded-lg p-6 text-center"
        >
          <Label text="No items collected during this walk" class="text-gray-600" />
        </StackLayout>

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
import walkService from '../services/walk.service';

export default Vue.extend({
  props: {
    walkId: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      walk: null as any,
      loading: true,
      errorMessage: ''
    };
  },

  async mounted() {
    await this.loadWalkDetails();
  },

  methods: {
    async loadWalkDetails() {
      this.loading = true;
      this.errorMessage = '';

      const result = await walkService.getWalkDetails(this.walkId);

      if ('error' in result) {
        this.errorMessage = result.error;
      } else {
        this.walk = result;
      }

      this.loading = false;
    },

    formatDateTime(dateString: string): string {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        month: 'long',
        day: 'numeric',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    },

    formatTime(dateString: string): string {
      const date = new Date(dateString);
      return date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
      });
    },

    formatDistance(meters: number): string {
      if (!meters) return '0 m';
      const km = meters / 1000;
      return km < 1 ? `${Math.round(meters)} m` : `${km.toFixed(2)} km`;
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

    getRarityText(rarity: string): string {
      return rarity.charAt(0).toUpperCase() + rarity.slice(1);
    },

    getRarityClass(rarity: string): string {
      const classes: { [key: string]: string } = {
        common: 'text-sm text-gray-600',
        rare: 'text-sm text-blue-600 font-bold',
        epic: 'text-sm text-purple-600 font-bold',
        legendary: 'text-sm text-yellow-600 font-bold'
      };
      return classes[rarity] || 'text-sm text-gray-600';
    },

    goBack() {
      this.$navigateBack();
    }
  }
});
</script>
