module.exports = {
  // default applies to all environments
  default: {
    enabled: true,
    provider: "whisper", // Communication provider. Currently, Embark only supports whisper
    available_providers: ["whisper"], // Array of available providers
  },

  // default environment, merges with the settings in default
  // assumed to be the intended environment by `embark run`
  development: {
    connection: {
      host: "localhost", // Host of the blockchain node
      port: 8546, // Port of the blockchain node
      type: "ws" // Type of connection (ws or rpc)
    }
  },
};
