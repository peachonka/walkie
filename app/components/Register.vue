<template>
  <Page>
    <ActionBar title="Create Account" class="bg-blue-500">
      <NavigationButton text="Back" android.systemIcon="ic_menu_back" @tap="goBack" />
    </ActionBar>

    <ScrollView>
      <StackLayout class="p-6">
        <Label text="Join Walky" class="text-3xl font-bold text-center mb-2" />
        <Label text="Create your account and pet" class="text-center text-gray-600 mb-6" />

        <TextField
          v-model="username"
          hint="Username"
          autocorrect="false"
          class="input mb-4 p-4 bg-gray-100 rounded-lg"
        />

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
          hint="Password (min 6 characters)"
          secure="true"
          class="input mb-6 p-4 bg-gray-100 rounded-lg"
        />

        <Label text="Choose Your Pet" class="text-xl font-bold mb-4" />

        <GridLayout rows="auto" columns="*, *, *, *" class="mb-4" v-if="petTypes.length > 0">
          <StackLayout
            v-for="(pet, index) in petTypes"
            :key="pet.id"
            :col="index"
            class="text-center p-2"
            @tap="selectPet(pet.id)"
          >
            <Label
              :text="getPetEmoji(pet.type)"
              :class="['text-5xl mb-2', selectedPet === pet.id ? 'opacity-100' : 'opacity-50']"
            />
            <Label
              :text="pet.type"
              :class="['text-sm capitalize', selectedPet === pet.id ? 'font-bold text-blue-500' : 'text-gray-600']"
            />
          </StackLayout>
        </GridLayout>

        <TextField
          v-model="petName"
          hint="Pet Name"
          class="input mb-6 p-4 bg-gray-100 rounded-lg"
        />

        <Button
          text="Create Account"
          class="btn btn-primary bg-blue-500 text-white font-bold py-4 rounded-lg mb-4"
          @tap="handleRegister"
          :isEnabled="!loading"
        />

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
import petService from '../services/pet.service';
import Home from './Home.vue';

export default Vue.extend({
  data() {
    return {
      username: '',
      email: '',
      password: '',
      petName: '',
      selectedPet: 1,
      petTypes: [] as any[],
      loading: false,
      errorMessage: ''
    };
  },

  async mounted() {
    const result = await petService.getPetTypes();
    if ('pets' in result) {
      this.petTypes = result.pets;
      if (this.petTypes.length > 0) {
        this.selectedPet = this.petTypes[0].id;
      }
    }
  },

  methods: {
    selectPet(petId: number) {
      this.selectedPet = petId;
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

    async handleRegister() {
      if (!this.username || !this.email || !this.password || !this.petName) {
        this.errorMessage = 'Please fill in all fields';
        return;
      }

      if (this.password.length < 6) {
        this.errorMessage = 'Password must be at least 6 characters';
        return;
      }

      this.loading = true;
      this.errorMessage = '';

      const result = await authService.register({
        username: this.username,
        email: this.email,
        password: this.password,
        pet: this.selectedPet,
        petName: this.petName
      });

      this.loading = false;

      if (result.status === 'success') {
        this.$navigateTo(Home, {
          clearHistory: true
        });
      } else {
        this.errorMessage = result.message || 'Registration failed';
      }
    },

    goBack() {
      this.$navigateBack();
    }
  }
});
</script>
