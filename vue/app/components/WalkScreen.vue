<template>
  <Page>
    <ActionBar title="Walking" class="bg-green-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="handleBack" />
    </ActionBar>

    <GridLayout rows="*, auto">
      <ScrollView row="0">
        <StackLayout class="p-6">
          <Label text="🐾" class="text-8xl text-center mb-6" />

          <StackLayout v-if="!walkStarted" class="text-center mb-6">
            <Label text="Ready to walk?" class="text-2xl font-bold mb-2" />
            <Label
              text="Tap the button below to start tracking your walk"
              class="text-gray-600"
              textWrap="true"
            />
          </StackLayout>

          <StackLayout v-else class="bg-white rounded-lg p-6 mb-4 shadow">
            <Label text="Walk in Progress" class="text-2xl font-bold text-center mb-4" />

            <StackLayout class="mb-4">
              <Label text="Distance" class="text-sm text-gray-600 mb-1" />
              <Label :text="formatDistance(distance)" class="text-3xl font-bold text-green-500" />
            </StackLayout>

            <StackLayout class="mb-4">
              <Label text="Duration" class="text-sm text-gray-600 mb-1" />
              <Label :text="formatDuration(duration)" class="text-2xl font-bold" />
            </StackLayout>

            <StackLayout class="mb-4">
              <Label text="Items Collected" class="text-sm text-gray-600 mb-1" />
              <Label :text="`🎁 ${itemsCollected}`" class="text-2xl font-bold text-purple-500" />
            </StackLayout>

            <StackLayout class="mb-4" v-if="lastItemCollected">
              <Label text="Just Found!" class="text-sm text-green-600 mb-1 font-bold" />
              <Label
                :text="`${lastItemCollected.icon} ${lastItemCollected.name}`"
                class="text-lg text-center"
              />
            </StackLayout>

            <Label
              :text="`📍 Tracking points: ${trackPoints}`"
              class="text-sm text-gray-500 text-center"
            />
          </StackLayout>

          <Label
            v-if="errorMessage"
            :text="errorMessage"
            class="text-red-500 text-center mb-4"
            textWrap="true"
          />
        </StackLayout>
      </ScrollView>

      <StackLayout row="1" class="p-4">
        <Button
          v-if="!walkStarted"
          text="Start Walk"
          class="btn btn-primary bg-green-500 text-white font-bold py-4 rounded-lg text-xl"
          @tap="startWalk"
          :isEnabled="!loading"
        />

        <Button
          v-else
          text="End Walk"
          class="btn bg-red-500 text-white font-bold py-4 rounded-lg text-xl"
          @tap="endWalk"
          :isEnabled="!loading"
        />

        <ActivityIndicator :busy="loading" class="mt-4" v-if="loading" />
      </StackLayout>
    </GridLayout>
  </Page>
</template>

<script lang="ts">
import Vue from 'nativescript-vue';
import * as geolocation from '@nativescript/geolocation';
import { Accuracy } from '@nativescript/core/ui/enums';
import walkService from '../services/walk.service';

export default Vue.extend({
  data() {
    return {
      walkStarted: false,
      walkId: null as string | null,
      distance: 0,
      duration: 0,
      itemsCollected: 0,
      trackPoints: 0,
      lastItemCollected: null as any,
      loading: false,
      errorMessage: '',
      watchId: null as number | null,
      startTime: null as Date | null,
      durationInterval: null as any,
      sequenceNumber: 0
    };
  },

  beforeDestroy() {
    this.stopTracking();
  },

  methods: {
    async startWalk() {
      this.loading = true;
      this.errorMessage = '';

      const hasPermission = await geolocation.enableLocationRequest();
      if (!hasPermission) {
        this.errorMessage = 'Location permission is required to track walks';
        this.loading = false;
        return;
      }

      const result = await walkService.startWalk();

      if ('error' in result) {
        this.errorMessage = result.error;
        this.loading = false;
        return;
      }

      this.walkId = result.walk_id;
      this.walkStarted = true;
      this.startTime = new Date();
      this.sequenceNumber = 0;
      this.loading = false;

      this.startTracking();
      this.startDurationTimer();
    },

    startTracking() {
      this.watchId = geolocation.watchLocation(
        async (location) => {
          if (!this.walkId || !location) return;

          this.sequenceNumber++;
          this.trackPoints = this.sequenceNumber;

          const result = await walkService.trackPoint(this.walkId, {
            lat: location.latitude,
            lng: location.longitude,
            sequenceNumber: this.sequenceNumber
          });

          if ('collected_item' in result && result.collected_item) {
            this.itemsCollected++;
            this.lastItemCollected = result.collected_item;

            setTimeout(() => {
              this.lastItemCollected = null;
            }, 5000);
          }
        },
        (error) => {
          console.error('Location error:', error);
        },
        {
          desiredAccuracy: Accuracy.high,
          updateDistance: 10,
          minimumUpdateTime: 5000
        }
      );
    },

    stopTracking() {
      if (this.watchId !== null) {
        geolocation.clearWatch(this.watchId);
        this.watchId = null;
      }

      if (this.durationInterval) {
        clearInterval(this.durationInterval);
        this.durationInterval = null;
      }
    },

    startDurationTimer() {
      this.durationInterval = setInterval(() => {
        if (this.startTime) {
          this.duration = Math.floor((new Date().getTime() - this.startTime.getTime()) / 1000);
        }
      }, 1000);
    },

    async endWalk() {
      if (!this.walkId) return;

      this.loading = true;
      this.stopTracking();

      const result = await walkService.endWalk(this.walkId);
      this.loading = false;

      if ('error' in result) {
        this.errorMessage = result.error;
        return;
      }

      this.distance = result.distance_meters;
      this.itemsCollected = result.items_collected;

      const WalkSummary = (await import('./WalkSummary.vue')).default;
      this.$navigateTo(WalkSummary, {
        props: {
          summary: result
        },
        clearHistory: false
      });
    },

    handleBack() {
      if (this.walkStarted) {
        const confirm = require('@nativescript/core').confirm;
        confirm({
          title: 'Walk in Progress',
          message: 'Do you want to end this walk?',
          okButtonText: 'End Walk',
          cancelButtonText: 'Continue'
        }).then((result: boolean) => {
          if (result) {
            this.endWalk();
          }
        });
      } else {
        this.$navigateBack();
      }
    },

    formatDistance(meters: number): string {
      const km = meters / 1000;
      return km < 1 ? `${Math.round(meters)} m` : `${km.toFixed(2)} km`;
    },

    formatDuration(seconds: number): string {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const secs = seconds % 60;

      if (hours > 0) {
        return `${hours}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
      }
      return `${minutes}:${String(secs).padStart(2, '0')}`;
    }
  }
});
</script>
