export const Logger = {
  warn: (...args: any[]) => {
    console.warn('[adapter]', ...args);
  },
  log: (...args: any[]) => {
    console.log('[adapter warn]', ...args);
  },
};
