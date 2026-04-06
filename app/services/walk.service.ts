import supabaseService from './supabase.service';
import petService from './pet.service';

interface TrackPoint {
  lat: number;
  lng: number;
  sequenceNumber: number;
}

class WalkService {
  private supabase = supabaseService.getClient();

  async startWalk() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data: existingWalk } = await this.supabase
        .from('walks')
        .select('id')
        .eq('user_id', user.id)
        .is('end_time', null)
        .maybeSingle();

      if (existingWalk) {
        return {
          walk_id: existingWalk.id,
          message: 'Walk already in progress',
          start_time: new Date().toISOString()
        };
      }

      const { data, error } = await this.supabase
        .from('walks')
        .insert({ user_id: user.id })
        .select()
        .single();

      if (error) throw error;

      return {
        walk_id: data.id,
        start_time: data.start_time,
        message: 'Walk started successfully'
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async trackPoint(walkId: string, point: TrackPoint) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data: walk } = await this.supabase
        .from('walks')
        .select('id, user_id')
        .eq('id', walkId)
        .eq('user_id', user.id)
        .maybeSingle();

      if (!walk) throw new Error('Walk not found');

      const { error } = await this.supabase
        .from('walk_points')
        .insert({
          walk_id: walkId,
          latitude: point.lat,
          longitude: point.lng,
          sequence_number: point.sequenceNumber
        });

      if (error) throw error;

      const shouldCollectItem = Math.random() < 0.1;
      let collected_item = null;

      if (shouldCollectItem) {
        const { data: itemTypes } = await this.supabase
          .from('item_types')
          .select('*');

        if (itemTypes && itemTypes.length > 0) {
          const randomItem = itemTypes[Math.floor(Math.random() * itemTypes.length)];

          const { data: newItem, error: itemError } = await this.supabase
            .from('user_items')
            .insert({
              user_id: user.id,
              item_type_id: randomItem.id,
              walk_id: walkId,
              latitude: point.lat,
              longitude: point.lng
            })
            .select()
            .single();

          if (!itemError) {
            collected_item = {
              id: newItem.id,
              name: randomItem.name,
              icon: randomItem.icon,
              rarity: randomItem.rarity,
              exp_value: randomItem.exp_value
            };

            await petService.addExperience(randomItem.exp_value);

            await this.supabase
              .from('walks')
              .update({ items_collected: this.supabase.sql`items_collected + 1` })
              .eq('id', walkId);
          }
        }
      }

      return {
        success: true,
        collected_item
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async endWalk(walkId: string) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data: walk, error: walkError } = await this.supabase
        .from('walks')
        .select('*')
        .eq('id', walkId)
        .eq('user_id', user.id)
        .maybeSingle();

      if (walkError || !walk) throw new Error('Walk not found');

      const { data: points } = await this.supabase
        .from('walk_points')
        .select('latitude, longitude, timestamp')
        .eq('walk_id', walkId)
        .order('sequence_number');

      let distance = 0;
      if (points && points.length > 1) {
        for (let i = 1; i < points.length; i++) {
          distance += this.calculateDistance(
            points[i - 1].latitude,
            points[i - 1].longitude,
            points[i].latitude,
            points[i].longitude
          );
        }
      }

      const endTime = new Date();
      const startTime = new Date(walk.start_time);
      const duration = Math.floor((endTime.getTime() - startTime.getTime()) / 1000);

      const { error: updateError } = await this.supabase
        .from('walks')
        .update({
          end_time: endTime.toISOString(),
          distance_meters: distance,
          duration_seconds: duration,
          route: points || []
        })
        .eq('id', walkId);

      if (updateError) throw updateError;

      const baseExp = Math.floor(distance / 100) * 10;
      await petService.addExperience(baseExp);

      const new_achievements = await this.checkAchievements(user.id);

      return {
        walk_id: walkId,
        distance_meters: distance,
        duration_seconds: duration,
        items_collected: walk.items_collected,
        summary: {
          distance_km: (distance / 1000).toFixed(2),
          duration_min: Math.floor(duration / 60),
          exp_earned: baseExp + (walk.items_collected * 10)
        },
        new_achievements
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async getHistory(limit = 10, offset = 0) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error, count } = await this.supabase
        .from('walks')
        .select('*', { count: 'exact' })
        .eq('user_id', user.id)
        .not('end_time', 'is', null)
        .order('start_time', { ascending: false })
        .range(offset, offset + limit - 1);

      if (error) throw error;

      return {
        total: count || 0,
        walks: data || []
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  async getWalkDetails(walkId: string) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data: walk, error } = await this.supabase
        .from('walks')
        .select('*')
        .eq('id', walkId)
        .eq('user_id', user.id)
        .maybeSingle();

      if (error || !walk) throw new Error('Walk not found');

      const { data: items } = await this.supabase
        .from('user_items')
        .select(`
          id,
          collected_at,
          latitude,
          longitude,
          item_types (
            name,
            icon,
            rarity
          )
        `)
        .eq('walk_id', walkId);

      return {
        id: walk.id,
        start_time: walk.start_time,
        end_time: walk.end_time,
        distance_meters: walk.distance_meters,
        duration_seconds: walk.duration_seconds,
        route: walk.route,
        collected_items: items || []
      };
    } catch (error: any) {
      return { error: error.message };
    }
  }

  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000;
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  private async checkAchievements(userId: string) {
    const newAchievements: any[] = [];

    try {
      const { data: stats } = await this.supabase
        .from('user_statistics')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();

      const { data: pet } = await this.supabase
        .from('pets')
        .select('level')
        .eq('user_id', userId)
        .maybeSingle();

      const { data: achievementTypes } = await this.supabase
        .from('achievement_types')
        .select('*');

      const { data: userAchievements } = await this.supabase
        .from('user_achievements')
        .select('achievement_type_id')
        .eq('user_id', userId);

      const unlockedIds = new Set(userAchievements?.map(a => a.achievement_type_id) || []);

      if (stats && achievementTypes) {
        for (const achievement of achievementTypes) {
          if (unlockedIds.has(achievement.id)) continue;

          let achieved = false;
          if (achievement.category === 'walks' && stats.total_walks >= achievement.requirement_value) {
            achieved = true;
          } else if (achievement.category === 'distance' && stats.total_distance_meters >= achievement.requirement_value) {
            achieved = true;
          } else if (achievement.category === 'items' && stats.total_items_collected >= achievement.requirement_value) {
            achieved = true;
          } else if (achievement.category === 'level' && pet && pet.level >= achievement.requirement_value) {
            achieved = true;
          }

          if (achieved) {
            await this.supabase
              .from('user_achievements')
              .insert({
                user_id: userId,
                achievement_type_id: achievement.id,
                progress: achievement.requirement_value
              });

            newAchievements.push(achievement);
          }
        }
      }
    } catch (error) {
      console.error('Error checking achievements:', error);
    }

    return newAchievements;
  }
}

export default new WalkService();
