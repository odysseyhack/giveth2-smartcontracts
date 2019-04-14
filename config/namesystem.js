module.exports = {
  // default applies to all environments
  default: {
    enabled: true,
    available_providers: ["ens"],
    provider: "ens"
  },

  // default environment, merges with the settings in default
  // assumed to be the intended environment by `embark run`
  development: {
    register: {
      rootDomain: "embark.eth",
      subdomains: {
        'status': '0x1a2f3b98e434c02363f3dac3174af93c1d690914'
      }
    }
  },
};
