/**
 * https://prettier.io/docs/en/
 * Prettier configuration file
 * In order to update the this config, update @code-style/code-style
 */
import config from '@code-style/code-style/prettierrc';
/**
 * @see https://prettier.io/docs/configuration
 * @type {import("prettier").Config}
 */
export default {
  ...config,
  overrides: [
    {
      files: '.vscode/settings.json',
      options: {
        parser: 'jsonc',
      },
    },
  ],
};
