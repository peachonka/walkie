import supabaseService from './supabase.service';

class UserService {
  private supabase = supabaseService.getClient();

  async getProfile() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data: profile, error: profileError } = await this.supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

      if (profileError) throw profileError;

      const { data: pet, error: petError } = await this.supabase
        .from('pets')
        .select(`
          *,
          pet_types (
            type,
            avatar
          )
        `)
        .eq('user_id', user.id)
        .maybeSingle();

      const { data: stats, error: statsError } = await this.supabase
        .from('user_statistics')
        .select('*')
        .eq('user_id', user.id)
        .maybeSingle();

      return {
        status: 'success',
        data: {
          profile,
          pet: pet ? {
            id: pet.id,
            name: pet.name,
            type: pet.pet_types?.type,
            avatar: pet.pet_types?.avatar,
            level: pet.level,
            exp: pet.exp,
            exp_to_next_level: pet.exp_to_next_level
          } : null,
          statistics: stats
        }
      };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message
      };
    }
  }

  async updateProfile(username?: string, email?: string) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const updates: any = {};
      if (username) updates.username = username;
      if (email) updates.email = email;

      const { data, error } = await this.supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.id)
        .select()
        .single();

      if (error) throw error;

      return {
        status: 'success',
        data
      };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message
      };
    }
  }

  async updatePet(petName?: string, petType?: number) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const updates: any = {};
      if (petName) updates.name = petName;
      if (petType) updates.type_id = petType;

      const { data, error } = await this.supabase
        .from('pets')
        .update(updates)
        .eq('user_id', user.id)
        .select()
        .single();

      if (error) throw error;

      return {
        status: 'success',
        data
      };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message
      };
    }
  }

  async deleteAccount() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { error } = await this.supabase.auth.admin.deleteUser(user.id);
      if (error) throw error;

      return {
        status: 'success',
        message: 'Account deleted successfully'
      };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message
      };
    }
  }

  async getAchievements() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await this.supabase
        .from('user_achievements')
        .select(`
          *,
          achievement_types (
            name,
            description,
            icon,
            category
          )
        `)
        .eq('user_id', user.id)
        .order('unlocked_at', { ascending: false });

      if (error) throw error;

      return {
        status: 'success',
        data: data || []
      };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message
      };
    }
  }

  async getStatistics() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await this.supabase
        .from('user_statistics')
        .select('*')
        .eq('user_id', user.id)
        .maybeSingle();

      if (error) throw error;

      return {
        status: 'success',
        data: data || {}
      };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message
      };
    }
  }
}

export default new UserService();
