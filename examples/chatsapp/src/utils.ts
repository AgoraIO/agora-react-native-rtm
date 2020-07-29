export const Logger = {
  warn: (...args: any[]) => {
    console.warn("[adapter]", ...args)
  },
  log: (...args: any[]) => {
    console.log("[adapter warn]", ...args)
  }
}

export const APP_ID = '2b4b76e458cf439aa7cd313b9504f0a4'
