<template>
  <Page>
    <ActionBar title="My Collection" class="bg-purple-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <GridLayout rows="auto, *">
      <StackLayout row="0" class="bg-purple-50 p-4">
        <Label
          :text="`Total Items: ${totalItems}`"
          class="text-lg font-bold text-center"
        />
      </StackLayout>

      <ScrollView row="1">
        <StackLayout class="p-4">
          <StackLayout
            v-if="items.length === 0 && !loading"
            class="text-center p-8"
          >
            <Label text="🎁" class="text-6xl mb-4" />
            <Label text="No items yet" class="text-xl font-bold mb-2" />
            <Label
              text="Go for a walk to collect items!"
              class="text-gray-600"
              textWrap="true"
            />
          </StackLayout>

          <StackLayout
            v-for="item in groupedItems"
            :key="item.name"
            class="bg-white rounded-lg p-4 mb-3 shadow"
          >
            <GridLayout columns="auto, *, auto" rows="auto">
              <Label
                col="0"
                :text="item.icon"
                class="text-4xl mr-3"
              />

              <StackLayout col="1">
                <Label :text="item.name" class="text-lg font-bold mb-1" />
                <Label
                  :text="getRarityText(item.rarity)"
                  :class="getRarityClass(item.rarity)"
                />
                <Label
                  :text="item.description"
                  class="text-xs text-gray-500 mt-1"
                  textWrap="true"
                />
              </StackLayout>

              <StackLayout col="2" class="text-right">
                <Label
                  :text="`×${item.count}`"
                  class="text-2xl font-bold text-purple-500"
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
import supabaseService from '../services/supabase.service';

export default Vue.extend({
  data() {
    return {
      items: [] as any[],
      groupedItems: [] as any[],
      totalItems: 0,
      loading: true,
      errorMessage: ''
    };
  },

  async mounted() {
    await this.loadCollection();
  },

  methods: {
    async loadCollection() {
      this.loading = true;
      this.errorMessage = '';

      try {
        const supabase = supabaseService.getClient();
        const { data: { user } } = await supabase.auth.getUser();

        if (!user) throw new Error('Not authenticated');

        const { data, error } = await supabase
          .from('user_items')
          .select(`
            id,
            collected_at,
            item_types (
              name,
              description,
              rarity,
              icon
            )
          `)
          .eq('user_id', user.id)
          .order('collected_at', { ascending: false });

        if (error) throw error;

        this.items = data || [];
        this.totalItems = this.items.length;
        this.groupItems();
      } catch (error: any) {
        this.errorMessage = error.message;
      }

      this.loading = false;
    },

    groupItems() {
      const grouped: { [key: string]: any } = {};

      this.items.forEach((item) => {
        const name = item.item_types.name;
        if (!grouped[name]) {
          grouped[name] = {
            name: item.item_types.name,
            description: item.item_types.description,
            rarity: item.item_types.rarity,
            icon: item.item_types.icon,
            count: 0
          };
        }
        grouped[name].count++;
      });

      this.groupedItems = Object.values(grouped).sort((a, b) => {
        const rarityOrder: { [key: string]: number } = {
          legendary: 0,
          epic: 1,
          rare: 2,
          common: 3
        };
        return rarityOrder[a.rarity] - rarityOrder[b.rarity];
      });
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
