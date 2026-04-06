<template>
  <Page>
    <ActionBar title="Achievements" class="bg-yellow-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <GridLayout rows="auto, *">
      <StackLayout row="0" class="bg-yellow-50 p-4">
        <Label
          :text="`Unlocked: ${unlockedCount} / ${totalCount}`"
          class="text-lg font-bold text-center"
        />
      </StackLayout>

      <ScrollView row="1">
        <StackLayout class="p-4">
          <StackLayout
            v-if="achievements.length === 0 && !loading"
            class="text-center p-8"
          >
            <Label text="🏆" class="text-6xl mb-4" />
            <Label text="No achievements yet" class="text-xl font-bold mb-2" />
            <Label
              text="Start walking to unlock achievements!"
              class="text-gray-600"
              textWrap="true"
            />
          </StackLayout>

          <Label
            v-if="achievements.length > 0"
            text="🎉 Unlocked"
            class="text-xl font-bold mb-3"
          />

          <StackLayout
            v-for="achievement in unlockedAchievements"
            :key="achievement.id"
            class="bg-yellow-50 border-2 border-yellow-500 rounded-lg p-4 mb-3"
          >
            <GridLayout columns="auto, *" rows="auto">
              <Label
                col="0"
                :text="achievement.achievement_types.icon"
                class="text-4xl mr-3"
              />
              <StackLayout col="1">
                <Label
                  :text="achievement.achievement_types.name"
                  class="text-lg font-bold mb-1"
                />
                <Label
                  :text="achievement.achievement_types.description"
                  class="text-sm text-gray-600 mb-2"
                  textWrap="true"
                />
                <Label
                  :text="`Unlocked: ${formatDate(achievement.unlocked_at)}`"
                  class="text-xs text-gray-500"
                />
              </StackLayout>
            </GridLayout>
          </StackLayout>

          <Label
            v-if="lockedAchievements.length > 0"
            text="🔒 Locked"
            class="text-xl font-bold mb-3 mt-4"
          />

          <StackLayout
            v-for="achievement in lockedAchievements"
            :key="achievement.id"
            class="bg-gray-100 rounded-lg p-4 mb-3 opacity-60"
          >
            <GridLayout columns="auto, *" rows="auto">
              <Label
                col="0"
                text="🔒"
                class="text-4xl mr-3"
              />
              <StackLayout col="1">
                <Label
                  :text="achievement.name"
                  class="text-lg font-bold mb-1"
                />
                <Label
                  :text="achievement.description"
                  class="text-sm text-gray-600"
                  textWrap="true"
                />
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
import userService from '../services/user.service';
import supabaseService from '../services/supabase.service';

export default Vue.extend({
  data() {
    return {
      achievements: [] as any[],
      allAchievementTypes: [] as any[],
      loading: true,
      errorMessage: ''
    };
  },

  computed: {
    unlockedAchievements(): any[] {
      return this.achievements;
    },

    lockedAchievements(): any[] {
      const unlockedIds = new Set(this.achievements.map(a => a.achievement_type_id));
      return this.allAchievementTypes.filter(a => !unlockedIds.has(a.id));
    },

    unlockedCount(): number {
      return this.achievements.length;
    },

    totalCount(): number {
      return this.allAchievementTypes.length;
    }
  },

  async mounted() {
    await this.loadAchievements();
  },

  methods: {
    async loadAchievements() {
      this.loading = true;
      this.errorMessage = '';

      const result = await userService.getAchievements();

      if (result.status === 'success') {
        this.achievements = result.data;
      } else {
        this.errorMessage = result.message || 'Failed to load achievements';
      }

      const supabase = supabaseService.getClient();
      const { data: allTypes } = await supabase
        .from('achievement_types')
        .select('*');

      if (allTypes) {
        this.allAchievementTypes = allTypes;
      }

      this.loading = false;
    },

    formatDate(dateString: string): string {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      });
    },

    goBack() {
      this.$navigateBack();
    }
  }
});
</script>
