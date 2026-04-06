import supabaseService from './supabase.service';

export interface RegisterData {
  username: string;
  email: string;
  password: string;
  pet: number;
  petName: string;
}

export interface LoginData {
  email: string;
  password: string;
}

class AuthService {
  private supabase = supabaseService.getClient();

  async register(data: RegisterData) {
    try {
      const { data: authData, error: authError } = await this.supabase.auth.signUp({
        email: data.email,
        password: data.password,
        options: {
          data: {
            username: data.username
          }
        }
      });

      if (authError) throw authError;

      if (authData.user) {
        const { error: petError } = await this.supabase
          .from('pets')
          .insert({
            user_id: authData.user.id,
            name: data.petName,
            type_id: data.pet
          });

        if (petError) throw petError;
      }

      return { status: 'success', data: authData };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message || 'Registration failed'
      };
    }
  }

  async login(data: LoginData) {
    try {
      const { data: authData, error } = await this.supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password
      });

      if (error) throw error;

      return { status: 'success', data: authData };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message || 'Login failed'
      };
    }
  }

  async logout() {
    try {
      const { error } = await this.supabase.auth.signOut();
      if (error) throw error;

      return { status: 'success', message: 'Logged out successfully' };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message || 'Logout failed'
      };
    }
  }

  async resetPassword(email: string) {
    try {
      const { error } = await this.supabase.auth.resetPasswordForEmail(email);
      if (error) throw error;

      return { status: 'success', message: 'Password reset email sent' };
    } catch (error: any) {
      return {
        status: 'error',
        code: error.code || 'UNKNOWN',
        message: error.message || 'Password reset failed'
      };
    }
  }

  async getCurrentUser() {
    const { data: { user } } = await this.supabase.auth.getUser();
    return user;
  }

  async getSession() {
    const { data: { session } } = await this.supabase.auth.getSession();
    return session;
  }
}

export default new AuthService();
