// Use https://finicky-kickstart.now.sh to generate basic configuration
// Learn more about configuration options:
// https://github.com/johnste/finicky/wiki/Configuration

module.exports = {
  defaultBrowser: 'Firefox',
  handlers: [
    /* Performance */ [
      {
        match: [
          '*cloud.google.com/*',
          'redirect.teleparty.com/join/*',
          'https://spectra.loggly.com/*',
        ],
        browser: 'Google Chrome',
      },
    ],
    /* Music */ [
      {
        match: ['music.apple.com/*'],
        browser: '/System/Applications/Music.app',
      },
      {
        match: ['open.spotify.com/*'],
        browser: '/Applications/Spotify.app',
      },
    ],
    /* Video Conferencing */ [
      {
        match: ['meet.google.com/*'],
        browser: 'Google Chrome',
        // browser: '/Users/dudeofawesome/Applications/Chrome Apps.localized/Google Meet.app',
      },
      {
        match: ['*.zoom.us/j/*', '*.zoom.us/my/*'],
        browser: zoom_path ?? 'us.zoom.xos',
      },
      {
        match: [/^slack:\/\/.*$/],
        browser: '/Applications/Slack.app',
      },
      {
        match: ['teams.microsoft.com/l/meetup-join/*'],
        browser: '/Applications/Microsoft Teams.app',
        // Teams only supports a broken URI scheme without the proper slashes between proto and host.
        url: ({ url }) =>
          `msteams:${url.pathname}${url.search ? `?${url.search}` : ''}${
            url.hash ? `#${url.hash}` : ''
          }`,
      },
    ],
    /* Other */ [
      {
        match: ['https://prod.liveshare.*.visualstudio.com/join?*'],
        browser: '/Applications/Visual Studio Code.app',
      },
    ],
  ].flat(),
  rewrite: [
    {
      match: ['https://*.slack.com/*'],
      url: ({ url }) => {
        // TODO: figure out how to get this dynamically
        const pac_slack_id = 'T1DMCHP33';
        const path_parts = url.pathname.split('/').filter((p) => p != '');

        if (path_parts[0] === 'team') {
          return `slack://user?team=${pac_slack_id}&id=${path_parts[1]}`;
        } else if (path_parts[0] === 'archives') {
          if (path_parts.length === 2) {
            return `slack://channel?team=${pac_slack_id}&id=${path_parts[1]}`;
          } else if (path_parts.length === 3) {
            // return `slack://channel?team=${pac_slack_id}&id=${path_parts[1]}&ts=${path_parts[2]}`;
          }
        }

        return url;
      },
    },
  ],
};
