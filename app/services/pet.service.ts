import supabaseService from './supabase.service';

class PetService {
  private supabase = supabaseService.getClient();

  async getPet() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await this.supabase
        .from('pets')
        .select(`
          id,
          name,
          level,
          exp,
          exp_to_next_level,
          type_id,
          pet_types (
            id,
            type,
            avatar
          )
        `)
        .eq('user_id', user.id)
        .maybeSingle();

      if (error) throw error;

      if (!data) {
        return { error: 'Pet not found' };
      }

      return {
        id: data.id,
        name: data.name,
        type: data.pet_types.type,
        avatar: data.pet_types.avatar,
        level: data.level,
        exp: data.exp,
        exp_to_next_level: data.exp_to_next_level
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async updatePetName(newName: string) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const currentPet = await this.getPet();
      if ('error' in currentPet) throw new Error(currentPet.error);

      const { error } = await this.supabase
        .from('pets')
        .update({ name: newName })
        .eq('user_id', user.id);

      if (error) throw error;

      return {
        success: true,
        old_name: currentPet.name,
        new_name: newName
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async getPetTypes() {
    try {
      const { data, error } = await this.supabase
        .from('pet_types')
        .select('id, type, avatar');

      if (error) throw error;

      return { pets: data };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async addExperience(expAmount: number) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const pet = await this.getPet();
      if ('error' in pet) throw new Error(pet.error);

      let newExp = pet.exp + expAmount;
      let newLevel = pet.level;
      let newExpToNextLevel = pet.exp_to_next_level;

      while (newExp >= newExpToNextLevel) {
        newExp -= newExpToNextLevel;
        newLevel += 1;
        newExpToNextLevel = Math.floor(newExpToNextLevel * 1.5);
      }

      const { error } = await this.supabase
        .from('pets')
        .update({
          exp: newExp,
          level: newLevel,
          exp_to_next_level: newExpToNextLevel
        })
        .eq('user_id', user.id);

      if (error) throw error;

      return { success: true, newLevel, newExp };
    } catch (error: any) {
      return { error: error.message };
    }
  }
}

export default new PetService();
