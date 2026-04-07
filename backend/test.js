const supabase = require('./src/lib/supabaseClient');

async function testConnection() {
  const { data, error } = await supabase
    .from('pet')
    .select('*');

  if (error) {
    console.error('❌ Supabase error:', error);
  } else {
    console.log('✅ Supabase data:', data);
  }
}

testConnection();