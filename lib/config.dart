
Map configs = {
  'development': {
    'url': 'https://momday.net/index.php?route='
  },
  'staging': {
    'url': 'https://momday.net/index.php?route='
  },
  'staging-remote': {
    'url': 'http://momday.net/index.php?route='
  },
  'production': {
    'url': 'https://momday.net/index.php?route='
  },
  'local': {
    'url': 'https://momday.net/index.php?route='
  },
  'test': {
    'url': 'https://momday.net/index.php?route='
  }
};

enum Environment {DEVELOPMENT, PRODUCTION, STAGING, STAGING_REMOTE, LOCAL, TEST}

class EnvironmentConfig {
  static Environment environment;

  static of(String key) {
    switch (EnvironmentConfig.environment) {
      case Environment.DEVELOPMENT:
        return configs['development'][key];
      case Environment.PRODUCTION:
        return configs['production'][key];
      case Environment.STAGING:
        return configs['staging'][key];
      case Environment.STAGING_REMOTE:
        return configs['staging-remote'][key];
      case Environment.LOCAL:
        return configs['local'][key];
      case Environment.TEST:
        return configs['test'][key];
    }
  }
}