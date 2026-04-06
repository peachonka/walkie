<template>
  <Page>
    <ActionBar title="Walk History" class="bg-blue-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <GridLayout rows="auto, *">
      <StackLayout row="0" class="bg-blue-50 p-4">
        <Label :text="`Total Walks: ${totalWalks}`" class="text-lg font-bold text-center" />
      </StackLayout>

      <ScrollView row="1">
        <StackLayout class="p-4">
          <StackLayout
            v-if="walks.length === 0 && !loading"
            class="text-center p-8"
          >
            <Label text="🚶" class="text-6xl mb-4" />
            <Label text="No walks yet" class="text-xl font-bold mb-2" />
            <Label
              text="Start your first walk to see it here!"
              class="text-gray-600"
              textWrap="true"
            />
          </StackLayout>

          <StackLayout
            v-for="walk in walks"
            :key="walk.id"
            class="bg-white rounded-lg p-4 mb-3 shadow"
            @tap="viewWalkDetails(walk.id)"
          >
            <GridLayout rows="auto, auto" columns="*, auto">
              <Label
                row="0"
                col="0"
                :text="formatDate(walk.start_time)"
                class="text-lg font-bold mb-2"
              />
              <Label
                row="0"
                col="1"
                text="›"
                class="text-2xl text-gray-400"
              />

              <StackLayout row="1" col="0" colSpan="2">
                <GridLayout columns="*, *, *" class="mb-2">
                  <StackLayout col="0">
                    <Label text="📏 Distance" class="text-xs text-gray-600" />
                    <Label
                      :text="formatDistance(walk.distance_meters)"
                      class="text-sm font-bold"
                    />
                  </StackLayout>

                  <StackLayout col="1">
                    <Label text="⏱️ Duration" class="text-xs text-gray-600" />
                    <Label
                      :text="formatDuration(walk.duration_seconds)"
                      class="text-sm font-bold"
                    />
                  </StackLayout>

                  <StackLayout col="2">
                    <Label text="🎁 Items" class="text-xs text-gray-600" />
                    <Label
                      :text="`${walk.items_collected || 0}`"
                      class="text-sm font-bold"
                    />
                  </StackLayout>
                </GridLayout>
              </StackLayout>
            </GridLayout>
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
    </GridLayout>
  </Page>
</template>

<script lang="ts">
import Vue from 'nativescript-vue';
import walkService from '../services/walk.service';

export default Vue.extend({
  data() {
    return {
      walks: [] as any[],
      totalWalks: 0,
      loading: true,
      errorMessage: ''
    };
  },

  async mounted() {
    await this.loadHistory();
  },

  methods: {
    async loadHistory() {
      this.loading = true;
      this.errorMessage = '';

      const result = await walkService.getHistory(50, 0);

      if ('error' in result) {
        this.errorMessage = result.error;
      } else {
        this.walks = result.walks;
        this.totalWalks = result.total;
      }

      this.loading = false;
    },

    async viewWalkDetails(walkId: string) {
      const WalkDetails = (await import('./WalkDetails.vue')).default;
      this.$navigateTo(WalkDetails, {
        props: {
          walkId
        }
      });
    },

    formatDate(dateString: string): string {
      const date = new Date(dateString);
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);

      if (date.toDateString() === today.toDateString()) {
        return `Today at ${date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}`;
      } else if (date.toDateString() === yesterday.toDateString()) {
        return `Yesterday at ${date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}`;
      } else {
        return date.toLocaleDateString('en-US', {
          month: 'short',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        });
      }
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

    goBack() {
      this.$navigateBack();
    }
  }
});
</script>
