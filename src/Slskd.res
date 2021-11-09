module State = {
  type version = {
    current: string,
    latest: option<string>,
    isUpdateAvailable: option<bool>,
    isCanary: bool,
  }

  type server = {
    address: string,
    ipEndPoint: string,
    state: string,
    username: string,
    isConnected: bool,
    isLoggedIn: bool,
    isTransitioning: bool,
  }

  type sharedFileCache = {
    filling: bool,
    faulted: bool,
    fillProgress: float,
    directories: int,
    files: int,
    excludedDirectories: int,
  }

  type t = {
    version: version,
    pendingReconnect: bool,
    pendingRestart: bool,
    pendingShareScan: bool,
    server: server,
    sharedFileCache: sharedFileCache,
    rooms: array<string>,
  }
}

type logLevel = [#Verbose | #Debug | #Information | #Warning | #Error | #Fatal]

type log = {
  timestamp: Js.Date.t,
  context: string,
  level: logLevel,
  message: string,
}
