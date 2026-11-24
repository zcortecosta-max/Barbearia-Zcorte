// Cole aqui os dois valores do Supabase (Project Settings > API).
// A chave "anon public" pode ficar no site: ela só deixa o cliente agendar e ver horários ocupados.
window.CONFIG = {
  SUPABASE_URL: "https://wengpbjebkbidovcsopq.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_GdE7PadY73KW3dEBl7BERA_HUCb1_vX",

  name: "Zcorte",
  tagline: "Escolha o serviço, o barbeiro e o horário.",
  whatsapp: "5585999999999",   // DDI + DDD + número, só dígitos
  open: 9, close: 19,          // abre às 9h, último horário termina às 19h
  step: 30,                    // minutos entre um horário e outro
  closedDays: [0],             // 0 = domingo
  daysAhead: 28,
  barbers: [                   // com um só barbeiro, a tela de escolha não aparece
    { id: "z", name: "Zé" }
  ],
  services: [
    { id: "corte",       name: "Corte",                        min: 30, price: 35 },
    { id: "corte-barba", name: "Corte e barba",                min: 40, price: 55 },
    { id: "completo",    name: "Barba, sobrancelha e cabelo",  min: 60, price: 80 }
  ]
};
